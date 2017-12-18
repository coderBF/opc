//
//  main.m
//  testmain
//
//  Created by yxzc on 16/8/26.
//  Copyright © 2016年 yxzc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPNController.h"
#include <sys/types.h>
#include <sys/time.h>
//#include <sys/socket.h>
#include <string.h>
//#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <unistd.h>
#include <pthread.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#define MAXLINE 1024

#define BUF_SIZE 1024

#include "openconnect.h"

#import "openconnectinfo.h"

//#include <cstdio>

int sockfd;
struct sockaddr_in servaddr, cliaddr;
socklen_t len;


int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        while (1) {
//            if (!socketStart()) {
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    socketStart();
//                });
//                
//            }
//        }
        socketStart();
       
        
    }
    return 0;
}

int socketStart(){


    sockfd=socket(AF_INET,SOCK_STREAM,0);
    if(sockfd<0)
    {   printf("socket error\n");
        return 0;  }
//    printf("sock-ret=[%d]\n",sockfd);  //网络字节序
    servaddr.sin_family=AF_INET;
    servaddr.sin_addr.s_addr=inet_addr("127.0.0.1");
    servaddr.sin_port=htons(SERV_PORT);//.........MYPORT
    bzero(&(servaddr.sin_zero),8);
    
    NSTask *task;
    const char *bReuseaddr;
    int ret;
    size_t namelen;
    int msgsock;
    setsockopt(sockfd,SOL_SOCKET ,SO_REUSEADDR,(const  char*)&bReuseaddr,sizeof(int));
    //bind
    if((ret=bind(sockfd,(struct sockaddr *)&servaddr,sizeof(struct  sockaddr)))<0)
        ////****bind()
    {   printf("bind error\n");
        return 0;
    }
//    printf("bind-ret=[%d]\n",ret);
    ret=-9;
    if((ret=listen(sockfd,100)<0))
        ////****listen()
    {   printf("listen error\n");
        return 0;   }
//    printf("listen-ret=[%d]\n",ret);
    
    // 在socket的创建以及初始化之后，做一个while（1）的死循环进行和客户端的链接。
    namelen=sizeof(struct sockaddr_in);
    //sockaddr_in:地址信息
    if((msgsock=accept(sockfd,(struct sockaddr *)&cliaddr,&namelen))<0)
        ////****accept()
    {
        printf("accept error\n");
        return 0;
    }else{
        int sockettemp=msgsock;
        while (1) {
            char data_buf[MAXLINE];
            char ch_send_back[300];
            int n=0;
            memset(data_buf,0,MAXLINE);
            if ((n=recv(sockettemp, data_buf, MAXLINE, 0)<0)) {
                printf("recv===errer");
            }else{
                NSString *data = [NSString stringWithCString:data_buf encoding:NSUTF8StringEncoding];
                id json = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                
                if (data_buf[0]=='\0') {
                    break;
                }
                if ([json isKindOfClass:[NSArray class]]) {
//                    NSLog(@"%@",json);
                    
                    NSMutableArray *arrayJson = [NSMutableArray arrayWithArray:json];
//                       NSLog(@"%@",arrayJson[0]);
                    
                    
                    task = [[NSTask alloc]init];
                    task.launchPath = arrayJson[0];
                    
                    [arrayJson removeObjectAtIndex:0];
//                    NSLog(@"%@",arrayJson);
                    task.arguments = arrayJson;
                    [task launch];
//                       NSLog(@"%zd",task.processIdentifier);
                    
                }else if([json isKindOfClass:[NSDictionary class]]){
                    if (json[@"port"]!=nil) {
                        openconnectinfo *ocinfo = [openconnectinfo shareOpenconnectInfo];
                        NSString *str = [NSString stringWithFormat:@"https://%@:%@",json[@"url"],json[@"port"]];
                        [ocinfo openconnectinfoWithLabel:json[@"username"] url:str username:json[@"username"] password:json[@"password"] group_id:1 dtls_reconnect_timeout:(int)9999999999  reconnect_timeout:(int)9999999999 proxy:json[@"proxy"]];
                        
                        
                        if (json[@"route"]!=nil) {
                            NSString *addrouteStr = [NSString stringWithFormat:@"route -n add -host %@ $(netstat -r -n | awk '/:/ { next; } /^(default|0\.0\.0\.0)/ { print $2; }')",json[@"route"]];
                            //                                //                        @"route -n add -host 45.127.97.79 $(netstat -r -n | awk '/:/ { next; } /^(default|0\.0\.0\.0)/ { print $2; }')";
                            //
                            //
                            system([addrouteStr UTF8String]);
                            
                            [[NSUserDefaults standardUserDefaults]setObject:json[@"route"] forKey:@"route"];
                            [[NSUserDefaults standardUserDefaults]setObject:json[@"ss-tunnelID"] forKey:@"ss-tunnelID"];
                            [[NSUserDefaults standardUserDefaults]synchronize];

                        }
                        
                        [ocinfo connect];
                        ocinfo.myblock = ^(NSDictionary *dict){
                        
                            NSLog(@"====%@",dict);
                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
                            
                          NSString *sudomessage = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            
                            long a = send(sockettemp, [sudomessage UTF8String], sudomessage.length, 0);
                        };
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            while (1) {
                            if (ocinfo.issuccess == YES) {
//

                                const char * ser = [@"success" UTF8String];
                                
                                long a = send(sockettemp, ser, @"success".length, 0);
                                
                                
                                
                                
                                ocinfo.issuccess = NO;
                                break;
                            }
                            }
                        });
                    }else{
                        NSString *serverID = [VPNController createWithDict:json];
                        //                    NSLog(@"serverid =======%@",serverID);
                        const char * ser = [serverID UTF8String];
                        //                  long a =   write(sockettemp,ser, serverID.length);
                        long a = send(sockettemp, ser, serverID.length, 0);
                        //                    NSLog(@"是否发送成功%zd=====%zd",a,serverID.length);
                    }

                }else{
                     NSRange range = [data rangeOfString:@"(^(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])$)" options:NSRegularExpressionSearch];
                    if ([data rangeOfString:@"ip-"].location != NSNotFound) {
                        NSTask *task = [[NSTask alloc]init];
                        NSLog(@"%@",data);
                        task.launchPath = data;
                        [[NSUserDefaults standardUserDefaults]setObject:data forKey:@"ipdown"];
                        task.arguments = [NSMutableArray array];
                        [task launch];
                    }else if ([data rangeOfString:@"connect"].location != NSNotFound){

//                        
                    }else if ([data rangeOfString:@"cutdown"].location != NSNotFound){
                        
//                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
//                        });
                        openconnectinfo *ocinfo = [openconnectinfo shareOpenconnectInfo];
                       
                         [ocinfo disconnect];
                        
                        
                        sleep(1);
                        if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"route"] isEqualToString:@""]&&[[NSUserDefaults standardUserDefaults]objectForKey:@"route"]!=nil) {
                        NSString *addrouteStr = [NSString stringWithFormat:@"route -n delete -host %@ $(netstat -r -n | awk '/:/ { next; } /^(default|0\.0\.0\.0)/ { print $2; }')",[[NSUserDefaults standardUserDefaults]objectForKey:@"route"]];
                        system([addrouteStr UTF8String]);
                            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"route"];

                        }
                       
                                           //                        @"route -n add -host 45.127.97.79 $(netstat -r -n | awk '/:/ { next; } /^(default|0\.0\.0\.0)/ { print $2; }')";
                    
//                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                            if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"route"] isEqualToString:@""]&&![[[NSUserDefaults standardUserDefaults]objectForKey:@"route"] isEqual:nil]) {
                        
//                            }

//                        });
                        
                        
                    }else if (range.location!=NSNotFound){
                    
                        NSString *addrouteStr = [NSString stringWithFormat:@"route -n add -host %@ $(netstat -r -n | awk '/:/ { next; } /^(default|0\.0\.0\.0)/ { print $2; }')",data];
                        system([addrouteStr UTF8String]);
                        [[NSUserDefaults standardUserDefaults]setObject:data forKey:@"loginRoute"];
                    }
                    
                }
            }
        }
        
        openconnectinfo *ocinfo = [openconnectinfo shareOpenconnectInfo];
        [ocinfo disconnect];
        if (task.processIdentifier) {
            NSString *killopn = [NSString stringWithFormat:@"kill -9 %zd",task.processIdentifier+1];
            system([killopn UTF8String]);
        }
        
       
        if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"ss-tunnelID"] isEqualToString:@""]&&[[NSUserDefaults standardUserDefaults]objectForKey:@"ss-tunnelID"] !=nil) {
            NSString *killsstunnel = [NSString stringWithFormat:@"kill -9 %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"ss-tunnelID"]];
            system([killsstunnel UTF8String]);
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"ss-tunnelID"];
        }
         sleep(1);
        if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"route"] isEqualToString:@""]&&[[NSUserDefaults standardUserDefaults]objectForKey:@"route"]!=nil) {
            NSString *addrouteStr = [NSString stringWithFormat:@"route -n delete -host %@ $(netstat -r -n | awk '/:/ { next; } /^(default|0\.0\.0\.0)/ { print $2; }')",[[NSUserDefaults standardUserDefaults]objectForKey:@"route"]];
            system([addrouteStr UTF8String]);
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"route"];
        }
        sleep(1);
        if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"loginRoute"] isEqualToString:@""]&&[[NSUserDefaults standardUserDefaults]objectForKey:@"loginRoute"]!=nil) {
            NSString *addrouteStr = [NSString stringWithFormat:@"route -n delete -host %@ $(netstat -r -n | awk '/:/ { next; } /^(default|0\.0\.0\.0)/ { print $2; }')",[[NSUserDefaults standardUserDefaults]objectForKey:@"loginRoute"]];
            system([addrouteStr UTF8String]);
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"loginRoute"];
        }
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"ipdown"]!=nil) {
            NSArray *temarr =[[[NSUserDefaults standardUserDefaults]objectForKey:@"ipdown"] componentsSeparatedByString:@"ip-"];
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"ipdown"];
            NSTask *task = [[NSTask alloc]init];
            task.launchPath = [[temarr firstObject] stringByAppendingString:@"ip-down"];
            NSLog(@"%@",task.launchPath);
            task.arguments = [NSMutableArray array];
            [task launch];
        }
        
        close(sockettemp);
//        printf("SOCKET END  ===================\n");
    }
    close(sockfd);
//    printf("socket end ~~~~~~~~~~~~~\n");
    return 0;

}


