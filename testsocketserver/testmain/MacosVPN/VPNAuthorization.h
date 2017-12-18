//
//  VPNAuthorization.h
//  flyingVPN
//
//  Created by yxzc on 16/5/14.
//  Copyright © 2016年 yxzc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
@interface VPNAuthorization : NSObject


+ (instancetype)shareAuthorization;
@property (nonatomic,assign)SCPreferencesRef prefs;

- (SCPreferencesRef)creat;

@end
