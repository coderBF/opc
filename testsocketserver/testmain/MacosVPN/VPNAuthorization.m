//
//  VPNAuthorization.m
//  flyingVPN
//
//  Created by yxzc on 16/5/14.
//  Copyright © 2016年 yxzc. All rights reserved.
//

#import "VPNAuthorization.h"

@implementation VPNAuthorization



+ (instancetype)shareAuthorization{

   static VPNAuthorization *authorization;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        authorization = [[VPNAuthorization alloc]init];
        
    });
    
    return  authorization;
}
- (SCPreferencesRef)creat{

    AuthorizationRef auth = NULL;
    
    OSStatus status;
//        AuthorizationItem	envItems[2];
//    
//        envItems[0].name = kAuthorizationEnvironmentPassword;
//        envItems[0].value = [@"nishengri" cStringUsingEncoding:NSUTF8StringEncoding];
//        envItems[0].valueLength = [@"nishengri" length];
//        envItems[0].flags = 0;
//    
//        envItems[1].name = kAuthorizationEnvironmentUsername;
//        envItems[1].value = [@"yxzc" cStringUsingEncoding:NSUTF8StringEncoding];
//        envItems[1].valueLength = [@"yxzc" length];
//        envItems[1].flags = 0;
//    
//        AuthorizationItemSet	env = { 2, envItems };
    
    status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, [self flags], &auth);
    
    if (status == errAuthorizationSuccess) {
//        NSLog(@"Successfully obtained Authorization reference");
    } else {
//            NSLog(@"Could not obtain Authorization reference");
        return NULL;
    }
//    return auth;
   SCPreferencesRef prefs = SCPreferencesCreateWithAuthorization(NULL, CFSTR("flyingVPN"), NULL, auth);
    
//    AuthorizationFree(auth, [self flags]);
    self.prefs = prefs;
    
    return self.prefs;
}

- (AuthorizationFlags) flags {
    return kAuthorizationFlagDefaults           |
    kAuthorizationFlagExtendRights       |
    kAuthorizationFlagInteractionAllowed |
    kAuthorizationFlagPreAuthorize;
}

@end
