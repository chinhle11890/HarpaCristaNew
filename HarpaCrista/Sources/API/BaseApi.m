//
//  FavoritosViewController.h
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.

#import "BaseApi.h"
#import "LRResty.h"
#import "NSDictionary+Json.h"
#import "NSArray+Json.h"
#import "LRRestyResponse+Json.h"
#import <Foundation/Foundation.h>
#import "UserInfo.h"
#import "AppDelegate.h"
#import "Define.h"

@implementation NSDictionary (Utility)


@end


@implementation BaseApi {
    LRRestyClient *client_;
    NSString *csrf_;
}

+ (BaseApi*) client {
    static BaseApi *staticInstance = nil;
    if(!staticInstance) {
        staticInstance = [[BaseApi alloc] init];
    }
    return  staticInstance;
}

- (id) init {
    self = [super init];
    if(self) {
        client_ = [LRResty client];
        [client_ setHandlesCookiesAutomatically: YES];
        [LRResty setDebugLoggingEnabled: YES];
        __block BaseApi* this = self;
        [client_ setGlobalTimeout:60.0 handleWithBlock:^(LRRestyRequest *client) {
            [this handleRequestTimeout];
        }];
    }
    return self;
}

- (void) cancelAllRequests {
    [client_ cancelAllRequests];
}


#pragma mark - Post

- (void) postJSON: (id)object
          headers: (NSDictionary*) header
            toUri: (NSString*) uri
        onSuccess: (ResponseSuccessBlock)successBlock
          onError: (ResponseFailBlock)errorBlock {
    
    JSONObject *json;
    if([object isKindOfClass:[NSString class]]) {
        json = [[JSONObject alloc] initWithJSONString:object];
    } else if ([object isKindOfClass:[NSDictionary class]]){
        json = [[JSONObject alloc] initWithDictionary:object];
    } else if([object isKindOfClass:[NSArray class]]) {
        json = [[JSONObject alloc] initWithArray:object];
    }
    
    NSString *url = [self urlStringFromUri: uri];
    [client_ post:url
          payload:json
     //headers:nil
          headers:header
        withBlock:^(LRRestyResponse *response) {
            
            if(response.status == 200 ||            // Status OK
               response.status == 201 ||            // Status
               response.status == 202               // Status Accepted
               ) {
                id data = nil;
                data = [response asJSONObject];
                
                successBlock(data, response.headers);
            } else {
                NSError *error = nil;
                error = [self generateErrorWithCode:response.status description: response.asString];
                errorBlock(response.status, error);
            }
        }];
}

#pragma mark - Get

- (void) getJSON: (id)object
         headers: (NSDictionary*) header
           toUri: (NSString*) uri
       onSuccess: (ResponseSuccessBlock)successBlock
         onError: (ResponseFailBlock)errorBlock {
    JSONObject *json;
    if([object isKindOfClass:[NSString class]]) {
        json = [[JSONObject alloc] initWithJSONString:object];
    } else if ([object isKindOfClass:[NSDictionary class]]){
        json = [[JSONObject alloc] initWithDictionary:object];
    } else if([object isKindOfClass:[NSArray class]]) {
        json = [[JSONObject alloc] initWithArray:object];
    }

    //NSDictionary *headers = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
  
    NSString *url = [self urlStringFromUri: uri];
    
    NSLog(@"url = %@",url);

    [client_ get:url
      parameters:object
         headers:header
       withBlock:^(LRRestyResponse *response) {
           
           if(response.status == 200) {
               id data = nil;
               data = [response asJSONObject];
               successBlock(data, response.headers);
           } else {
               NSError *error = nil;
               error = [self generateErrorWithCode:response.status description: response.asString];
               NSLog(@"error = %@",error);
               errorBlock(response.status, error);
           }
       }];
}

- (NSString*) urlStringFromUri: (NSString*) uri {
    uri = [uri stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    if ([uri hasPrefix:@"http:"] || [uri hasPrefix:@"https:"] ) {
        return uri;
    } else if([uri hasPrefix:@"/"]) {
        NSString *url = [NSString stringWithFormat:@"%@%@", self.server, uri];
        return url;
    } else {
        
        NSString *url = [NSString stringWithFormat:@"%@/%@", self.server, uri];
        return url;
    }
    
}

- (NSError*) generateErrorWithCode: (NSInteger) code description: (NSString*) description {
    NSError *anError;
    // Create and return the custom domain error.
    NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : description };
    
    anError = [[NSError alloc] initWithDomain: NSUnderlyingErrorKey
                                         code: code
                                     userInfo: errorDictionary];
    return anError;
}

- (void) handleRequestTimeout {
    [self showAlertView];
}

- (void) showAlertView {
    if(!_alert){
        _alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request timeout" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    } else {
        if(!_alert.visible)
            [_alert show];
    }
}

+ (AFHTTPSessionManager *) HTTPSessionManagerRequiredAuthorization:(BOOL)authorization {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [policy setValidatesDomainName:NO];
    [policy setAllowInvalidCertificates:YES];
    manager.securityPolicy = policy;
    
    manager.requestSerializer = [[AFJSONRequestSerializer alloc] init];
    manager.responseSerializer  = [AFJSONResponseSerializer serializer];
    if (authorization && [UserInfo shareInstance].accessToken) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [UserInfo shareInstance].accessToken] forHTTPHeaderField:@"Authorization"];
    }
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",@"text/html",@"text/plain"]];
    return manager;
}

@end

void CommunicationHandler(NSURLSessionDataTask * _Nonnull task, id _Nonnull responseObject, ResponseCompletion completion) {
    NSLog(@"Response object = %@", responseObject);
    NSInteger code = [responseObject[kCode] integerValue];
    if (code == 100) {
        id object = responseObject[kData];
        if (completion) {
            completion(YES, object);
        }
    } else {
        id error = responseObject[kError];
        NSString *errorString;
        if ([error isKindOfClass:[NSString class]]) {
            errorString = error;
        } else if ([error isKindOfClass:[NSArray class]]) {
            errorString = [((NSArray *)error) componentsJoinedByString:@" "];
        }
        UIViewController *viewController = [[UIApplication sharedApplication].delegate window].rootViewController;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kAppName message:errorString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:kOk style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (completion) {
                completion(NO, error);
            }
        }];
        [alertController addAction:okAction];
        [viewController presentViewController:alertController animated:YES completion:nil];
    }
}

void CommunicationhandlerError(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    UIViewController *viewController = [[UIApplication sharedApplication].delegate window].rootViewController;
    
    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (errorData) {
        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"TserializedData -> %@",serializedData);
        NSDictionary *errorInfo = [serializedData[@"errors"] firstObject];
        NSUInteger statusCode   = [errorInfo[@"error_code"] integerValue];
        if (statusCode > 0 ) {
            NSString *message = errorInfo[kMessage];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kAppName message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:kOk style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [viewController presentViewController:alertController animated:YES completion:nil];
        }
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kAppName message:@"Please check your connection" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:kOk style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [viewController presentViewController:alertController animated:YES completion:nil];
    }
}
