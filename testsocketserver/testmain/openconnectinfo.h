//
//  openconnectinfo.h
//  tesopenconnect
//
//  Created by System Administrator on 24/11/2016.
//  Copyright © 2016 yxzc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "openconnect.h"
#include <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#include <string.h>
#define SERV_PORT 38889
typedef void(^myblock)(NSDictionary *dict);
@interface openconnectinfo : NSObject
+ (instancetype)shareOpenconnectInfo;

- (void)openconnectinfoWithLabel:(NSString *)label url:(NSString *)url username:(NSString *)username password:(NSString *)password  group_id:(int)group_id dtls_reconnect_timeout:(int) dtls_reconnect_timeout reconnect_timeout:(int) reconnect_timeout proxy:(NSString *)proxy;

- (int)connect;
- (void)disconnect;
@property (nonatomic,copy)myblock myblock;
@property (nonatomic,strong)NSString *label;
@property (nonatomic,strong)NSString *url;
@property (nonatomic,strong)NSString *username;
@property (nonatomic,strong)NSString *password;
@property (nonatomic,assign)int group_id;
@property (nonatomic,assign)int dtls_reconnect_timeout;
@property (nonatomic,assign)int reconnect_timeout;
@property (nonatomic,assign)struct openconnect_info *vpninfo;
@property (nonatomic,assign)int cmd_fd;
@property (nonatomic,assign)BOOL m_disable_udp;
@property (nonatomic,assign)BOOL issuccess;
@property (nonatomic,assign)BOOL isCutdown;
@property (nonatomic,strong)NSTimer *timer;

@end
