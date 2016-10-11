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

@interface ProfileViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    __weak IBOutlet UIImageView *_avatarImageView;
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_locationLabel;
    __weak IBOutlet UILabel *_bioLabel;
    __weak IBOutlet UILabel *_intrumentoLabel;
    __weak IBOutlet UILabel *_favouriesLabel;
    __weak IBOutlet UIBarButtonItem *_editButton;
    BOOL _canEdited;
}

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    INIT_INDICATOR;
    _canEdited = YES;
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

#pragma mark - Call Webservice
- (void)getUserInformation {
    if (![UserInfo shareInstance].isLogin) {
        return;
    }
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

- (void)updateUserInformation {
    AFHTTPSessionManager *manager = [BaseApi HTTPSessionManagerRequiredAuthorization:YES];
    SHOW_INDICATOR(self.navigationController.view);
    [manager POST:@"http://harpacca.com/api/public/api/users/update_profile" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        HIDE_INDICATOR(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        HIDE_INDICATOR(YES);
    }];
}

- (void)saveUserInformation:(id)userData context:(NSManagedObjectContext *)context completion:(dispatch_block_t)completion {
    NSString *userId = userData[@"id"] == [NSNull null] ? nil : [userData[@"id"] stringValue];
    if (!userId) {
        return;
    }
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDUserInfo"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user.cdUserId == %@", userId];
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        return;
    }
    CDUserInfo *userInfo = objects.firstObject;
    CDUser *user;
    if (userInfo) {
        user = userInfo.user;
    } else {
        userInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CDUserInfo" inManagedObjectContext:context];
        user = [NSEntityDescription insertNewObjectForEntityForName:@"CDUser" inManagedObjectContext:context];
    }
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
    user.cdUserId = userId;
    
    userInfo.user = user;
    error = nil;
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

- (IBAction)didClickEditButton:(id)sender {
    UIBarButtonItem *button = sender;
    _canEdited = !_canEdited;
    _canEdited ? [button setTitle:@"Edit"] : [button setTitle:@"Save"];
    if (!_canEdited) {
        //Update profile
//        [self updateUserInformation];
    }
}

- (IBAction)chooseAvatar:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"HarpaCrista" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Take a New Photo"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                                 UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                                                                 imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                 imagePickerController.allowsEditing = YES;
                                                                 imagePickerController.delegate = self;
                                                                 [self presentViewController:imagePickerController animated:YES completion:nil];
                                                             }
                                                         }];
    [alert addAction:cameraAction];
    
    UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:@"Select From Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.allowsEditing = YES;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }];
    [alert addAction:galleryAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -  UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    if (image == nil) {
        image = [info valueForKey:UIImagePickerControllerOriginalImage];
    }
    _avatarImageView.image = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
