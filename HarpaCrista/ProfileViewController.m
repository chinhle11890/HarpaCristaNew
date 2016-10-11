//
//  ProfileViewController.m
//  HarpaCrista
//
//  Created by Nguyen Bao on 10/10/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "ProfileViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "UserInfo.h"
#import "BaseApi.h"
#import "CDUserInfo+CoreDataClass.h"
#import "CDUser+CoreDataProperties.h"
#import "AppDelegate.h"

@interface ProfileViewController () {
    
    __weak IBOutlet UIImageView *_avatarImageView;
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_locationLabel;
    __weak IBOutlet UILabel *_bioLabel;
    __weak IBOutlet UILabel *_intrumentoLabel;
    __weak IBOutlet UILabel *_favouriesLabel;
}

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    INIT_INDICATOR;
    [self getUserInformation];
}

- (IBAction)revealMenu:(id)sender {
    ECSlidingViewController *slidingViewController = self.slidingViewController;
    if (slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [slidingViewController resetTopViewAnimated:YES];
    } else {
        [slidingViewController anchorTopViewToRightAnimated:YES];
    }
}

- (void)getUserInformation {
    AFHTTPSessionManager *manager = [BaseApi HTTPSessionManagerRequiredAuthorization:YES];
    SHOW_INDICATOR(self.navigationController.view);
    [manager GET:@"http://harpacca.com/api/public/api/users/get_profile" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        CommunicationHandler(task, responseObject, ^(BOOL success, id  _Nullable object) {
            if (success) {
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [self saveUserInformation:object[@"user"] context:appDelegate.managedObjectContext completion:^{
                    HIDE_INDICATOR(YES);
                }];
            } else {
                HIDE_INDICATOR(YES);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        HIDE_INDICATOR(YES);
    }];
}

- (void)saveUserInformation:(id)userData context:(NSManagedObjectContext *)context completion:(dispatch_block_t)completion {
    CDUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"CDUser" inManagedObjectContext:context];
    
    user.cdAddress = userData[@"address"] == [NSNull null] ? nil : userData[@"address"];
    user.cdAvatar = userData[@"avatar_url"] == [NSNull null] ? nil : userData[@"avatar_url"];
    user.cdBio = userData[@"bio"] == [NSNull null] ? nil : userData[@"bio"];
    user.cdCountry = userData[@"country"] == [NSNull null] ? nil : userData[@"country"];
    user.cdEmail = userData[@"email"] == [NSNull null] ? nil : userData[@"email"];
    user.cdFirstName = userData[@"first_name"] == [NSNull null] ? nil : userData[@"first_name"];
    user.cdLastName = userData[@"last_name"] == [NSNull null] ? nil : userData[@"last_name"];
    user.cdPhone = userData[@"phone"] == [NSNull null] ? nil : userData[@"phone"];
    user.cdState = userData[@"state"] == [NSNull null] ? nil : userData[@"state"];
    user.cdInstrument = userData[@"favorite_instrument"] == [NSNull null] ? nil : userData[@"favorite_instrument"];
    user.cdSong = userData[@"favorite_song"] == [NSNull null] ? nil : userData[@"favorite_song"];
    user.cdSocial = userData[@"social"] == [NSNull null] ? nil : userData[@"social"];
    CDUserInfo *userInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CDUserInfo" inManagedObjectContext:context];
    userInfo.user = user;
    NSError *error = nil;
    if (![context save: &error]) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.cdAvatar]];
    _nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.cdFirstName, user.cdLastName];
    _locationLabel.text = user.cdCountry;
    _bioLabel.text = user.cdBio;
    _intrumentoLabel.text = user.cdInstrument;
    _favouriesLabel.text = user.cdSong;
    if (completion) {
        completion();
    }
}

@end
