//
//  FlickrPhototMetadata.m
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 8.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import "FlickrPhototMetadata.h"

@implementation FlickrPhototMetadata

- (NSString *)description {
    return [NSString stringWithFormat:@"\n metadata:author=%@ comments=%lU, faves=%lU, views=%lU, description= %@", self.owner, self.comments, self.favourites, self.views, self.photoDescription];
}

@end