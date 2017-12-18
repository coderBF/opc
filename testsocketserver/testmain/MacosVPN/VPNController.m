#import <SystemConfiguration/SystemConfiguration.h>

// Local dependencies
#import "VPNAuthorizations.h"
#import "VPNController.h"
#import "VPNKeychain.h"
#import "VPNServiceConfig.h"
#import "AHKeychain.h"
//#import "BFServers.h"
//#import "STPrivilegedTask.h"
#import "VPNAuthorization.h"
typedef struct{
    
    const char *magic;
    BOOL forcePrintStatus;
    int  lastMinorStatus;
    
} CallbackParams;
static int const VPNServiceL2TPOverIPSec = 1;
static int const VPNServiceCiscoIPSec = 2;
static int const VPNServicePPTP = 3;

static CallbackParams params;
static NSMutableArray *thearguments;
static NSString *serverID;

@implementation VPNController

/** TODO   Product Name **/
const CFStringRef productName = CFSTR("FlyVpn");



void MyNetworkConnectionCallBack(SCNetworkConnectionRef connection, SCNetworkConnectionStatus status, void *info)
{
//    NSLog(@"test callback %d", status);
    
    
//    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%zd",status],@"textOne", nil];
////    //创建通知
////    NSNotification *notification =[NSNotification notificationWithName:@"tongzhi" object:nil userInfo:dict];
////    //通过通知中心发送通知
////    [[NSNotificationCenter defaultCenter] postNotification:notification];
//    
//    NSString *observedObject = @"com.chinapyg.notification";
//    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
//    [center postNotificationName:@"tongzhiclient" object:observedObject userInfo:dict deliverImmediately:YES];
//    NSLog(@"---------------------------------发送了通知");
    
    if (info == NULL) {
        NSLog(@"info is null");
        return;
    }
    
    //SCNetworkConnectionContext *context = (SCNetworkConnectionContext *)info;
    CallbackParams   *params = (CallbackParams *)(info);
    
    if (status == kSCNetworkConnectionConnected) {
        
        params->lastMinorStatus = kSCNetworkConnectionPPPConnected;
        
    }
    return;
}

 /* This method is responsible for obtaining authorization in order to perform
    privileged system modifications. It is mandatory for creating network interfaces. */
+ (NSString *) createWithDict:(NSDictionary *)dict{
    /* Obtaining permission to modify network settings */
    //  AuthorizationRef auth = NULL;
    
    //  auth = [VPNAuthorizations create];
    //  if (auth == NULL)
    //  {
    ////	  NSLog(@"obtain Authorization reference failed");
    ////	  return 30;
    //  }
    
    SCPreferencesRef prefs;
    if (![VPNAuthorization shareAuthorization].prefs) {
        prefs = [[VPNAuthorization shareAuthorization]creat];
    }else{
        prefs =[VPNAuthorization shareAuthorization].prefs;
    }
    
    //    SCPreferencesCreateWithAuthorization(NULL, CFSTR("flyingVPN"), NULL, auth);
    //SCPreferencesRef prefs = SCPreferencesCreate(NULL, CFSTR("myvpn.com"), NULL);
    
    /* Making sure other process cannot make configuration modifications
     by obtaining a system-wide lock over the system preferences. */
//    if (SCPreferencesLock(prefs, TRUE)) {
//        //    NSLog(@"Gained superhuman rights.");
//    } else {
//        //    NSLog(@"Sorry, without superuser privileges I won't be able to add any VPN interfaces.");
//        //    return 31;
//    }
    
    // If everything will work out fine, we will return exit code 0
    int exitCode = 0;
    
    /** TODO **/
    
    //    for (int i= 0; i< servers.count; i++) {
    //        BFServers *server = servers[i];
    //        [self removeService:(__bridge CFStringRef)(server.home) usingPreferencesRef:prefs];
    //        [self removeService:(__bridge CFStringRef)([NSString stringWithFormat:@"%@ 2",server.home]) usingPreferencesRef:prefs];
    //    }
    [self removeService:(__bridge CFStringRef)(@"feixiang") usingPreferencesRef:prefs];
    VPNServiceConfig *config = [VPNServiceConfig new];
    config.type = [dict[@"protocol"] integerValue];
    config.name = @"feixiang";
            config.username = dict[@"userName"];
            config.password = dict[@"password"];
//    config.username = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
//    config.password = [[NSUserDefaults standardUserDefaults]objectForKey:@"userPwd"];
    //        config.endpoint = server.ip;
    config.endpoint = dict[@"endPoint"];
    
//    config.type = VPNServiceL2TPOverIPSec;
//    config.name = @"feixiang";
//    config.username = @"zhengbofang";
//    config.password = @"admin@123";
//    config.endpoint = @"124.248.228.254";
//
    if (config.type==VPNServiceL2TPOverIPSec) {
         config.sharedSecret = @"ed19d30d1959383e6e8b25cee0bbef5d";
    }
    config.enableSplitTunnel = false;
    exitCode = [self createService:config usingPreferencesRef:prefs];
    
//    SCPreferencesUnlock(prefs);
    return config.serviceID;

}
+ (Boolean) removeService: (CFStringRef)serviceName usingPreferencesRef:(SCPreferencesRef)prefs{

    
    NSLog(@"serviceName==%@",serviceName);
    CFArrayRef              servicesArray = NULL;
    CFIndex arraySize, i;
    SCNetworkServiceRef		service = NULL;
    
    
    servicesArray = SCNetworkServiceCopyAll(prefs);
    if (servicesArray == NULL) {
//        NSLog(@"No such network services");
        return false;
    }
    arraySize = CFArrayGetCount(servicesArray);
    for (i = 0; i < arraySize; ++i) {
        service = (SCNetworkServiceRef) CFArrayGetValueAtIndex(servicesArray, i);
        CFStringRef serviceToDial = SCNetworkServiceGetName(service);
        
          NSLog(@"serviceToDial==%@",serviceToDial);
        if (CFStringCompare(serviceName, serviceToDial, 0) == kCFCompareEqualTo) {
        
 
           bool c =  SCNetworkServiceRemove(service);
//            CFRelease(serviceToDial);
            
            NSLog(@"是否执行了rm%zd",c);
            break;
        }
    }
    
    
    if (!SCPreferencesCommitChanges(prefs)) {
        NSLog(@"Error: Could not commit preferences with service . %s (Code %i)", SCErrorString(SCError()), SCError());
        return 41;
    }

    
    if (!SCPreferencesApplyChanges(prefs)) {
//        NSLog(@"Error: Could not apply changes with service %@. %s (Code %i)", serviceName, SCErrorString(SCError()), SCError());
        return 42;
    }
   
//    sleep(0.05);
    
    
//   printf("%zd", CFGetRetainCount(servicesArray));
//    CFRetain(servicesArray);
//        printf("%zd", CFGetRetainCount(servicesArray));
//    CFRelease(servicesArray);
//        printf("%zd", CFGetRetainCount(servicesArray));
//    CFRelease(servicesArray);
    
//    CFRelease(serviceName);
    
    return TRUE;
}
+ (CFStringRef) getServiceId: (CFStringRef)serviceName usingPreferencesRef:(SCPreferencesRef)prefs{
    CFStringRef serviceToDial = NULL;
    CFArrayRef              servicesArray = NULL;
    CFIndex arraySize, i;
    SCNetworkServiceRef		service = NULL;
    
    
    servicesArray = SCNetworkServiceCopyAll(prefs);
    if (servicesArray == NULL) {
//        NSLog(@"No network services");
        return serviceToDial;
    }
    
    arraySize = CFArrayGetCount(servicesArray);
    for (i = 0; i < arraySize; ++i) {
        service = (SCNetworkServiceRef) CFArrayGetValueAtIndex(servicesArray, i);
        serviceToDial = SCNetworkServiceGetName(service);
        if (CFStringCompare(serviceName, serviceToDial, 0) == kCFCompareEqualTo) {
            serviceToDial = SCNetworkServiceGetServiceID(service);
            return serviceToDial;
            break;
        }
    }
    CFRelease(serviceName);
    CFRelease(servicesArray);
    CFRelease(prefs);

    return serviceToDial;
}


//+ (int) startService:(VPNServiceConfig*)config usingPreferencesRef:(SCPreferencesRef)prefs{
+ (int) startService: (CFStringRef)ServiceToDial {
   	ServiceToDial = (__bridge CFStringRef)serverID;

    
    NSLog(@"%@",ServiceToDial);
    
//    CallbackParams          params;
    SCNetworkConnectionRef  connection;
    int err = 0;
    Boolean					ok;
    
    
    
    SCNetworkConnectionContext context;
    
#if 1
    // Set up the parameters to our callback function.
    //params.magic            = kCallbackParamsMagic;
    params.forcePrintStatus = true;
    params.lastMinorStatus  = kSCNetworkConnectionDisconnected;
    params.lastMinorStatus  = kSCNetworkConnectionPPPDisconnected;
    
    // Set up the context to reference those parameters.
    context.version         = 0;
    context.info            = (void *)&params;
    //context.info            = NULL;
    context.retain          = NULL;
    context.release         = NULL;
    context.copyDescription = NULL;
#endif
    
    NSLog(@"启动了里l2tp");
    connection = SCNetworkConnectionCreateWithServiceID(NULL,
                                                        ServiceToDial,
                                                        MyNetworkConnectionCallBack,
                                                        &context);
    
    
    
    if (connection == NULL) {
//        NSLog(@"Create connection error: code[%i], msg: %s\n", SCError(), SCErrorString(SCError()));
        return 60;
    }
    
    
    // Schedule our callback with the runloop.
    ok = SCNetworkConnectionScheduleWithRunLoop(connection,
                                                CFRunLoopGetCurrent(),
                                                kCFRunLoopDefaultMode);
    if (!ok) {
        err = SCError();
    }
    
//    // Check the status.  If we're already connected tell the user.
//    // If we're not connected, initiate the connection.
//    if (err == 0) {
//        // Most cases involve us bailing out, set the error here
//        err = ECANCELED;
//        
//        switch (SCNetworkConnectionGetStatus(connection)) {
//            case kSCNetworkConnectionDisconnected:
//                err = 0;
//                break;
//            case kSCNetworkConnectionConnecting:
//                NSLog(@"Service is already connecting.\n");
//                break;
//            case kSCNetworkConnectionDisconnecting:
//                NSLog(@"Service is disconnecting.\n");
//                break;
//            case kSCNetworkConnectionConnected:
//                NSLog(@"Service is already connected.\n");
//                break;
//            case kSCNetworkConnectionInvalid:
//                NSLog(@"Service is invalid. Weird.\n");
//                break;
//            default:
//                NSLog(@"Unexpected status.\n");
//                break;
//        }
//    }
//
//    
//    // Initiate the connection.
    if (err == 0) {
//        NSLog(@"Connecting...\n");
        ok = SCNetworkConnectionStart(connection, NULL, false);
        if (!ok) {
            err = SCError();
            NSLog(@"SCNetworkConnectionStart failed: %d, %s", err, SCErrorString(SCError()));
        }
    }
//
//    
//    // Run the runloop and wait for our connection attempt to be resolved.
//    // Once that happens, print the result.
//    CFDictionaryRef failedstatus;
    if (err == 0) {
        CFRunLoopRun();
        
        switch (params.lastMinorStatus) {
            case kSCNetworkConnectionPPPConnected:
                NSLog(@"Connection succeeded\n");
                
                break;
            case kSCNetworkConnectionPPPDisconnected:
                NSLog(@"Connection failed\n");
                
//                failedstatus = SCNetworkConnectionCopyExtendedStatus(connection);
//                CFShow(failedstatus);
                err = ECANCELED;
                break;
            default:
                NSLog(@"Bad params.lastMinorStatus (%ld)\n",
                      (long) params.lastMinorStatus);
                err = EINVAL;
        }
    }
//
//    
//    NSLog(@"loop out run\n");
//    // Run this loop indefinitely until a SIGINT signal is received
    if (err == 0) {
        CFRunLoopRun();
    }
//    CFRelease(connection);
//    CFRelease(connection);
//    CFRelease(failedstatus);
    
    return 0;

}

+ (int)stopService:(CFStringRef)serviceID{

    serviceID = (__bridge CFStringRef)serverID;
    SCNetworkConnectionRef  connection;
    int err = 0;
    Boolean					ok;
    SCNetworkConnectionContext context;
    
    // Set up the parameters to our callback function.
    //params.magic            = kCallbackParamsMagic;
    params.forcePrintStatus = true;
    params.lastMinorStatus  = kSCNetworkConnectionDisconnected;
    params.lastMinorStatus  = kSCNetworkConnectionPPPDisconnected;
    
    // Set up the context to reference those parameters.
    context.version         = 0;
    context.info            = NULL;
    context.info            = NULL;
    context.retain          = NULL;
    context.release         = NULL;
    context.copyDescription = NULL;
    
    connection = SCNetworkConnectionCreateWithServiceID(NULL,
                                                        serviceID,
                                                        NULL,
                                                        &context);
    
    
    if (connection == NULL) {
//        NSLog(@"Create connection error: code[%i], msg: %s\n", SCError(), SCErrorString(SCError()));
        return 60;
    }
    
    ok = SCNetworkConnectionStop(connection, true);
    if (!ok) {
        err = SCError();
//        NSLog(@"SCNetworkConnectionStart failed: %d, %s", err, SCErrorString(err));
    }

    CFRelease(connection);
   
    return 0;
}



+ (int) createService:(VPNServiceConfig*)config usingPreferencesRef:(SCPreferencesRef)prefs {
    NSLog(@"Creating new %@ Service using %@", config.humanType, config);
    
    // These variables will hold references to our new interfaces
    SCNetworkInterfaceRef topInterface;
    SCNetworkInterfaceRef bottomInterface;
    
    switch (config.type) {
        case VPNServiceL2TPOverIPSec:
            NSLog(@"L2TP Service detected...");
            // L2TP on top of IPv4
            bottomInterface = SCNetworkInterfaceCreateWithInterface(kSCNetworkInterfaceIPv4,kSCNetworkInterfaceTypeL2TP);
            // PPP on top of L2TP
            topInterface = SCNetworkInterfaceCreateWithInterface(bottomInterface, kSCNetworkInterfaceTypePPP);
            break;
            
        case VPNServiceCiscoIPSec:
            NSLog(@"Cisco IPSec Service detected...");
            // Cisco IPSec (without underlying interface)
            topInterface = SCNetworkInterfaceCreateWithInterface (kSCNetworkInterfaceIPv4, kSCNetworkInterfaceTypeIPSec);
            break;
            
        case VPNServicePPTP:
            // PPTP on top of IPv4
            bottomInterface = SCNetworkInterfaceCreateWithInterface(kSCNetworkInterfaceIPv4,kSCNetworkInterfaceTypePPTP);
            // PPP on top of PPTP
            topInterface = SCNetworkInterfaceCreateWithInterface(bottomInterface, kSCNetworkInterfaceTypePPP);
            break;
            
        default:
            NSLog(@"Sorry, this service type is not yet supported");
            return 32;
            break;
    }
    
    NSLog(@"Instantiating interface references...");
    NSLog(@"Creating a new, fresh VPN service in memory using the interface we already created");
    SCNetworkServiceRef service = SCNetworkServiceCreate(prefs, topInterface);
    NSLog(@"That service is to have a name");
    SCNetworkServiceSetName(service, (__bridge CFStringRef)config.name);
    NSLog(@"And we also woould like to know the internal ID of this service");
    NSString *serviceID = (__bridge NSString *)(SCNetworkServiceGetServiceID(service));
    NSLog(@"It will be used to find the correct passwords in the system keychain");
    config.serviceID = serviceID;
    
    // Interestingly enough, the interface variables in itself are now worthless.
    // We used them to create the service and that's it, we cannot modify or use them any more.
    NSLog(@"Deallocating obsolete interface references...");
    CFRelease(topInterface);
    topInterface = NULL;
    if (bottomInterface) {
        CFRelease(bottomInterface);
        bottomInterface = NULL;
    }
    
    NSLog(@"Reloading top Interface...");
    // Because, if we would like to modify the interface, we first need to freshly fetch it from the service
    // See https://lists.apple.com/archives/macnetworkprog/2013/Apr/msg00016.html
    topInterface = SCNetworkServiceGetInterface(service);
    
    // Error Codes 50-59
    
    switch (config.type) {
        case VPNServiceL2TPOverIPSec:
            NSLog(@"Configuring %@ Service", config.humanType);
            
            // Let's apply all configuration to the PPP interface
            // Specifically, the servername, account username and password
            if (SCNetworkInterfaceSetConfiguration(topInterface, config.L2TPPPPConfig)) {
                NSLog(@"Successfully configured PPP interface of service %@", config.name);
            } else {
                NSLog(@"Error: Could not configure PPP interface for service %@", config.name);
                return 50;
            }
            
            // Now let's apply the shared secret to the IPSec part of the L2TP/IPSec Interface
            if (SCNetworkInterfaceSetExtendedConfiguration(topInterface, CFSTR("IPSec"), config.L2TPIPSecConfig)) {
                NSLog(@"Successfully configured IPSec on PPP interface for service %@", config.name);
            } else {
                NSLog(@"Error: Could not configure IPSec on PPP interface for service %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
                return 35;
            }
            break;
            
        case VPNServiceCiscoIPSec:
            NSLog(@"Configuring %@ Service", config.humanType);
            
            // Let's apply all configuration data to the Cisco IPSec interface
            // As opposed to L2TP, here all configuration goes to the top Interface, i.e. the only Interface there is.
            if (SCNetworkInterfaceSetConfiguration(topInterface, config.ciscoConfig)) {
                NSLog(@"Successfully configured Cisco IPSec interface of service %@", config.name);
            } else {
                NSLog(@"Error: Could not configure Cisco IPSec interface for service %@", config.name);
                return 51;
            }
            break;
        case VPNServicePPTP:
            NSLog(@"Configuring %@ Service", config.humanType);
            
            // Let's apply all configuration to the PPP interface
            // Specifically, the servername, account username and password
            CFDictionaryRef tmp = config.PPTPPPPConfig;
            if (SCNetworkInterfaceSetConfiguration(topInterface, tmp)) {
                NSLog(@"Successfully configured PPP interface of service %@", config.name);
            } else {
                NSLog(@"Error: Could not configure PPP interface for service %@", config.name);
                return 50;
            }
            
            break;
            
        default:
            NSLog(@"Error: I cannot handle this interface type yet.");
            return 59;
            break;
    }
    
    // Error Codes ...
    
    NSLog(@"Adding default protocols (DNS, etc.) to service %@...", config.name);
    if (!SCNetworkServiceEstablishDefaultConfiguration(service)) {
        NSLog(@"Error: Could not establish a default service configuration for %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
        return 36;
    }
    
    NSLog(@"Fetching set of all available network services...");
    SCNetworkSetRef networkSet = SCNetworkSetCopyCurrent(prefs);
    if (!networkSet) {
        NSLog(@"Error: Could not fetch current network set when creating %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
        return 37;
    }
    
    if (!SCNetworkSetAddService (networkSet, service)) {
        if (SCError() == 1005) {
            NSLog(@"Skipping VPN Service %@ because it already exists.", config.humanType);
            return 0;
        } else {
            NSLog(@"Error: Could not add new VPN service %@ to current network set. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
            return 38;
        }
    }
    
    NSLog(@"Fetching IPv4 protocol of service %@...", config.name);
    SCNetworkProtocolRef protocol = SCNetworkServiceCopyProtocol(service, kSCNetworkProtocolTypeIPv4);
    
    if (!protocol) {
        NSLog(@"Error: Could not fetch IPv4 protocol of %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
        return 39;
    }
    
    NSLog(@"Configuring IPv4 protocol of service %@...", config.name);
    if (!SCNetworkProtocolSetConfiguration(protocol, config.L2TPIPv4Config)) {
        NSLog(@"Error: Could not configure IPv4 protocol of %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
        return 40;
    }
    
    SCNetworkServiceSetEnabled(service, TRUE);
    
    NSLog(@"Commiting all changes including service %@...", config.name);
    if (!SCPreferencesCommitChanges(prefs)) {
        NSLog(@"Error: Could not commit preferences with service %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
        return 41;
    }
    
    
    
    NSLog(@"Preparing to add Keychain items for service %@...", config.name);
    
    // The password and the shared secret are not stored directly in the System Preferences .plist file
    // Instead we put them into the KeyChain. I know we're creating new items each time you run this application
    // But this actually is the same behaviour you get using the official System Preferences Network Pane
    if (config.password) {
        [VPNKeychain createPasswordKeyChainItem:config.name forService:serviceID withAccount:config.username andPassword:config.password];
    }
    
    if (config.sharedSecret) {
        [VPNKeychain createSharedSecretKeyChainItem:config.name forService:serviceID withPassword:config.sharedSecret];
    }
    
    //NSError *error;
    //[AHKeychain setPassword:config.password service:serviceID account:config.username keychain:kAHKeychainSystemKeychain
    //                  error:&error];
    
    if (!SCPreferencesApplyChanges(prefs)) {
        NSLog(@"Error: Could not apply changes with service %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
        return 42;
    }
    
    NSLog(@"Successfully created %@ VPN %@ with ID %@", config.humanType, config.name, serviceID);
    serverID = serviceID;
    
    return 0;
}


//// This method creates one VPN interface according to the desired configuration
//+ (int) createService:(NSMutableArray*)configs usingPreferencesRef:(SCPreferencesRef)prefs  server:(NSArray *)servers{
//    
////  NSMutableArray *arr = [NSMutableArray array];
//    for (int i=0 ;i<configs.count;i++) {
//        VPNServiceConfig *config = configs[i];
////        BFServers *server = servers[i];
//        
//      
////        NSLog(@"Creating new %@ Service using %@", config.humanType, config);
//        
//        // These variables will hold references to our new interfaces
//        SCNetworkInterfaceRef topInterface;
//        SCNetworkInterfaceRef bottomInterface;
//        
//        switch (config.type) {
//            case VPNServiceL2TPOverIPSec:
////                NSLog(@"L2TP Service detected...");
//                // L2TP on top of IPv4
//                bottomInterface = SCNetworkInterfaceCreateWithInterface(kSCNetworkInterfaceIPv4,kSCNetworkInterfaceTypeL2TP);
//                // PPP on top of L2TP
//                topInterface = SCNetworkInterfaceCreateWithInterface(bottomInterface, kSCNetworkInterfaceTypePPP);
//                CFRelease(bottomInterface);
//                bottomInterface = NULL;
//                break;
//                
//            case VPNServiceCiscoIPSec:
////                NSLog(@"Cisco IPSec Service detected...");
//                // Cisco IPSec (without underlying interface)
//                topInterface = SCNetworkInterfaceCreateWithInterface (kSCNetworkInterfaceIPv4, kSCNetworkInterfaceTypeIPSec);
//                break;
//                
//            case VPNServicePPTP:
//                // PPTP on top of IPv4
//                bottomInterface = SCNetworkInterfaceCreateWithInterface(kSCNetworkInterfaceIPv4,kSCNetworkInterfaceTypePPTP);
//                // PPP on top of PPTP
//                topInterface = SCNetworkInterfaceCreateWithInterface(bottomInterface, kSCNetworkInterfaceTypePPP);
//                CFRelease(bottomInterface);
//                bottomInterface = NULL;
//                break;
//                
//            default:
////                NSLog(@"Sorry, this service type is not yet supported");
//                return 32;
//                break;
//        }
//        
////        NSLog(@"Instantiating interface references...");
////        NSLog(@"Creating a new, fresh VPN service in memory using the interface we already created");
//        SCNetworkServiceRef service = SCNetworkServiceCreate(prefs, topInterface);
////        NSLog(@"That service is to have a name");
//        SCNetworkServiceSetName(service, (__bridge CFStringRef)config.name);
////        NSLog(@"And we also woould like to know the internal ID of this service");
//        NSString *serviceID = (__bridge NSString *)(SCNetworkServiceGetServiceID(service));
////        NSLog(@"It will be used to find the correct passwords in the system keychain");
//        config.serviceID = serviceID;
////        server.serviceID = serviceID;
//       
//        // Interestingly enough, the interface variables in itself are now worthless.
//        // We used them to create the service and that's it, we cannot modify or use them any more.
////        NSLog(@"Deallocating obsolete interface references...");
//        CFRelease(topInterface);
//        topInterface = NULL;
////        if (bottomInterface) {
////            CFRelease(bottomInterface);
////            bottomInterface = NULL;
////        }
//        
////        NSLog(@"Reloading top Interface...");
//        // Because, if we would like to modify the interface, we first need to freshly fetch it from the service
//        // See https://lists.apple.com/archives/macnetworkprog/2013/Apr/msg00016.html
//        topInterface = SCNetworkServiceGetInterface(service);
//        
//        // Error Codes 50-59
//        
//        switch (config.type) {
//            case VPNServiceL2TPOverIPSec:
////                NSLog(@"Configuring %@ Service", config.humanType);
//                
//                // Let's apply all configuration to the PPP interface
//                // Specifically, the servername, account username and password
//                if (SCNetworkInterfaceSetConfiguration(topInterface, config.L2TPPPPConfig)) {
////                    NSLog(@"Successfully configured PPP interface of service %@", config.name);
//                } else {
////                    NSLog(@"Error: Could not configure PPP interface for service %@", config.name);
//                    return 50;
//                }
//                
//                // Now let's apply the shared secret to the IPSec part of the L2TP/IPSec Interface
//                if (SCNetworkInterfaceSetExtendedConfiguration(topInterface, CFSTR("IPSec"), config.L2TPIPSecConfig)) {
////                    NSLog(@"Successfully configured IPSec on PPP interface for service %@", config.name);
//                } else {
////                    NSLog(@"Error: Could not configure IPSec on PPP interface for service %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
//                    return 35;
//                }
//                break;
//                
//            case VPNServiceCiscoIPSec:
////                NSLog(@"Configuring %@ Service", config.humanType);
//                
//                // Let's apply all configuration data to the Cisco IPSec interface
//                // As opposed to L2TP, here all configuration goes to the top Interface, i.e. the only Interface there is.
//                if (SCNetworkInterfaceSetConfiguration(topInterface, config.ciscoConfig)) {
////                    NSLog(@"Successfully configured Cisco IPSec interface of service %@", config.name);
//                } else {
////                    NSLog(@"Error: Could not configure Cisco IPSec interface for service %@", config.name);
//                    return 51;
//                }
//                break;
//            case VPNServicePPTP:
//                (void)VPNServicePPTP;
////                NSLog(@"Configuring %@ Service", config.humanType);
//                
//                // Let's apply all configuration to the PPP interface
//                // Specifically, the servername, account username and password
//                CFDictionaryRef tmp = config.PPTPPPPConfig;
//                if (SCNetworkInterfaceSetConfiguration(topInterface, tmp)) {
////                    NSLog(@"Successfully configured PPP interface of service %@", config.name);
//                } else {
////                    NSLog(@"Error: Could not configure PPP interface for service %@", config.name);
//                    return 50;
//                }
//                
//                break;
//                
//            default:
////                NSLog(@"Error: I cannot handle this interface type yet.");
//                return 59;
//                break;
//        }
//        
//        // Error Codes ...
//        
////        NSLog(@"Adding default protocols (DNS, etc.) to service %@...", config.name);
//        if (!SCNetworkServiceEstablishDefaultConfiguration(service)) {
////            NSLog(@"Error: Could not establish a default service configuration for %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
//            return 36;
//        }
//        
////        NSLog(@"Fetching set of all available network services...");
//        SCNetworkSetRef networkSet = SCNetworkSetCopyCurrent(prefs);
//        if (!networkSet) {
////            NSLog(@"Error: Could not fetch current network set when creating %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
//            return 37;
//        }
//        
//        if (!SCNetworkSetAddService (networkSet, service)) {
//            if (SCError() == 1005) {
////                NSLog(@"Skipping VPN Service %@ because it already exists.", config.humanType);
//                return 0;
//            } else {
////                NSLog(@"Error: Could not add new VPN service %@ to current network set. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
//                return 38;
//            }
//        }
//        
////        NSLog(@"Fetching IPv4 protocol of service %@...", config.name);
//        SCNetworkProtocolRef protocol = SCNetworkServiceCopyProtocol(service, kSCNetworkProtocolTypeIPv4);
//        
//        if (!protocol) {
////            NSLog(@"Error: Could not fetch IPv4 protocol of %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
//            return 39;
//        }
//        
////        NSLog(@"Configuring IPv4 protocol of service %@...", config.name);
//        if (!SCNetworkProtocolSetConfiguration(protocol, config.L2TPIPv4Config)) {
////            NSLog(@"Error: Could not configure IPv4 protocol of %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
//            return 40;
//        }
//        
//        SCNetworkServiceSetEnabled(service, TRUE);
//        
////        NSLog(@"Commiting all changes including service %@...", config.name);
//        if (!SCPreferencesCommitChanges(prefs)) {
////            NSLog(@"Error: Could not commit preferences with service %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
//            return 41;
//        }
//        
//        
//        
////        NSLog(@"Preparing to add Keychain items for service %@...", config.name);
//        
//    if (!SCPreferencesApplyChanges(prefs)) {
////                 NSLog(@"Error: Could not apply changes with service %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
//                 return 42;
//              }
////NSLog(@"Successfully created %@ VPN %@ with ID %@", config.humanType, config.name, serviceID);
//        
////        NSMutableString *ms = [NSMutableString stringWithString:config.name];
////        if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)) {
////                        NSLog(@"Pingying: %@", ms);
////            // wo shi zhong guo ren
////            [arr addObject:ms];
////        }
//        
//        [thearguments addObject:config.name];
//        [thearguments addObject:config.serviceID];
//        [thearguments addObject:config.username];
//        [thearguments addObject:config.password];
//        [thearguments addObject:config.sharedSecret];
//        
//        CFRelease(topInterface);
//        topInterface = NULL;
//        if (topInterface) {
//            CFRelease(topInterface);
//            topInterface = NULL;
//        }
//        if (topInterface) {
//            CFRelease(topInterface);
//            topInterface = NULL;
//        }
//        CFRelease(service);
//        service = NULL;
//        if (service) {
//            CFRelease(service);
//            service = NULL;
//        }
//        if (service) {
//            CFRelease(service);
//            service = NULL;
//        }
//        if (service) {
//            CFRelease(service);
//            service = NULL;
//        }
////        if (protocol) {
////            free(protocol);
////        }
////        CFRelease(service);
////        CFRelease(protocol);
//        CFRelease(networkSet);
//        networkSet = NULL;
//        if (networkSet) {
//            CFRelease(networkSet);
//            networkSet = NULL;
//        }
//    }
////    NSString *path =[[NSBundle mainBundle]pathForResource:@"permanentProcess" ofType:nil];
////    NSString *path = @"/Users/yxzc/Desktop/svnText/flyingVPNPPTP/flyingVPN/build/Debug/permanentProcess";
//    
////    NSArray *array = [NSArray arrayWithObjects:config.name,serviceID ,config.username,config.password,nil];
//    
////    NSString *str = [configs componentsJoinedByString:@","];
////    
////    NSLog(@"%@",str);
//    
//
////
//    
//    
////    [self runAsRoot:path arguments:thearguments];
//    
//    
//
//  // The password and the shared secret are not stored directly in the System Preferences .plist file
//  // Instead we put them into the KeyChain. I know we're creating new items each time you run this application
//  // But this actually is the same behaviour you get using the official System Preferences Network Pane
////  if (config.password) {
////      NSLog(@"unlock%zd",a);
////    [VPNKeychain createPasswordKeyChainItem:config.name forService:serviceID withAccount:config.username andPassword:config.password];
//    
//    
//    
////        NSLog(@"lock%zd",a);
////  }
//
////  if (config.sharedSecret) {
////    [VPNKeychain createSharedSecretKeyChainItem:config.name forService:serviceID withPassword:config.sharedSecret];
////  }
//    
//   //NSError *error;
//  //[AHKeychain setPassword:config.password service:serviceID account:config.username keychain:kAHKeychainSystemKeychain
//    //                  error:&error];
//
////  if (!SCPreferencesApplyChanges(prefs)) {
////     NSLog(@"Error: Could not apply changes with service %@. %s (Code %i)", config.name, SCErrorString(SCError()), SCError());
////     return 42;
////  }
////
////  NSLog(@"Successfully created %@ VPN %@ with ID %@", config.humanType, config.name, serviceID);
//  return 0;
//}
//
//+(void)runAsRoot:(NSString *)thePath arguments:(NSArray *)theArguments{
//    
//    STPrivilegedTask *privilegedTask = [[STPrivilegedTask alloc] init];
//    //    self.privilegedTask = privilegedTask;
//    [privilegedTask setLaunchPath:thePath];
//    //    NSArray *args = theArguments;
//    [privilegedTask setArguments:theArguments];
//    [privilegedTask setCurrentDirectoryPath:[[NSBundle mainBundle] resourcePath]];
//    OSStatus err = [privilegedTask launch];
//    if (err != errAuthorizationSuccess) {
//        if (err == errAuthorizationCanceled) {
//            //            NSLog(@"User cancelled");
//            //            [self stopToLink:self.stopLink];
//        } else {
//            //            NSLog(@"Something went wrong");
//            //            [self stopToLink:self.stopLink];
//        }
//    } else {
//        //        [self rootProcessSocket];
//        dispatch_async( dispatch_get_global_queue(0, 0), ^{
//            //            self.safeport = [theArguments[kSOCKETPROTINDEXT] intValue];
//            //
//            //            int socketStatus =  [self rootProcessSocket];
//            //
//            //            if (socketStatus==1) {
//            //                sleep(2);
//            //                socketStatus =  [self rootProcessSocket];
//            //            }
//            
//            //                if (b==0) {
//            //                    dispatch_async(dispatch_get_main_queue(), ^{
//            //                        [self stopToLink:self.stopLink];
//            //                    });
//            //                }
//            //            }
//        });
//    }
//    [privilegedTask waitUntilExit];
//    
//    //        NSFileHandle *readHandle = [privilegedTask outputFileHandle];
//    //        NSData *outputData = [readHandle readDataToEndOfFile];
//    //        NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
//}



- (void)dealloc{

    NSLog(@"%s",__func__);
}

@end
