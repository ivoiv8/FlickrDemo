//
//  SearchResultsTableViewCell.h
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 8.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsTableViewCell : UITableViewCell

@property (strong, nonatomic) NSArray *commentsArray;

- (void)bindViewModel:(id)viewModel;

- (void) setParallax:(CGFloat)value;

@end
