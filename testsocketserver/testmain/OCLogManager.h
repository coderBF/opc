//
//  OCLogManager.h
//  testmain
//
//  Created by yxzc on 2017/9/5.
//  Copyright © 2017年 yxzc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCLogManager : NSObject

+ (instancetype)shareOCLogManager;

- (void)writeMssage:(NSString *)mssage;

- (void)deleteFile;

@end
