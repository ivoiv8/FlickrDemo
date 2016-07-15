//
//  FlickrSearchViewModel.h
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 8.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "ViewModelServices.h"
#import "FlickrSearchResults.h"

@interface FlickrSearchViewModel : NSObject

@property (weak, nonatomic) id<ViewModelServices> services;

- (instancetype)initWithServices:(id<ViewModelServices>)services;

@property (strong, nonatomic) RACCommand *executeSearch;
@property (strong, nonatomic) RACCommand *selectionCommand;
@property (strong, nonatomic) NSString *searchText;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) RACSignal *connectionErrors;
@property (strong, nonatomic) NSArray *searchResults;

- (void)refreshTableView;

@end

