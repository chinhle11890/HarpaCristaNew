//
//  MenuSlideBarTableViewCell.m
//  HarpaCrista
//
//  Created by Chinh Le on 6/9/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "MenuSlideBarTableViewCell.h"

@implementation MenuSlideBarTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    UIView * selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:(117.0/255.0) green:(203.0/255.0) blue:(252.0/255.0) alpha:1.0]];
    [self setSelectedBackgroundView:selectedBackgroundView];
}

@end
