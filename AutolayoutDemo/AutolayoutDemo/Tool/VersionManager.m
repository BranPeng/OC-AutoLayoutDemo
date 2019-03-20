//
//  VersionManager.m
//  AutolayoutDemo
//
//  Created by Binfeng Peng - Vendor on 2019/2/25.
//  Copyright © 2019年 Binfeng Peng - Vendor. All rights reserved.
//

#import "VersionManager.h"
#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import "AppModel.h"

NSString * const kAppStoreVersion = @"kAppStoreVersion";

@implementation VersionManager

/**
 * 调用此接口判断AppStore的版本是否有更新
 * @param appId app的唯一标识 登录开发者账号到 App Store Connect 上查看 App ID
 * @param versionBlock 是否更新到回调
 */
+ (void)isAppstoreVersionUpdate:(NSString *)appId versionBlock:(void (^)(BOOL isUpdate))versionBlock;
{
    NSString *versionURL = [NSString stringWithFormat:@"https://itunes.apple.com/cn/lookup?id=%@", appId];
    
    // 版本号请求会引起线程阻塞，所以放入后台线程
    // 并发队列的创建方法
    dispatch_queue_t queue = dispatch_queue_create("net.bran.versionQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        // 这里放异步执行任务代码
        // 1.创建请求管理对象
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        
        session.requestSerializer = [AFHTTPRequestSerializer serializer];
        session.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        // 设置请求超时时间
        session.requestSerializer.timeoutInterval = 100.f;
        
        // 2.发送请求
        [session GET:versionURL parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // 请求成功，解析数据
            if(responseObject != nil) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
                
                NSString *resultCount = dic[@"resultCount"];
                if ([resultCount intValue] > 0) {
                    NSString *version = dic[@"results"][0][@"version"];
                    
                    
                    NSString *appCurrentVersion = [VersionManager getAppVersion];
                    if ([version floatValue] > [appCurrentVersion floatValue]) {
                        // 有更新
                        
                        // 回到主队列
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (versionBlock) {
                                versionBlock(YES);
                            }
                        });
                    } else {
                        // 回到主队列
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (versionBlock) {
                                versionBlock(NO);
                            }
                        });
                        
                    }
                }
                
                
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error:%@", error);
            
            // 回到主队列
            dispatch_async(dispatch_get_main_queue(), ^{
                if (versionBlock) {
                    versionBlock(NO);
                }
            });
        }];
    });
}

+ (NSString *)getAppVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle]infoDictionary];
    NSString *appCurVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    return appCurVersion;
}

/**
 * 调用此接口跳转到AppStore下载更新页面
 * @param appStoreURLString App Store应用间通信的URL字符串常量
 */
+ (void)jumpToAppStoreApp:(NSString *)appStoreURLString;
{
    NSString *appStoreURLStr = appStoreURLString;
    NSURL *appStoreURL = [NSURL URLWithString:appStoreURLStr];
    if ([[UIApplication sharedApplication]canOpenURL:appStoreURL]) {
        if ([UIDevice currentDevice].systemVersion.doubleValue >= 10.0) {
            [[UIApplication sharedApplication] openURL:appStoreURL options:@{UIApplicationOpenURLOptionsAnnotationKey: @"YES"} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:appStoreURL];
        }
    }
}

/**
 * 调用此接口检查jsbundle包是否有更新
 * @param modal App 模型对象
 */
+ (BOOL)isJSBundleVersionUpdate:(AppModel *)modal
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:modal.cid];
    AppModel *oldModal = [AppModel unarchiveData:data];
    float oldVersion = oldModal.version.floatValue;
    float version = modal.version.floatValue;
    if (oldVersion < version) {
        return YES;
    } else {
        return NO;
    }
}

@end
