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
    __weak IBOutlet UILabel *_emailLabel;
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

#pragma mark - Call Webservice
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

- (void)updateUserInformation {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    if ([UserInfo shareInstance].accessToken) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [UserInfo shareInstance].accessToken] forHTTPHeaderField:@"Authorization"];
    }
    SHOW_INDICATOR(self.navigationController.view);
    [manager POST:@"http://harpacca.com/api/public/api/users/update_profile" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        UIImage *image = _avatarImageView.image;
        if (image) {
            CGFloat maxSize = MAX(image.size.width, image.size.height);
            NSData *data;
            if (maxSize > 5*2014) {
                data = UIImageJPEGRepresentation(image, 5*2014/maxSize);
            } else {
                data = UIImagePNGRepresentation(image);
            }
            [formData appendPartWithFileData:data name:@"avatar_url" fileName:@"photo.png" mimeType:@"image/png"];
        }
        if (_nameLabel.text) {
            NSMutableArray *name = [NSMutableArray arrayWithArray: [_nameLabel.text componentsSeparatedByString:@" "]];
            NSString *firstName = name.firstObject;
            [formData appendPartWithFormData:[firstName dataUsingEncoding:NSUTF8StringEncoding] name:@"first_name"];
            if (name.count > 0) {
                [name removeObjectAtIndex:0];
                NSString *lastName = [name componentsJoinedByString:@" "];
                [formData appendPartWithFormData:[lastName dataUsingEncoding:NSUTF8StringEncoding] name:@"last_name"];
            }
        }
        if (_locationLabel.text) {
            [formData appendPartWithFormData:[_locationLabel.text dataUsingEncoding:NSUTF8StringEncoding] name:@"country"];
        }
        if (_bioLabel.text) {
            [formData appendPartWithFormData:[_bioLabel.text dataUsingEncoding:NSUTF8StringEncoding] name:@"bio"];
        }
        if (_emailLabel.text) {
            [formData appendPartWithFormData:[_emailLabel.text dataUsingEncoding:NSUTF8StringEncoding] name:@"email"];
        }
        if (_intrumentoLabel.text) {
            [formData appendPartWithFormData:[_intrumentoLabel.text dataUsingEncoding:NSUTF8StringEncoding] name:@"favorite_instrument"];
        }
        if (_favouriesLabel.text) {
            [formData appendPartWithFormData:[_favouriesLabel.text dataUsingEncoding:NSUTF8StringEncoding] name:@"favorite_song"];
        }
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        CommunicationHandler(task, responseObject, ^(BOOL success, id  _Nullable object) {
            if (success) {
                
            }
        });
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
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.cdAvatar] placeholderImage:[UIImage imageNamed:@"icn_user"]];
    _nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.cdFirstName, user.cdLastName];
    _locationLabel.text = user.cdCountry;
    _bioLabel.text = user.cdBio;
    _intrumentoLabel.text = user.cdInstrument;
    _favouriesLabel.text = user.cdSong;
    _emailLabel.text = user.cdEmail;
    if (completion) {
        completion();
    }
}

- (IBAction)didClickEditButton:(id)sender {
    [self updateUserInformation];
}

- (IBAction)chooseAvatar:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"HarpaCrista" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Take a New Photo"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                                 UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                                 picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                 picker.allowsEditing = YES;
                                                                 picker.delegate = self;
                                                                 [self presentViewController:picker animated:YES completion:nil];
                                                             }
                                                         }];
    [alert addAction:cameraAction];
    
    UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:@"Select From Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark edit profile
- (void)showAlert:(NSString *)inputString completion:(void (^)(id data))completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Harpa Cristã" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = [alert.textFields firstObject];
        if (completion && textField.text) {
            completion(textField.text);
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Input text here";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        if (inputString) {
            textField.text = inputString;
        }
    }];
    [alert addAction:cancelAction];
    [alert addAction:saveAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)didClickName:(UITapGestureRecognizer *)sender {
    [self showAlert:[_nameLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] completion:^(id data) {
        if (data) {
            _nameLabel.text = data;
        }
    }];
}

- (IBAction)didClickLocation:(UITapGestureRecognizer *)sender {
    [self showAlert:[_locationLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] completion:^(id data) {
        if (data) {
            _locationLabel.text = data;
        }
    }];
}

- (IBAction)didClickBio:(UITapGestureRecognizer *)sender {
    [self showAlert:[_bioLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] completion:^(id data) {
        if (data) {
            _bioLabel.text = data;
        }
    }];
}

- (IBAction)didClickInstrument:(UITapGestureRecognizer *)sender {
    [self showAlert:[_intrumentoLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] completion:^(id data) {
        if (data) {
            _intrumentoLabel.text = data;
        }
    }];
}

- (IBAction)didClickFavouries:(UITapGestureRecognizer *)sender {
    [self showAlert:[_favouriesLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] completion:^(id data) {
        if (data) {
            _favouriesLabel.text = data;
        }
    }];
}

- (IBAction)didClickEmail:(UITapGestureRecognizer *)sender {
    [self showAlert:[_emailLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] completion:^(id data) {
        if (data) {
            _emailLabel.text = data;
        }
    }];
}

@end
