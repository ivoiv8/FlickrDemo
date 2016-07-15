//
//  FlickrSearchViewModel.m
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 8.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import "FlickrSearchViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <LinqToObjectiveC/NSArray+LinqExtensions.h>
#import "FlickrPhoto.h"
#import "SearchResultsItemViewModel.h"
#import "FlickrSearchViewController.h"

@interface FlickrSearchViewModel ()

@property (strong, nonatomic) FlickrSearchResults *searcResults;;

@end

@implementation FlickrSearchViewModel

- (instancetype)initWithServices:(id<ViewModelServices>)services {
    self = [super init];
    if (self) {
        _services = services;
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.title = @"Flickr Search";
    
    RACSignal *validSearchSignal =
    [[RACObserve(self, searchText)
      map:^id(NSString *text) {
          return @(text.length > 3);
      }]
     distinctUntilChanged];
    
    [validSearchSignal subscribeNext:^(id x) {
        NSLog(@"\n search text is valid %@", x);
    }];
    
    self.executeSearch =
    [[RACCommand alloc] initWithEnabled:validSearchSignal
                            signalBlock:^RACSignal *(id input) {
                                return  [self executeSearchSignal];
                            }];
    
    self.connectionErrors = self.executeSearch.errors;
}



-(RACSignal *)executeSearchSignal {
    return [[[self.services getFlickrSearchService]
             flickrSearchSignal:self.searchText]
            doNext:^(id result) {
                self.searcResults = result;
                // init table
                [self initSearchResults:result services:self.services];
            }];
}


- (void)initSearchResults:(FlickrSearchResults *)results
                 services:(id<ViewModelServices>)services {
    self.searchResults =
    [results.photos linq_select:^id(FlickrPhoto *photo) {
        return [[SearchResultsItemViewModel alloc]
                initWithPhoto:photo services:services];
    }];
    [self updateNavTitleWithNumberOfResults:results.totalResults];
}

- (void)updateNavTitleWithNumberOfResults: (NSUInteger)totalResults {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSString *numberAsString = [numberFormatter stringFromNumber:@(totalResults)];
    
    self.title = [NSString stringWithFormat:@"%@ results for %@", numberAsString, self.searchText];
}

- (void)refreshTableView {
    [self initSearchResults:self.searcResults services:self.services];
}
@end

