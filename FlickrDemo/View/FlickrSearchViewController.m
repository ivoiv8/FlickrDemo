//
//  FlickrSearchViewController.m
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 8.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import "FlickrSearchViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CETableViewBindingHelper.h"
#import "SearchResultsTableViewCell.h"
#import "SearchResultsItemViewModel.h"

@interface FlickrSearchViewController () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (strong, nonatomic) NSArray *commentsArray;

@property (weak, nonatomic) FlickrSearchViewModel *viewModel;
@property (strong, nonatomic) CETableViewBindingHelper *bindingHelper;

@end

@implementation FlickrSearchViewController

- (instancetype)initWithViewModel:(FlickrSearchViewModel *)viewModel {
    self = [super init];
    if (self ) {
        self.viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self bindViewModel];
}

- (void)bindViewModel {
    
    RAC(self, title) = RACObserve(self, viewModel.title);

    RAC(self.viewModel, searchText) = self.searchTextField.rac_textSignal;
    
    self.searchButton.rac_command = self.viewModel.executeSearch;
    
    RAC(self.loadingIndicator, hidden) =
    [self.viewModel.executeSearch.executing not];

    RAC([UIApplication sharedApplication], networkActivityIndicatorVisible) =
    self.viewModel.executeSearch.executing;
    
    [self.viewModel.executeSearch.executionSignals
     subscribeNext:^(id x) {
         [self.searchTextField resignFirstResponder];
         [self bindResults];
         [self.searchResultsTable setContentOffset:CGPointZero animated:YES];
     }];
    
    [self.viewModel.connectionErrors subscribeNext:^(NSError *error) {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                   message:@"There was a problem reaching Flickr."
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
    }];
    
    RACSignal *commentsChangedSignal = [RACObserve(self, commentsArray) skip:2];
    [commentsChangedSignal subscribeNext:^(id x) {
        [self.viewModel refreshTableView];
        NSLog(@"\n comments were modified");
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    if (![self.commentsArray isEqualToArray:[self allCommentsArray]]) {
        self.commentsArray = [self allCommentsArray];
    }
}

- (void)bindResults {
    UINib *nib = [UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:nil];
    self.bindingHelper  =
    [CETableViewBindingHelper bindingHelperForTableView:self.searchResultsTable
                                           sourceSignal:RACObserve(self.viewModel, searchResults)
                                       selectionCommand:nil
                                           templateCell:nib];
    
    self.bindingHelper.delegate = self;
}

#pragma mark - Text view delegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *cells = [self.searchResultsTable visibleCells];
    for (SearchResultsTableViewCell *cell in cells) {
        CGFloat value = -5 + (cell.frame.origin.y - self.searchResultsTable.contentOffset.y) / 10;
        [cell setParallax:value];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.viewModel.executeSearch execute:nil];
    
    return YES;
}

#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultsItemViewModel *detailsViewModel = [[SearchResultsItemViewModel alloc] initWithPhoto:self.viewModel.searchResults[indexPath.row] services:self.viewModel.services];
    [self.viewModel.services pushViewModel:detailsViewModel];
}


#pragma mark - Core Data methods
- (NSArray *)allCommentsArray {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FlickrPhotoCD"];
    NSSortDescriptor *sortDescriptorDate = [[NSSortDescriptor alloc] initWithKey:@"date"
                                                                       ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorDate, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
                                                  ascending:NO;
    NSArray *allComments = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    NSLog(@"\n %lu Comments Total", (unsigned long)allComments.count);
    
    return [allComments valueForKey:@"comment"];;
}

@end
