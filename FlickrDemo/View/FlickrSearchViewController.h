//
//  FlickrSearchViewController.h
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 8.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrSearchViewModel.h"
#import <CoreData/CoreData.h>

@interface FlickrSearchViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (instancetype)initWithViewModel:(FlickrSearchViewModel *)viewModel;
- (void)bindViewModel;
- (void)bindResults;

@end