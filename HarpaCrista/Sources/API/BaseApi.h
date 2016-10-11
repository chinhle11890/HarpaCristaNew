//
//  FavoritosViewController.h
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.

#import <Foundation/Foundation.h>
#import "JSONObject.h"
#import "Constants.h"
#import "HTProgressHUD.h"
#import <objc/objc.h>
#import <objc/runtime.h>
#import "AFNetworking/AFNetworking.h"
#import <HTProgressHUD/HTProgressHUD.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDWebImageOperation.h>
#import <SDWebImage/SDWebImageDecoder.h>
#import <SDWebImage/SDWebImagePrefetcher.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/SDWebImageDownloaderOperation.h>
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/UIImage+MultiFormat.h>
#import <SDWebImage/UIButton+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIImage+GIF.h>

typedef void (^ResponseCompletion)(BOOL success, id _Nullable object);
typedef void (^ResponseSuccessBlock)(id data, id header);
typedef void (^ResponseSuccessBlockIndex)(id data, id header, int index);
typedef void (^ResponseFailBlock)(NSInteger code, NSError * error);

@interface NSDictionary (Utility)

@end

#import <UIKit/UIKit.h>

@interface BaseApi : NSObject
@property (nonatomic, copy) NSString *server;
@property (nonatomic, copy) NSString *csrf;

@property (nonatomic) NSString *apiKey;
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, assign) int index_;

+ (BaseApi*) client;

- (NSString*) urlStringFromUri: (NSString*) uri;

- (void) postJSON: (id)object
          headers: (NSDictionary*) header
            toUri: (NSString*) uri
        onSuccess: (ResponseSuccessBlock) success
          onError: (ResponseFailBlock) error;

- (void) getJSON: (id)object
         headers: (NSDictionary*) header
           toUri: (NSString*) uri
       onSuccess: (ResponseSuccessBlock) success
         onError: (ResponseFailBlock) error;


- (void) cancelAllRequests;

+ (AFHTTPSessionManager *) HTTPSessionManagerRequiredAuthorization:(BOOL)authorization;

@end

void CommunicationHandler(NSURLSessionDataTask * _Nonnull task, id _Nonnull responseObject, ResponseCompletion completion);

//define the HTProgressHUD

#define GET_INDICATOR (HTProgressHUD *)objc_getAssociatedObject(self, (__bridge const void *)([self class]))
#define INIT_INDICATOR objc_setAssociatedObject(self, (__bridge const void *)([self class]), [[HTProgressHUD alloc] init], OBJC_ASSOCIATION_RETAIN_NONATOMIC)
#define SHOW_INDICATOR(sview) [GET_INDICATOR showInView:sview animated:YES]
#define HIDE_INDICATOR(animated) [GET_INDICATOR hideWithAnimation:animated]
