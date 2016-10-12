//
//  TutorialViewController.h
//  HarpaCrista
//
//  Created by MacAir on 3/5/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^loginCompletion)(BOOL success);

@interface TutorialViewController : UIViewController

@property (strong, nonatomic) loginCompletion completion;

@end
