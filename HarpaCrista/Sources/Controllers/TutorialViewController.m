//
//  TutorialViewController.m
//  HarpaCrista
//
//  Created by MacAir on 3/5/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "TutorialViewController.h"
#import "PageItemViewController.h"
#import "CDSong+CoreDataClass.h"
#import "BaseApi.h"
#import "ECSlidingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "FBSDKLoginKit/FBSDKLoginKit.h"
#import <Google/SignIn.h>
#import "UserInfo.h"
#import "AppDelegate.h"
#import "CDUserInfo+CoreDataClass.h"
#import "CDUser+CoreDataProperties.h"
#import "AFNetworking/AFNetworking.h"
#import "Define.h"

@interface TutorialViewController () <UIPageViewControllerDataSource,UITextFieldDelegate, GIDSignInDelegate, GIDSignInUIDelegate> {
    __weak IBOutlet UIPageControl *_pageControl;
    NSArray *_contentTitle;
    NSArray *_contentDescription;
    UIPageViewController *_pageViewController;
    
    __weak IBOutlet UIView *_viewPageController;
    __weak IBOutlet UIView *_containerView;
    __weak IBOutlet NSLayoutConstraint *_yOfContainViewConstraint;
    __weak IBOutlet UIView *_videoView;
    AVPlayer *_moviePlayer;
    
    __weak IBOutlet UITextField *_emailTextField;
    __weak IBOutlet UIButton *_skipButton;
    UITapGestureRecognizer *_tapGestureRecognizer;
    GIDSignInButton *_googleSignInButton;
    
}
@end

@implementation TutorialViewController

#pragma mark -
#pragma mark View Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
    
    INIT_INDICATOR;
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    // Add tapGestureRecognizer for view to hide the keyboard
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                             initWithTarget:self
                             action:@selector(dismissKeyboard)];
    
    [self createPageViewController];
    
    //Create a standardUserDefaults variable
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *isLoadTutorial = [standardUserDefaults objectForKey:keyLoadTutorial];
    if (![isLoadTutorial boolValue]) {
        // Init data
        [self initData];
    }
    [self configureGoogleSignIn];
    
}

- (void)configureGoogleSignIn {
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    
    _googleSignInButton = [[GIDSignInButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _googleSignInButton.center = self.view.center;
    _googleSignInButton.hidden = YES;
}

- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || (self.navigationController != nil && self.navigationController.presentingViewController.presentedViewController == self.navigationController)
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkAndPlayVideo) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //Play the video
    [self playVideo];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self stopVideo];
}

#pragma mark -
- (void)checkAndPlayVideo {
    if (_moviePlayer && _moviePlayer.rate != 0.0f) {
        [_moviePlayer play];
    }
}

#pragma mark - Play/stop video
- (void)playVideo {
    [self stopVideo];
    
    NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Introduction" ofType:@"mp4"]];
    AVAsset *avAsset = [AVAsset assetWithURL:movieURL];
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc] initWithAsset:avAsset];
    // create an AVPlayer
    _moviePlayer = [[AVPlayer alloc] initWithPlayerItem:avPlayerItem];
    [_moviePlayer play];
    AVPlayerLayer *avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_moviePlayer];
    [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [avPlayerLayer setFrame:self.view.bounds];
    [_videoView.layer addSublayer:avPlayerLayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[_moviePlayer currentItem]];
}

- (void)stopVideo {
    if (_moviePlayer) {
        [_moviePlayer pause];
        _moviePlayer = nil;
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    [playerItem seekToTime:kCMTimeZero];
    
    [_moviePlayer play];
}

#pragma mark - Init the page controller
- (void) createPageViewController {
    _contentTitle = @[@"Bem-Vindo",
                      @"Aprenda",
                      @"Adore",
                      @"Melhore"];
    _contentDescription = @[@"Vamos adorar a Deus melhor, juntos.",
                            @"Escute todos os hinos da harpa, use nosso metrônomo e afinador enquanto vocé toca.",
                            @"Use o app offline. Pra tocar na igreja, ensaiar ou fazer seu devocional.",
                            @"Veja recursos, artigos, livros digitais e muito mais em nosso site harpacca.com."];
    
    UIPageViewController *pageController = [self.storyboard instantiateViewControllerWithIdentifier: @"PageController"];
    pageController.dataSource = self;
    if([_contentTitle count]) {
        NSArray *startingViewControllers = @[[self itemControllerForIndex: 0]];
        [pageController setViewControllers: startingViewControllers
                                 direction: UIPageViewControllerNavigationDirectionForward
                                  animated: NO
                                completion: nil];
    }
    _pageViewController = pageController;
    [_pageViewController.view setFrame:_viewPageController.bounds];
    _pageViewController.view.backgroundColor = [UIColor clearColor];
    [self addChildViewController:_pageViewController];
    [_viewPageController addSubview:_pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];
    [self.view bringSubviewToFront:_pageControl];
}

#pragma mark - Init data
- (void)initData {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[BaseApi client] getJSON:nil headers:nil toUri:@"http://harpacca.com/mobile_get_songs.php" onSuccess:^(id data, id header) {
        NSDictionary *dictData = (NSDictionary *)data;
        if (dictData) {
            NSArray *arrayData = dictData[@"data"];
            for (NSDictionary *dictItem in arrayData) {
                NSString *title = dictItem[@"post_title"];
                NSArray *arrayString = [title componentsSeparatedByString:@" - "];
                NSString *songID = arrayString[0];
                NSString *songTitle = arrayString[1];
                NSString *songChord = dictItem[@"post_content"];
                NSString *songLink = dictItem[@"audio_url"];
                
                CDSong *song = [CDSong getOrCreateSongWithId:[songID intValue]];
                song.cdTitle = songTitle;
                song.cdChord = songChord;
                song.cdSongLink = songLink;
                [CDSong saveContext];
            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:[NSNumber numberWithBool:YES] forKey:keyLoadTutorial];
        [userDefault synchronize];
        
    }onError:^(NSInteger code, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
    // Set today to be the initial value for last_update_time
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *stringCurrentDate = [dateFormatter stringFromDate:[NSDate date]];
    [standardUserDefaults setObject:stringCurrentDate forKey:@"last_update_time"];
    [standardUserDefaults synchronize];
}

#pragma mark - Actions
- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    _yOfContainViewConstraint.constant -= keyboardSize.height;
    [UIView animateWithDuration:0.3 animations:^{
        [_containerView layoutIfNeeded];
    }];
    [self.view addGestureRecognizer:_tapGestureRecognizer];
    [_containerView addGestureRecognizer:_tapGestureRecognizer];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    _yOfContainViewConstraint.constant += keyboardSize.height;
    [UIView animateWithDuration:0.3 animations:^{
        [_containerView layoutIfNeeded];
    }];
    [self.view removeGestureRecognizer:_tapGestureRecognizer];
    [_containerView removeGestureRecognizer:_tapGestureRecognizer];
}

- (void)dismissKeyboard {
    [_emailTextField resignFirstResponder];
}

#pragma mark - Submit Email Action

- (void)submitEmailAction {
    if ([self validateEmailWithString:_emailTextField.text]) {
        NSDictionary *object = @{@"email":_emailTextField.text};
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[BaseApi client] postJSON:object headers:nil toUri:@"http://harpacca.com/mobile_submit_email.php" onSuccess:^(id data, id header) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            // Post email successfully. Continue!
            //
//            [self goToMainView];
        }onError:^(NSInteger code, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"Failed with error: %@", error.description);
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Harpa Crista" message:@"This email is invalid. Please check it again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)submitEmailAction:(NSString *)email {
    if ([self validateEmailWithString:email]) {
        NSDictionary *object = @{
                                 @"email":email
                                 };
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[BaseApi client] postJSON:object headers:nil toUri:@"http://harpacca.com/mobile_submit_email.php" onSuccess:^(id data, id header) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            // Post email successfully. Continue!
            //
            NSLog(@"data = %@", data);
            [UserInfo shareInstance].userInfo = object;
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate loginWithCompletion:nil];
//            [self goToMainView];
        }onError:^(NSInteger code, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"Failed with error: %@", error.description);
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Harpa Crista" message:@"This email is invalid. Please check it again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)skipAction:(id)sender {
    if ([self isModal]) {
        [self dismissViewControllerAnimated:YES completion:^{
            if (_completion) {
                _completion(NO);
            }
        }];
    } else {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate loginWithCompletion:nil];
    }
}

- (BOOL)validateEmailWithString:(NSString*)checkString {
    BOOL stricterFilter = NO;
    // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self submitEmailAction];
    
    return YES;
}

#pragma mark -
#pragma mark UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    PageItemViewController *itemController = (PageItemViewController *) viewController;
    _pageControl.currentPage = itemController.itemIndex;
    if (itemController.itemIndex > 0) {
        return [self itemControllerForIndex: itemController.itemIndex - 1];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    PageItemViewController *itemController = (PageItemViewController *) viewController;
    _pageControl.currentPage = itemController.itemIndex;
    if (itemController.itemIndex < [_contentTitle count] - 1) {
        return [self itemControllerForIndex: itemController.itemIndex + 1];
    }
    return nil;
}

- (PageItemViewController *)itemControllerForIndex:(NSUInteger)itemIndex {
    if (itemIndex < [_contentTitle count]) {
        PageItemViewController *pageItemController = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemController"];
        pageItemController.itemIndex = itemIndex;
        pageItemController.titleString = _contentTitle[itemIndex];
        pageItemController.descriptionString = _contentDescription[itemIndex];
        return pageItemController;
    }
    return nil;
}

#pragma mark -
#pragma mark Page Indicator

- (NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    _pageControl.numberOfPages = _contentTitle.count;
    return 0;
}

- (NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

#pragma mark - facebook login
- (IBAction)didClickLoginFBButton:(id)sender {
    [self loginFacebook];
}

- (void)loginFacebook {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    if ([FBSDKAccessToken currentAccessToken]) {
        [login logOut];
        [FBSDKAccessToken setCurrentAccessToken:nil];
    }
    [login logInWithReadPermissions:@[@"public_profile", @"email"]
                 fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                if (error) {
                                    NSLog(@"error login facebook: %@", error);
                                } else if (result.isCancelled) {
                                    NSLog(@"login facebook cancelled: %d", result.isCancelled);
                                    return;
                                } else if ([result.grantedPermissions containsObject:@"email"]) {
                                    NSString *fbToken = [FBSDKAccessToken currentAccessToken].tokenString;
                                    [self loginWithService:kFacebook token:fbToken];
                                }
                            }];
}

#pragma mark - google signin
- (IBAction)didClickGoogleSignIn:(id)sender {
    [_googleSignInButton sendActionsForControlEvents:UIControlEventAllEvents];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error) {
        NSLog(@"error when sign in google: %@", error);
        return;
    }
    [self loginWithService:kGoogle token:user.authentication.idToken];
}

- (void)loginWithService:(NSString *)type token:(NSString *)token {
    NSDictionary *dictionary = @{
                                 kSocial: type,
                                 kOs: @"ios",
                                 kDeviceToken: [NSUUID UUID].UUIDString
                                 };
    NSMutableDictionary *params =[[NSMutableDictionary alloc] initWithDictionary:dictionary];
    if ([type isEqualToString:kGoogle]) {
        params[kGoogleToken] = token;
    } else {
        params[kFacebookToken] = token;
    }
  
    NSLog(@"login with params = %@", params);
    AFHTTPSessionManager *manager = [BaseApi HTTPSessionManagerRequiredAuthorization:NO];
    SHOW_INDICATOR(self.view);
    [manager POST:@"http://harpacca.com/api/public/api/users/social"
       parameters:params
         progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             CommunicationHandler(task, responseObject, ^(BOOL success, id  _Nullable object) {
                 if (success) {
                     // Login success
                     NSString *accessToken = object[@"access_token"];
                     if (accessToken) {
                         AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                         id userData = object[kUser];
                         if (userData) {
                             NSString *userLogin = userData[kUserLogin] == [NSNull null] ? @"" : userData[kUserLogin];
                             [UserInfo shareInstance].userInfo = @{
                                                                   kAccessToken: accessToken,
                                                                   kUserLogin : userLogin
                                                                   };
                             [self saveUserInformation:object[kUser] context:appDelegate.managedObjectContext];
                         }
                         if ([self isModal]) {
                             [self dismissViewControllerAnimated:YES completion:^{
                                 if (_completion) {
                                     _completion(YES);
                                 }
                             }];
                         } else {
                             [appDelegate loginWithCompletion:nil];
                         }
                     }
                 } else {
                     
                 }
                 HIDE_INDICATOR(YES);
             });
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"error: %@", error);
             CommunicationhandlerError(task, error);
             HIDE_INDICATOR(YES);
         }];
}

- (void)saveUserInformation:(id)userData context:(NSManagedObjectContext *)context {
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
}

@end
