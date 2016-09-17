//
//  PageItemViewController.m
//  HarpaCrista
//
//  Created by MacAir on 3/5/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "PageItemViewController.h"

@interface PageItemViewController() {
    __weak IBOutlet UILabel *_lblTitle;
    __weak IBOutlet UILabel *_lblDescription;
}

@end

@implementation PageItemViewController

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    _lblTitle.text = _titleString;
    _lblDescription.text = _descriptionString;
}

#pragma mark -
#pragma mark Content

- (void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
    _lblTitle.text = _titleString;
}

- (void)setDescriptionString:(NSString *)descriptionString {
    _descriptionString = descriptionString;
    _lblDescription.text = descriptionString;
}

@end
