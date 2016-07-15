//
//  FlickrDetailsViewController.h
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 11.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResultsItemViewModel.h"
#import <CoreData/CoreData.h>

@interface FlickrDetailsViewController : UIViewController <NSFetchedResultsControllerDelegate>


@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (instancetype)initWithViewModel:(SearchResultsItemViewModel *)viewModel;

@end
