//
//  ViewModelServices.h
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 8.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrSearch.h"

@protocol ViewModelServices <NSObject>

- (void) pushViewModel:(id)viewModel;

- (id<FlickrSearch>) getFlickrSearchService;

@end
