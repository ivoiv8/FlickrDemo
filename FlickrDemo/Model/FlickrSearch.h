//
//  FlickrSearch.h
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 8.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Foundation/Foundation.h>

@protocol FlickrSearch <NSObject>

- (RACSignal *)flickrSearchSignal:(NSString *)searchString;

- (RACSignal *)flickrImageMetadata:(NSString *)photoId;

@end
