//
//  openconnectinfo.m
//  tesopenconnect
//
//  Created by System Administrator on 24/11/2016.
//  Copyright © 2016 yxzc. All rights reserved.
//

#import "openconnectinfo.h"
#import <string.h>
#import <sys/pipe.h>
#import "OCLogManager.h"
@implementation openconnectinfo

+ (instancetype)shareOpenconnectInfo{

    static openconnectinfo *instace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instace = [[openconnectinfo alloc]init];
    });

    return instace;
}

static void stats_vfn(void* privdata, const struct oc_stats* stats)
{
    printf("stats_vfn \n");
    openconnectinfo* vpn = (__bridge openconnectinfo *)(privdata);
    const char* cipher;
   // string dtls;
    
    cipher = openconnect_get_dtls_cipher(vpn->_vpninfo);
    if (cipher != nullptr) {
        //dtls = string(cipher);
    }
    printf("upload %llu\n",stats->tx_bytes);
    printf("download %llu\n",stats->rx_bytes);
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"upload"] = @(stats->tx_bytes);
    dict[@"download"]= @(stats->rx_bytes);
    vpn.myblock([dict copy]);
}

static int validate_peer_cert(void* privdata, const char* reason)
{
    printf("validate_peer_cert \n");
    return 0;
}
static int process_auth_form(void* privdata, struct oc_auth_form* form)
{
    printf("process_auth_form \n");
     openconnectinfo* vpn =(__bridge openconnectinfo *)(privdata);
    bool ok;
   // string text;
    
    struct oc_form_opt* opt;
    //     QStringList gitems;
    //     QStringList ditems;
    int i, idx;
    
    if (form->banner)
        printf("%s\n", form->banner);
    
    if (form->message)
        printf("%s\n", form->message);
    
    if (form->error) {
        printf("%s\n", form->error);
        return -1;
    }
    
    if (form->authgroup_opt) {
        struct oc_form_opt_select* select_opt = form->authgroup_opt;
        
     
        printf("Saving group: %s\n", select_opt->choices[vpn->_group_id]->name);
        openconnect_set_option_value(&select_opt->form, select_opt->choices[vpn->_group_id]->name);
  
    }
    
    for (opt = form->opts; opt; opt = opt->next) {
       // text.clear();
        if (opt->flags & OC_FORM_OPT_IGNORE)
            continue;
        
        if (opt->type == OC_FORM_OPT_SELECT) {

        } else if (opt->type == OC_FORM_OPT_TEXT) {
            printf("Text form: %s\n", opt->name);
            openconnect_set_option_value(opt, [vpn->_username UTF8String]);

        } else if (opt->type == OC_FORM_OPT_PASSWORD) {
            printf("Password form: %s\n",opt->name);
            openconnect_set_option_value(opt, [vpn->_password UTF8String]);

        }
    }
    
    return OC_FORM_RESULT_OK;
fail:
    return OC_FORM_RESULT_CANCELLED;
}

static void progress_vfn(void* privdata, int level, const char* fmt, ...)
{
    //printf("progress_vfn \n");
    openconnectinfo* vpn = (__bridge openconnectinfo *)(privdata);
    char buf[512];
    size_t len;
    va_list args;
    
    /* don't spam */
    if (level == PRG_TRACE)
        return;
    
    buf[0] = 0;
    va_start(args, fmt);
    vsnprintf(buf, sizeof(buf), fmt, args);
    va_end(args);
    
    len = strlen(buf);
    if (buf[len - 1] == '\n')
        buf[len - 1] = 0;
    printf("%s\n",buf);
}

- (void)openconnectinfoWithLabel:(NSString *)label url:(NSString *)url username:(NSString *)username password:(NSString *)password  group_id:(int)group_id dtls_reconnect_timeout:(int) dtls_reconnect_timeout reconnect_timeout :(int)reconnect_timeout proxy:(NSString *)proxy{
    self.label = label;
    self.url = url;
    self.username = username;
    self.password = password;
    self.group_id = group_id;
    self.dtls_reconnect_timeout = dtls_reconnect_timeout;
    self.reconnect_timeout = reconnect_timeout;
    OCLogManager *manager = [OCLogManager shareOCLogManager];
    openconnect_init_ssl();
    self.vpninfo = openconnect_vpninfo_new([label UTF8String], validate_peer_cert, nil, process_auth_form, progress_vfn, (__bridge void *)(self));
    if (self.vpninfo==nil) {
        [manager writeMssage:@"creat vpninfo error\n"];
    }
    
    if (proxy) {
        openconnect_set_http_proxy(_vpninfo, strdup([proxy UTF8String]));
           [manager writeMssage:@"use proxy link server\n"];
    }
    self.cmd_fd = openconnect_setup_cmd_pipe(self.vpninfo);
    if (self.cmd_fd == -1) {
        [manager writeMssage:@"setup_cmd_pipe error\n"];
        return;
    }
    
   
   // set_sock_block(self.cmd_fd);
    openconnect_set_stats_handler(_vpninfo, stats_vfn);
    
    int ret = openconnect_parse_url(_vpninfo, [url UTF8String]);
    
    if (ret!=0) {
        [manager writeMssage:@"url set error\n"];
        return;
    }
}

- (int) dtls_connect{

//    if (!_m_disable_udp) {
    OCLogManager *manager = [OCLogManager shareOCLogManager];
        int ret = openconnect_setup_dtls(_vpninfo,_dtls_reconnect_timeout);
        if (ret != 0) {
            printf("Error setting up DTLS");
            [manager writeMssage:@"Error setting up DTLS\n"];
            return ret;
        }
//    }
    return 0;
}
- (int)connect{
    OCLogManager *manager = [OCLogManager shareOCLogManager];
    int ret;
    //std::string cert_file, key_file;
    //std::string ca_file;
  
    ret = openconnect_obtain_cookie(_vpninfo);
    if (ret != 0) {
        printf("Authentication error; cannot obtain cookie");
        [manager writeMssage:@"Authentication error; cannot obtain cookie\n"];
        return ret;
    }
    
    ret = openconnect_make_cstp_connection(_vpninfo);
    if (ret != 0) {
        printf("Error establishing the CSTP channel");
        [manager writeMssage:@"Error establishing the CSTP channel\n"];
        return ret;
    }
    
    //     QByteArray vpncScriptFullPath;
    //     vpncScriptFullPath.append(QCoreApplication::applicationDirPath());
    //     vpncScriptFullPath.append(QDir::separator());
    //     vpncScriptFullPath.append(DEFAULT_VPNC_SCRIPT);
    
    
    if (SERV_PORT==38889) {
         ret = openconnect_setup_tun_device(_vpninfo, "/Library/LaunchAgents/arkvpnc-script", NULL);
    }else{
    
     ret = openconnect_setup_tun_device(_vpninfo, "/Library/LaunchAgents/vpnc-script", NULL);
    }
   
    if (ret != 0) {
        [manager writeMssage:@"Error setting up the TUN device\n"];
        printf("Error setting up the TUN device");
        return ret;
    }
    
    [self dtls_connect];
    
    
    self.issuccess = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (_timer==nil) {
          _timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(vpnstates) userInfo:nil repeats:YES];
        }
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
//        [timer fire];
    });
  
    
 dispatch_async(dispatch_get_global_queue(0, 0), ^{
    while (true) {
       
        int ret = openconnect_mainloop(_vpninfo,_reconnect_timeout,RECONNECT_INTERVAL_MIN);
        
        if (ret != 0) {
            printf("Disconnected \n");
             [manager writeMssage:@"Disconnected!!!\n"];
            self.isCutdown = YES;
            break;
        }
    }
     
//     if(_vpninfo != NULL){
////         undelete; vpninfo;
//         _vpninfo = NULL;
//     }
     
     
 });
    
    return 0;

}

- (void)vpnstates{
    

    char cmd = OC_CMD_STATS;
    
    if (_cmd_fd!=-1) {
    int ret = (int)write(_cmd_fd, &cmd, 1);
    if (ret<0) {
        printf("vpn stats : ipc error");
    }
    }


}
- (void)disconnect{
    OCLogManager *manager = [OCLogManager shareOCLogManager];

    char cmd = OC_CMD_CANCEL;
    if (_cmd_fd != -1) {
        write(_cmd_fd, &cmd, 1);
         [manager writeMssage:@"write OC_CMD_CANCEL success \n"];
       _cmd_fd = -1;
    }
}


@end
