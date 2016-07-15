//
//  SearchResultsItemViewModel.h
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 8.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrPhoto.h"
#import "ViewModelServices.h"
#import <CoreData/CoreData.h>

@interface SearchResultsItemViewModel : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) BOOL isVisible;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *owner;
@property (strong, nonatomic) NSString *photoDescription;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSNumber *favouritesCount;
@property (strong, nonatomic) NSNumber *commentsCount;
@property (strong, nonatomic) NSNumber *viewsCount;
@property (strong, nonatomic) NSString *identifier;

@property (strong, nonatomic) NSArray *commentsArray;

- (instancetype) initWithPhoto:(FlickrPhoto *)photo services:(id<ViewModelServices>)services;


@end
