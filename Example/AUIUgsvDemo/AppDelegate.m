//
//  AppDelegate.m
//  AUIUgsvDemo
//
//  Created by Bingo on 2022/10/27.
//

#import "AppDelegate.h"
#import "AlivcUgsvSDKHeader.h"

#import "AUIFoundation.h"

#define ENABLE_UGSV_MAIN
#ifdef ENABLE_UGSV_MAIN
#import "AUIUgsvViewController.h"
#else
#import "ViewController.h"
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)registerSDK {
#if DEBUG
//    [AliyunVideoSDKInfo setLogLevel:AlivcLogDebug];
#else
    [AliyunVideoSDKInfo setLogLevel:AlivcLogWarn];
#endif
    [AliyunVideoSDKInfo registerSDK];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // 仅支持暗黑模式
    AVTheme.supportsAutoMode = NO;
    AVTheme.currentMode = AVThemeModeDark;
    
#ifdef ENABLE_UGSV_MAIN
    AUIUgsvViewController *rootVC = [AUIUgsvViewController new];
    rootVC.hiddenBackButton = YES;
#else
    ViewController *rootVC = [ViewController new];
#endif
    AVNavigationController *nav =[[AVNavigationController alloc] initWithRootViewController:rootVC];
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];
    
    [self registerSDK];
    return YES;
}


@end
