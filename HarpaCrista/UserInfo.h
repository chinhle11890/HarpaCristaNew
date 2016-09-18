//
//  UserInfo.b
//
//  Created by Bao Nguyen on 9/17/16.
//  Copyright © 2016 Bao Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (strong, nonatomic, readonly) NSString *email;
@property (assign, nonatomic, readonly) BOOL isLogin;
// save infomation of user login
@property (strong, nonatomic, setter=setUserInfo:) NSDictionary *userInfo;

+ (instancetype)shareInstance;

/**
 *  Do something when user login
 *
 *  @param completion   : action
 *  @param update       : action
 */
- (void)shouldPerformActionWithLogin:(dispatch_block_t)completion noLogin:(dispatch_block_t)no_login_handler;

- (void)update;

- (void)clearInfo;

@end
