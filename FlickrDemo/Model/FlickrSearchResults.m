//
//  FlickrSearchResults.m
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 8.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import "FlickrSearchResults.h"

@implementation FlickrSearchResults

- (NSString *)description {
    return [NSString stringWithFormat:@"searchString=%@, totalresults=%lU, photos=%@",
            self.searchString, (unsigned long)self.totalResults, self.photos];
}

@end
