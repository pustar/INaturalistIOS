//
//  PhotoScrollView.m
//  iNaturalist
//
//  Created by Alex Shepard on 9/9/15.
//  Copyright (c) 2015 iNaturalist. All rights reserved.
//

#import <FontAwesomeKit/FAKIonIcons.h>

#import "PhotoScrollView.h"
#import "ObservationPhoto.h"
#import "ImageStore.h"

@interface PhotoScrollView () {
    NSArray *_photos;
}
@property UIScrollView *scrollView;

@end

@implementation PhotoScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:self.scrollView];
    }
    
    return self;
}

#pragma mark - ScrollView configuration

- (void)configureScrollView {
    self.scrollView.frame = self.bounds;
    
    NSInteger numCells = self.photos.count + 1;

    // each photo 100 px wide?
    CGFloat width = numCells * 90;
    CGFloat height = self.bounds.size.height;
    self.scrollView.contentSize = CGSizeMake(width, height);
    
    NSArray *subviews = self.scrollView.subviews;
    for (UIView *view in subviews) {
        [view removeFromSuperview];
    }
    
    // 100 - 20 = 80
    // 80 - 20 = 60
    
    // add new photo button
    self.addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.addButton.frame = CGRectMake(5, 5, 70, self.bounds.size.height - 30);
    self.addButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.addButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.addButton.layer.borderWidth = 1.0f;
    self.addButton.tintColor = [UIColor grayColor];
    [self.addButton addTarget:self action:@selector(addPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    FAKIcon *plus = [FAKIonIcons iosPlusEmptyIconWithSize:25];
    [self.addButton setAttributedTitle:plus.attributedString forState:UIControlStateNormal];
    
    [self.scrollView addSubview:self.addButton];
    
    for (int i = 1; i < numCells; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * 80, 0, 80, self.bounds.size.height)];
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 70, self.bounds.size.height - 30)];
        iv.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = YES;
        ObservationPhoto *obsPhoto = (ObservationPhoto *)self.photos[i-1];
        iv.image = [[ImageStore sharedImageStore] find:obsPhoto.photoKey forSize:ImageStoreSmallSize];
        [view addSubview:iv];
        
        [self.scrollView addSubview:view];
        
        UIButton *delete = [UIButton buttonWithType:UIButtonTypeSystem];
        delete.tag = i;
        [delete addTarget:self action:@selector(deletePressed:) forControlEvents:UIControlEventTouchUpInside];
        delete.frame = CGRectMake(i * 80 + 60 - 5, 5, 20, 20);
        [delete setTitle:@"X" forState:UIControlStateNormal];
        delete.tintColor = [UIColor blackColor];
        delete.backgroundColor = [UIColor grayColor];
        [self.scrollView addSubview:delete];
        
        if (i == 1) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5 + 70, 70, 20)];
            label.text = @"Default";
            label.font = [UIFont systemFontOfSize:11.0f];
            label.textColor = [UIColor grayColor];
            [view addSubview:label];
        } else {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5, 5 + 70, 70, 20)];
            [button setTitle:@"Set Default" forState:UIControlStateNormal];
            button.backgroundColor = [UIColor orangeColor];
            button.tintColor = [UIColor grayColor];
            button.titleLabel.font = [UIFont systemFontOfSize:11.0f];
            button.tag = i;
            [button addTarget:self action:@selector(setDefault:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
        }
    }
}

#pragma mark - UIButton targets
- (void)deletePressed:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deletePressedForIndex:)]) {
        [self.delegate deletePressedForIndex:button.tag];
    }
}

- (void)addPressed:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addPressed)]) {
        [self.delegate addPressed];
    }
}

- (void)setDefault:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(setDefaultPressedForIndex:)]) {
        [self.delegate setDefaultPressedForIndex:button.tag];
    }
}


#pragma mark - Setter/Getter

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    
    [self configureScrollView];
}

- (NSArray *)photos {
    return _photos;
}

@end
