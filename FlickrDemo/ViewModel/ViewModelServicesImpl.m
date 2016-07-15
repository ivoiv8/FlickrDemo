//
//  ViewModelServicesImpl.m
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 8.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import "ViewModelServicesImpl.h"
#import "FlickrSearchImpl.h"
#import "SearchResultsItemViewModel.h"
#import "FlickrDetailsViewController.h"

@interface ViewModelServicesImpl ()

@property (strong, nonatomic) FlickrSearchImpl *searchService;
@property (weak, nonatomic) UINavigationController *navigationController;

@end

@implementation ViewModelServicesImpl

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController {
    if (self = [super init]) {
        _searchService = [FlickrSearchImpl new];
        _navigationController = navigationController;
    }
    return self;
}


- (id<FlickrSearch>)getFlickrSearchService {
    return  self.searchService;
}

- (void)pushViewModel:(id)viewModel {
    id viewController;
    
    if ([viewModel isKindOfClass:SearchResultsItemViewModel.class]) {
        viewController = [[FlickrDetailsViewController alloc] initWithViewModel:viewModel];
    } else {
        NSLog(@"an unknown ViewModel was pushed!");
    }

    [self.navigationController pushViewController:viewController animated:YES];
}

@end
