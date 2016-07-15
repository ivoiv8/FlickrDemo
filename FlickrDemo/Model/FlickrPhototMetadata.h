//
//  FlickrPhototMetadata.h
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 8.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrPhototMetadata : NSObject


@property (nonatomic) NSUInteger favourites;
@property (nonatomic) NSUInteger comments;
@property (nonatomic) NSUInteger views;
@property (nonatomic) NSString *owner;
@property (nonatomic) NSString *photoDescription;

@end