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
#import "Define.h"

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
    NSString *userId = [UserInfo shareInstance].userLogin;
    if (!userId) {
        return;
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDUserInfo"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user.cdUserId == %@", userId];
    NSError *error = nil;
    NSArray *objects = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        // Show user profile
        CDUserInfo *userInfo = objects.firstObject;
        [self showUserInformation:userInfo.user];
        return;
    }
    AFHTTPSessionManager *manager = [BaseApi HTTPSessionManagerRequiredAuthorization:YES];
    SHOW_INDICATOR(self.navigationController.view);
    [manager GET:@"http://harpacca.com/api/public/api/users/get_profile" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        CommunicationHandler(task, responseObject, ^(BOOL success, id  _Nullable object) {
            if (success) {
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [self saveUserInformation:object[kUser] context:appDelegate.managedObjectContext completion:^{
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
            [formData appendPartWithFileData:data name:kAvatarUrl fileName:@"photo.png" mimeType:@"image/png"];
        }
        if (_nameLabel.text) {
            NSMutableArray *name = [NSMutableArray arrayWithArray: [_nameLabel.text componentsSeparatedByString:@" "]];
            NSString *firstName = name.firstObject;
            [formData appendPartWithFormData:[firstName dataUsingEncoding:NSUTF8StringEncoding] name:kFirstname];
            if (name.count > 0) {
                [name removeObjectAtIndex:0];
                NSString *lastName = [name componentsJoinedByString:@" "];
                [formData appendPartWithFormData:[lastName dataUsingEncoding:NSUTF8StringEncoding] name:kLastname];
            }
        }
        if (_locationLabel.text) {
            [formData appendPartWithFormData:[_locationLabel.text dataUsingEncoding:NSUTF8StringEncoding] name:kCountry];
        }
        if (_bioLabel.text) {
            [formData appendPartWithFormData:[_bioLabel.text dataUsingEncoding:NSUTF8StringEncoding] name:kCountry];
        }
        if (_emailLabel.text) {
            [formData appendPartWithFormData:[_emailLabel.text dataUsingEncoding:NSUTF8StringEncoding] name:kEmail];
        }
        if (_intrumentoLabel.text) {
            [formData appendPartWithFormData:[_intrumentoLabel.text dataUsingEncoding:NSUTF8StringEncoding] name:kFavouriteInstrument];
        }
        if (_favouriesLabel.text) {
            [formData appendPartWithFormData:[_favouriesLabel.text dataUsingEncoding:NSUTF8StringEncoding] name:kFavouriteSong];
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
    CDUserInfo *userInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CDUserInfo" inManagedObjectContext:context];
    CDUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"CDUser" inManagedObjectContext:context];
    
    user.cdAddress = userData[kAddress] == [NSNull null] ? nil : userData[kAddress];
    user.cdAvatar = userData[kAvatarUrl] == [NSNull null] ? nil : userData[kAvatarUrl];
    user.cdBio = userData[kBio] == [NSNull null] ? nil : userData[kBio];
    user.cdCountry = userData[kCountry] == [NSNull null] ? nil : userData[kCountry];
    user.cdEmail = userData[kEmail] == [NSNull null] ? nil : userData[kEmail];
    user.cdFirstName = userData[kFirstname] == [NSNull null] ? nil : userData[kFirstname];
    user.cdLastName = userData[kLastname] == [NSNull null] ? nil : userData[kLastname];
    user.cdPhone = userData[kPhone] == [NSNull null] ? nil : userData[kPhone];
    user.cdState = userData[kState] == [NSNull null] ? nil : userData[kState];
    user.cdInstrument = userData[kFavouriteInstrument] == [NSNull null] ? nil : userData[kFavouriteInstrument];
    user.cdSong = userData[kFavouriteSong] == [NSNull null] ? nil : userData[kFavouriteSong];
    user.cdSocial = userData[kSocial] == [NSNull null] ? nil : userData[kSocial];
    user.cdUserId = userData[kUserLogin] == [NSNull null] ? nil : userData[kUserLogin];
    
    userInfo.user = user;
    NSError *error = nil;
    if (![context save: &error]) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    [self showUserInformation:user];
    if (completion) {
        completion();
    }
}

- (void)showUserInformation:(CDUser *)user {
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.cdAvatar] placeholderImage:[UIImage imageNamed:@"icn_user"]];
    _nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.cdFirstName, user.cdLastName];
    _locationLabel.text = user.cdCountry;
    _bioLabel.text = user.cdBio;
    _intrumentoLabel.text = user.cdInstrument;
    _favouriesLabel.text = user.cdSong;
    _emailLabel.text = user.cdEmail;
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
