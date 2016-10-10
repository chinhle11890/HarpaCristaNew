// MEMenuViewController.m
// TransitionFun
//
// Copyright (c) 2013, Michael Enriquez (http://enriquez.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MEMenuViewController.h"
#import "MenuSlideBarTableViewCell.h"
#import "UIViewController+ECSlidingViewController.h"
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"

#define kLogoutCellIndex 12
#define kFooterHeight 44.0f

static MEMenuViewController *__shared = nil;

@interface MEMenuViewController ()<UITableViewDataSource,UITableViewDelegate, MFMailComposeViewControllerDelegate> {
    __weak IBOutlet UITableView *_tableView;
    
    NSArray *_arrayMenuItems;
}

@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation MEMenuViewController

- (void)viewDidLoad {
    _arrayMenuItems = [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SlideMenuItems" ofType:@"plist"]] mutableCopy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuItemChoose:) name:@"MenuItemChoose" object:nil];
}

- (void)menuItemChoose:(NSNotification*)notification {
    if ([notification.name isEqualToString:@"MenuItemChoose"]) {
        int index = [(NSNumber*)notification.object intValue];
        switch (index) {
            case 1:
                self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"naviHinosVC"];
                [self.slidingViewController resetTopViewAnimated:YES];
                break;
            case 2:
                self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoritosNavigationController"];
                [self.slidingViewController resetTopViewAnimated:YES];
                break;
            case 5:
                self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsNavigationController"];
                [self.slidingViewController resetTopViewAnimated:YES];
                break;
            default:
                break;
        }
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 6;
    } else if (section == 1) {
        return 4;
    } else {
        return 1;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict;
    if (indexPath.section < 2) {
        dict = _arrayMenuItems[indexPath.section*6 + indexPath.row];
    } else {
        dict = _arrayMenuItems[kLogoutCellIndex];
    }
    
    static NSString *cellIdentifier = @"MenuSlideBarTableViewCell";
    MenuSlideBarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MenuSlideBarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    cell.lblTitle.text = dict[@"title"];
    cell.imvIcon.image  = [UIImage imageNamed:dict[@"icon"]];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.lblNumberOfUnSeenArticles.hidden = NO;
    } else {
        cell.lblNumberOfUnSeenArticles.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return kFooterHeight;
    }
    return 20.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (float)3/4 * screenRect.size.width, kFooterHeight)];
    //headerView.contentMode = UIViewContentModeScaleToFill;
    
    // Add the label
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (float)3/4 * screenRect.size.width, kFooterHeight)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.highlightedTextColor = [UIColor blackColor];
    
    //this is what you asked
    headerLabel.font = [UIFont systemFontOfSize:11];
    
    headerLabel.shadowColor = [UIColor clearColor];
    headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    headerLabel.numberOfLines = 0;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview: headerLabel];
    
    if (section == 2) {
        headerLabel.text = @"Harpa Cristã com Acordes © 2016";
    }
    
    return headerView;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"naviHomeVC"];
                break;
            case 1:
                self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"naviHinosVC"];
                break;
            case 2:
                self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoritosNavigationController"];
                break;
            case 3:
                self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TunerNavigationController"];
                break;
            case 4:
                self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MetronomoNavigationController"];
                break;
            case 5:
                //self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsNavigationController"];
                self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileNavigationController"];
                break;
                
            default:
                break;
        }
        [self.slidingViewController resetTopViewAnimated:YES];
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                break;
            case 1:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://harpacca.com/perguntas-e-respostas/"]];
                break;
            case 2:
                if ([MFMailComposeViewController canSendMail]) {
                    // Email Subject
                    NSString *emailTitle = @"Contact from app";
                    // Email Content
                    NSString *messageBody = @"";
                    // To address
                    NSArray *toRecipents = @[@"contact@harpacca.com"];
                    
                    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                    mc.mailComposeDelegate = self;
                    [mc setSubject:emailTitle];
                    [mc setMessageBody:messageBody isHTML:NO];
                    [mc setToRecipients:toRecipents];
                    
                    // Present mail view controller on screen
                    [self presentViewController:mc animated:YES completion:NULL];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Harpa Crista" message:@"Please setup a mail account in your phone first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                break;
            case 3:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/harpa-crista-com-acordes/id903898552?mt=8"]];
                break;
            case 4: {
                NSString *textToShare = @"Achei o melhor aplicativo evangélico! @harpacrista7\n- Android: https://play.google.com/store/apps/details?id=com.harpacrista\n- iOS: https://itunes.apple.com/us/app/harpa-crista-com-acordes/id903898552?mt=8";
                
                UISimpleTextPrintFormatter *printData = [[UISimpleTextPrintFormatter alloc]
                                                         initWithText:textToShare];
                NSArray *itemsToShare = [[NSArray alloc] initWithObjects:textToShare,printData, nil];
                
                UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
                
                // Present the controller
                [self presentViewController:controller animated:YES completion:nil];
                break;
            }
            case 5:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://harpacca.com/"]];
                break;
                
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            // Handle Logout here
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Harpa Crista"
                                                                           message:@"Are you sure want to logout?"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [((AppDelegate *)[[UIApplication sharedApplication] delegate]) logoutWithCompletion:nil];
                                                             }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:nil];
            [alert addAction:cancelAction];
            [alert addAction:OKAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
