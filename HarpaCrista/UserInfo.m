//
//  UserInfo.m
//
//  Created by Bao Nguyen on 9/17/16.
//  Copyright © 2016 Bao Nguyen. All rights reserved.
//

#import "UserInfo.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CDUserInfo+CoreDataClass.h"
#import "CDUserInfo+CoreDataProperties.h"
#import "Define.h"

static NSString *KEY = @"userdefault";
static NSString *USERINFO = @"userInfo";

@implementation UserInfo

static UserInfo *user = nil;

@synthesize userInfo = _userInfo;

+ (instancetype)shareInstance {
    if (!user) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSData * data = [userDefault dataForKey:KEY];
        if (data != nil) {
            user = (UserInfo *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        if (!user) {
            user = [[UserInfo alloc] init];
            [user update];
        }
        
    }
    return user;
}

/**
 *  Update
 */
- (void)update {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject: [NSKeyedArchiver archivedDataWithRootObject:[UserInfo shareInstance]] forKey:KEY];
    [userDefault synchronize];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _userInfo = [coder decodeObjectForKey:USERINFO];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if (self.userInfo) {
        [coder encodeObject:self.userInfo forKey:USERINFO];
    }
}

/**
 *  Clear info of user (use when logout, ...)
 */
- (void)clearInfo {
    UserInfo *user = [UserInfo shareInstance];
    user.userInfo = nil;
    [user update];
    [self clearUserInfo];
}

- (void)clearUserInfo {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDUserInfo"];
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        return;
    }
    for (NSManagedObject * object in objects) {
        [context deleteObject:object];
    }
}

- (void)setUserInfo:(NSDictionary *)userInfo {
    _userInfo = userInfo;
    UserInfo *user = [UserInfo shareInstance];
    [user update];
}

- (NSString *)userLogin {
    return _userInfo[kUserLogin];
}

- (NSString *)accessToken {
    return _userInfo[kAccessToken];
}


- (BOOL)isLogin {
    return self.accessToken != nil;
}

- (void)shouldPerformActionWithLogin:(dispatch_block_t)completion noLogin:(dispatch_block_t)no_login_handler {
    if (self.isLogin) {
        if (completion) {
            completion();
        }
    } else {
        if (no_login_handler) {
            no_login_handler();
        }
    }
}

@end
