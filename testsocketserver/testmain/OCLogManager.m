//
//  OCLogManager.m
//  testmain
//
//  Created by yxzc on 2017/9/5.
//  Copyright © 2017年 yxzc. All rights reserved.
//

#import "OCLogManager.h"

@interface OCLogManager ()

@property (nonatomic,strong)NSString *filePath;
@end

@implementation OCLogManager

+ (instancetype)shareOCLogManager{

    static OCLogManager *instence;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instence = [OCLogManager new];
        instence.filePath = @"/Library/LaunchAgents/oc.log";
        NSFileManager *manager = [NSFileManager defaultManager];
        BOOL ifFileExist = [manager fileExistsAtPath:instence.filePath];
        
        if (ifFileExist) {
            NSLog(@"文件已经存在");
            if ([[manager attributesOfItemAtPath:instence.filePath error:nil]fileSize]/1024.0>1024.0) {
                [instence deleteFile];
                
            }
        }else{
           NSLog(@"文件不存在");
            [instence createfile:instence.filePath];
        }
        
    });
    return instence;
}

- (void)writeMssage:(NSString *)mssage{
    if (_filePath!=nil) {
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:_filePath];
        [file seekToEndOfFile];
        NSData *strData = [mssage dataUsingEncoding:NSUTF8StringEncoding];
        [file writeData:strData ];
    }
}
- (void)deleteFile{

    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL deleSuccess = [manager removeItemAtPath:_filePath error:nil];
    if (deleSuccess) {
        NSLog(@"删除文件成功");
        [self createfile:_filePath];
    }else{
        NSLog(@"删除文件不成功");
    }

}

- (void)createfile:(NSString *)filePath{
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL success = NO;
    success = [manager createFileAtPath:filePath contents:nil attributes:nil];
    if (!success) {
        NSLog(@"创建文件不成功");
        _filePath = nil;
        //        错误判断+++
    }else{
        NSLog(@"创建文件成功");
        _filePath = filePath;
        //            instence.filePath = testPath;
    }

}
@end
