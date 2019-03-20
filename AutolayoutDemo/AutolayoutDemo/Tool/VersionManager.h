//
//  VersionManager.h
//  AutolayoutDemo
//
//  Created by Binfeng Peng - Vendor on 2019/2/25.
//  Copyright © 2019年 Binfeng Peng - Vendor. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AppModel;

NS_ASSUME_NONNULL_BEGIN

@interface VersionManager : NSObject

/**
 * 调用此接口判断AppStore的版本是否有更新
 * @param appId app的唯一标识 登录开发者账号到 App Store Connect 上查看 App ID
 * @param versionBlock 是否更新到回调
 */
+ (void)isAppstoreVersionUpdate:(NSString *)appId versionBlock:(void (^)(BOOL isUpdate))versionBlock;

/**
 * 调用此接口跳转到AppStore下载更新页面
 * @param appStoreURLString App Store应用间通信的URL字符串常量
 */
+ (void)jumpToAppStoreApp:(NSString *)appStoreURLString;

/**
 * 调用此接口检查jsbundle包是否有更新
 * @param modal App 模型对象
 */
+ (BOOL)isJSBundleVersionUpdate:(AppModel *)modal;

@end

NS_ASSUME_NONNULL_END
