//
//  ViewModelServicesImpl.h
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 8.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewModelServices.h"

@interface ViewModelServicesImpl : NSObject <ViewModelServices>

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

@end
