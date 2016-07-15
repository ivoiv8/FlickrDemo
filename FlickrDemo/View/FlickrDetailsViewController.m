//
//  FlickrDetailsViewController.m
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 11.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import "FlickrDetailsViewController.h"
#import "SearchResultsItemViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "FlickrPhotoCD.h"

@interface FlickrDetailsViewController () <UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) SearchResultsItemViewModel *viewModel;
@property (weak, nonatomic)  NSString *lastComment;

@property (weak, nonatomic) IBOutlet UIImageView *imageThumbnailView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *viewsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favouritesCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsCountLabel;
@property (weak, nonatomic) IBOutlet UIToolbar *commentsToolbar;
@property (weak, nonatomic) IBOutlet UITextField *commentingTextField;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendCommentButton;

- (IBAction)sendComment:(id)sender;


@end

@implementation FlickrDetailsViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (instancetype)initWithViewModel:(SearchResultsItemViewModel *)viewModel {
    if (self = [super init]) {
        _viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"\n Error! %@",error);
        abort();
    }
    
    RACSignal *validCommentSignal =
    [[RACObserve(self, lastComment)
      map:^id(NSString *text) {
          return @(text.length > 1);
      }]
     distinctUntilChanged];
    
    [validCommentSignal subscribeNext:^(NSNumber *isValidComment) {
        NSLog(@"\n comment text is valid");
        self.sendCommentButton.enabled = isValidComment.boolValue;
    }];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self bindViewModel:self.viewModel];
}

- (void)bindViewModel:(id)viewModel {
    SearchResultsItemViewModel *photo = viewModel;
    self.favouritesCountLabel.text = photo.favouritesCount.stringValue;
    self.commentsCountLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)photo.commentsArray.count];
    
    self.imageThumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.imageThumbnailView sd_setImageWithURL:photo.url];
    
    [RACObserve(photo, favouritesCount) subscribeNext:^(NSNumber *x) {
        self.favouritesCountLabel.text = [x stringValue];
        self.favouritesCountLabel.hidden = (x == nil);
    }];
    
    [RACObserve(photo, commentsCount) subscribeNext:^(NSNumber *x) {
        self.commentsCountLabel.text = [x stringValue];
        self.commentsCountLabel.hidden = (x == nil);
    }];
    
    [RACObserve(photo, viewsCount) subscribeNext:^(NSNumber *x) {
        self.viewsCountLabel.text = [x stringValue];
        self.viewsCountLabel.hidden = (x == nil);
    }];
    
    [RACObserve(photo, photoDescription) subscribeNext:^(NSString *x) {
        self.descriptionTextView.text = x;
        dispatch_async(dispatch_get_main_queue(), ^{
        [self.descriptionTextView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
        });
        self.viewsCountLabel.hidden = (x == nil);
    }];
    
    photo.isVisible = YES;
}

- (IBAction)sendComment:(id)sender {
    if (self.commentingTextField.text.length > 0) {
        FlickrPhotoCD *newPhoto = (FlickrPhotoCD *) [NSEntityDescription insertNewObjectForEntityForName:@"FlickrPhotoCD" inManagedObjectContext:[self managedObjectContext]];
        newPhoto.date = [NSDate date];
        newPhoto.urlPath = self.viewModel.url.path;
        newPhoto.comment = self.commentingTextField.text;
        self.commentingTextField.text = @"";
        
        [self.managedObjectContext performBlock:^{
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"\n Error! %@", error);
            } else {
                NSLog(@"\n Comment Saved");
            }
        }];
    }
}

#pragma mark - Text view delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (self.lastComment.length > 1) {
        [theTextField resignFirstResponder];
        [self sendComment:nil];
    }
    return NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.lastComment = textField.text;
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> secInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [secInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    [self.commentsTableView registerClass:[UITableViewCell self] forCellReuseIdentifier:@"Cell"];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    FlickrPhotoCD *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.username;
    cell.detailTextLabel.text = photo.comment;
    cell.imageView.image = [UIImage imageNamed:@"avatar"];
    
    return cell;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[self.fetchedResultsController sections]objectAtIndex:section]name];
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        FlickrPhotoCD *photoToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext performBlock:^{
            [self.managedObjectContext deleteObject:photoToDelete];
        }];
        
        [self.managedObjectContext performBlock:^{
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"\n Error! %@", error);
            } else {
                NSLog(@"\n Comment Deleted");
            }
        }];
    }
}

#pragma mark -
#pragma mark Fetched Results Controller section
-(NSFetchedResultsController *) fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FlickrPhotoCD"
                                              inManagedObjectContext:[self managedObjectContext]];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(urlPath == %@)", self.viewModel.url.path];

    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptorDate = [[NSSortDescriptor alloc] initWithKey:@"date"
                                                                           ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorDate, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

-(void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.commentsTableView beginUpdates];
}

-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.commentsTableView endUpdates];
}
-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.commentsTableView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            FlickrPhotoCD *changedComment = [self.fetchedResultsController objectAtIndexPath:indexPath];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.textLabel.text = changedComment.comment;
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}

-(void) controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.commentsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.commentsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}
@end
