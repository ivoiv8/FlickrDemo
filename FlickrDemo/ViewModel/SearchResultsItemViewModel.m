//
//  SearchResultsItemViewModel.m
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 8.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import "SearchResultsItemViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "FlickrPhototMetadata.h"

@interface SearchResultsItemViewModel ()

@property (weak, nonatomic) id<ViewModelServices> services;
@property (strong, nonatomic) FlickrPhoto *photo;

@end

@implementation SearchResultsItemViewModel

- (instancetype)initWithPhoto:(FlickrPhoto *)photo services:(id<ViewModelServices>)services {
    self = [super init];
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];

    if (self) {
        _identifier = photo.identifier;
        _title = photo.title;
        _owner = photo.owner;
        _photoDescription = photo.photoDescription;
        _url = photo.url;
        _services = services;
        _photo = photo;
        
        _commentsArray = [self commentsForPhotoWithURL:photo.url];
        
        [self initialize];
    }
    return  self;
}

- (void)initialize {
    
    RACSignal *visibleStateChanged = [RACObserve(self, isVisible) skip:1];
    
    RACSignal *visibleSignal = [visibleStateChanged filter:^BOOL(NSNumber *value) {
        return [value boolValue];
    }];
    
    RACSignal *hiddenSignal = [visibleStateChanged filter:^BOOL(NSNumber *value) {
        return ![value boolValue];
    }];
    
    RACSignal *fetchMetadata = [[visibleSignal delay:1.0f]
                                takeUntil:hiddenSignal];
    
    
    @weakify(self)
    [fetchMetadata subscribeNext:^(id x) {
        @strongify(self)
        [[[self.services getFlickrSearchService] flickrImageMetadata:self.photo.identifier]
         subscribeNext:^(FlickrPhototMetadata *x) {
             self.favouritesCount = @(x.favourites);
             self.commentsCount = @(x.comments);
             self.viewsCount = @(x.views);
             self.owner = (x.owner);
             self.photoDescription = (x.photoDescription);
         }];
    }];
}

- (NSArray *)commentsForPhotoWithURL: (NSURL *)url {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FlickrPhotoCD"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(urlPath == %@)", url.path];
    NSSortDescriptor *sortDescriptorDate = [[NSSortDescriptor alloc] initWithKey:@"date"
                                                                       ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorDate, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *comments = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    NSLog(@"\n %lu Comments", (unsigned long)comments.count);

    return [comments valueForKey:@"comment"];;
}

@end
