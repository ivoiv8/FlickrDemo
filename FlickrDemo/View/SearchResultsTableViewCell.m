//
//  SearchResultsTableViewCell.m
//  FlickrDemo
//
//  Created by Ivaylo Ivanov on 8.07.16 г..
//  Copyright © 2016 г. Ivaylo Ivanov. All rights reserved.
//

#import "SearchResultsTableViewCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "SearchResultsItemViewModel.h"

@interface SearchResultsTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *cellContentView;

@property (weak, nonatomic) IBOutlet UIView *detailsView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageThumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *favouritesLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commentsIcon;
@property (weak, nonatomic) IBOutlet UIImageView *favouritesIcon;

@property (weak, nonatomic) IBOutlet UIView *commentView1;
@property (weak, nonatomic) IBOutlet UIView *commentView2;
@property (weak, nonatomic) IBOutlet UIView *commentView3;
@property (weak, nonatomic) IBOutlet UIImageView *avatarIcon1;
@property (weak, nonatomic) IBOutlet UIImageView *avatarIcon2;
@property (weak, nonatomic) IBOutlet UIImageView *avatarIcon3;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel1;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel2;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel3;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel1;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel2;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel3;


@end

@implementation SearchResultsTableViewCell

- (void)bindViewModel:(id)viewModel {
    SearchResultsItemViewModel *photo = viewModel;
    self.titleLabel.text = photo.title;
    self.commentsArray = photo.commentsArray;
    
    self.imageThumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.imageThumbnailView sd_setImageWithURL:photo.url];
    
    [RACObserve(photo, favouritesCount) subscribeNext:^(NSNumber *x) {
        self.favouritesLabel.text = [x stringValue];
        self.favouritesIcon.hidden = (x == nil);
    }];
    
    [RACObserve(photo, commentsCount) subscribeNext:^(NSNumber *x) {
        self.commentsLabel.text = [x stringValue];
        self.commentsIcon.hidden = (x == nil);
    }];
    
    
    [RACObserve(photo, owner) subscribeNext:^(NSString *x) {
        self.ownerLabel.text = [NSString stringWithFormat:@"By %@", x];
        self.ownerLabel.hidden = (x == nil);

    }];
    
    photo.isVisible = YES;
    [self.rac_prepareForReuseSignal subscribeNext:^(id x) {
        photo.isVisible = NO;
    }];
    
    _usernameLabel1.text = photo.commentsArray.count? @"Vadim" : nil;
    _commentLabel1.text = photo.commentsArray.count? photo.commentsArray[0] : nil;
    
    _usernameLabel2.text = (photo.commentsArray.count >1)? @"Vadim" : nil;
    _commentLabel2.text = (photo.commentsArray.count >1)? photo.commentsArray[1] : nil;
    
    
    _usernameLabel3.text = (photo.commentsArray.count >2)? @"Vadim" : nil;
    _commentLabel3.text = (photo.commentsArray.count >2)? photo.commentsArray[2] : nil;
    
    self.commentView1.hidden = (photo.commentsArray.count <1)? YES : NO;
    self.commentView2.hidden = (photo.commentsArray.count <2)? YES : NO;
    self.commentView3.hidden = (photo.commentsArray.count <3)? YES : NO;
    
    self.commentView1.hidden = (photo.commentsArray.count <1)? YES : NO;
    self.commentView1.hidden = (photo.commentsArray.count <1)? YES : NO;
    self.commentView1.hidden = (photo.commentsArray.count <1)? YES : NO;

    [self setGradient];
}

- (void)setParallax:(CGFloat)value {
    self.imageThumbnailView.transform = CGAffineTransformMakeTranslation(0, value);
}

- (void)setGradient{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.detailsView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor lightGrayColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
    [self.detailsView.layer insertSublayer:gradient atIndex:0];}

@end

