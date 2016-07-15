//
//  FlickrPhotoCD+CoreDataProperties.h
//  
//
//  Created by Ivaylo Ivanov on 13.07.16 г..
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FlickrPhotoCD.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlickrPhotoCD (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *urlPath;
@property (nullable, nonatomic, retain) NSString *comment;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *username;

@end

NS_ASSUME_NONNULL_END
