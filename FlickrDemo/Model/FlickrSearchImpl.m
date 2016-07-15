//
//  FlickrSearchImpl.m
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 8.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import "FlickrSearchImpl.h"
#import "FlickrSearchResults.h"
#import "FlickrPhoto.h"
#import <objectiveflickr/ObjectiveFlickr.h>
#import <LinqToObjectiveC/NSArray+LinqExtensions.h>
#import "FlickrPhototMetadata.h"
#import <ReactiveCocoa/RACEXTScope.h>


@interface FlickrSearchImpl () <OFFlickrAPIRequestDelegate>

@property (strong, nonatomic) NSMutableSet *requests;
@property (strong, nonatomic) OFFlickrAPIContext *flickrContext;

@end

@implementation FlickrSearchImpl

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *OFSampleAppAPIKey = @"2c6bd9a82c183bbf67fb6e6930188c14"; // @"9d1bdbde083bc30ebe168a64aac50be5";
        NSString *OFSampleAppAPISharedSecret = @"489902f49c6c57e4"; // @"5fbfa610234c6c23";
        
        _flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:OFSampleAppAPIKey
                                                       sharedSecret:OFSampleAppAPISharedSecret];
        _requests = [NSMutableSet new];
    }
    return  self;
}

- (RACSignal *)signalFromAPIMethod:(NSString *)method
                         arguments:(NSDictionary *)args
                         transform:(id (^)(NSDictionary *response))block {
    
    // 1. Create a signal for this request
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // 2. Create a Flick request object
        OFFlickrAPIRequest *flickrRequest =
        [[OFFlickrAPIRequest alloc] initWithAPIContext:self.flickrContext];
        flickrRequest.delegate = self;
        [self.requests addObject:flickrRequest];
        
        RACSignal *errorSignal =
        [self rac_signalForSelector:@selector(flickrAPIRequest:didFailWithError:)
                       fromProtocol:@protocol(OFFlickrAPIRequestDelegate)];
        
        [errorSignal subscribeNext:^(RACTuple *tuple) {
            [subscriber sendError:tuple.second];
        }];
        
        // 3. Create a signal from the delegate method
        RACSignal *successSignal =
        [self rac_signalForSelector:@selector(flickrAPIRequest:didCompleteWithResponse:)
                       fromProtocol:@protocol(OFFlickrAPIRequestDelegate)];
        
        @weakify(flickrRequest)
        [[[[successSignal
            filter:^BOOL(RACTuple *tuple) {
                @strongify(flickrRequest)
                return tuple.first == flickrRequest;
            }]
           map:^id(RACTuple *tuple) {
               return tuple.second;
           }]
          map:block]
         subscribeNext:^(id x) {
             [subscriber sendNext:x];
             [subscriber sendCompleted];
         }];
        
        // 5. Make the request
        [flickrRequest callAPIMethodWithGET:method
                                  arguments:args];
        
        // 6. When we are done, remvoe the reference to this request
        return [RACDisposable disposableWithBlock:^{
            [self.requests removeObject:flickrRequest];
        }];
    }];
}

/// provides a signal that returns the result of a Flickr search
- (RACSignal *)flickrSearchSignal:(NSString *)searchString {
    return [self signalFromAPIMethod:@"flickr.photos.search"
                           arguments:@{@"text": searchString,
                                       @"sort": @"interestingness-desc"}
                           transform:^id(NSDictionary *response) {
                               
                               FlickrSearchResults *results = [FlickrSearchResults new];
                               results.searchString = searchString;
                               results.totalResults = [[response valueForKeyPath:@"photos.total"] integerValue];
                               
                               NSArray *photos = [response valueForKeyPath:@"photos.photo"];
                               results.photos = [photos linq_select:^id(NSDictionary *jsonPhoto) {
                                   FlickrPhoto *photo = [FlickrPhoto new];
                                   photo.title = [jsonPhoto objectForKey:@"title"];
                                   //photo.owner = [jsonPhoto objectForKey:@"owner"];
                                   photo.identifier = [jsonPhoto objectForKey:@"id"];
                                   photo.url = [self.flickrContext photoSourceURLFromDictionary:jsonPhoto
                                                                                           size:OFFlickrSmallSize];
                                   return photo;
                               }];
                               
                               return results;
                           }];
}

- (RACSignal *)flickrImageMetadata:(NSString *)photoId {
    
    RACSignal *favourites = [self signalFromAPIMethod:@"flickr.photos.getFavorites"
                                            arguments:@{@"photo_id": photoId}
                                            transform:^id(NSDictionary *response) {
                                                NSString *total = [response valueForKeyPath:@"photo.total"];
                                                return total;
                                            }];
    
    RACSignal *comments = [self signalFromAPIMethod:@"flickr.photos.getInfo"
                                          arguments:@{@"photo_id": photoId}
                                          transform:^id(NSDictionary *response) {
                                              NSString *total = [response valueForKeyPath:@"photo.comments._text"];
                                              return total;
                                          }];
    
    RACSignal *views = [self signalFromAPIMethod:@"flickr.photos.getInfo"
                                          arguments:@{@"photo_id": photoId}
                                          transform:^id(NSDictionary *response) {
                                              NSString *total = [response valueForKeyPath:@"photo.views"];
                                              return total;
                                          }];
    
    RACSignal *owner = [self signalFromAPIMethod:@"flickr.photos.getInfo"
                                       arguments:@{@"photo_id": photoId}
                                       transform:^id(NSDictionary *response) {
                                           NSString *total = [response valueForKeyPath:@"photo.owner.realname"];
                                           return total;
                                       }];
    
    RACSignal *photoDescription = [self signalFromAPIMethod:@"flickr.photos.getInfo"
                                       arguments:@{@"photo_id": photoId}
                                       transform:^id(NSDictionary *response) {
                                           NSString *total = [response valueForKeyPath:@"photo.description._text"];
                                           return total;
                                       }];

    return [[RACSignal combineLatest:@[favourites, comments, views, owner, photoDescription] reduce:^id(NSString *favs, NSString *coms, NSString *vws, NSString *onr, NSString *dscr){
        FlickrPhototMetadata *meta = [FlickrPhototMetadata new];
        meta.comments = [coms integerValue];
        meta.favourites = [favs integerValue];
        meta.views = [vws integerValue];
        meta.owner = onr;
        meta.photoDescription = dscr;
        return  meta;
    }] logAll];
}


@end
