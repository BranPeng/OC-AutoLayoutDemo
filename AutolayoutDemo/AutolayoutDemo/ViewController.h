//
//  ViewController.h
//  AutolayoutDemo
//
//  Created by Binfeng Peng - Vendor on 2019/2/25.
//  Copyright © 2019年 Binfeng Peng - Vendor. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionHandlerBlock)(NSData *jsonData, NSError * _Nullable error);

@interface ViewController : UIViewController

// response jsonData: { "iosVersion": "10.0", "androidVersion": "10.0", message: "description", "code": 200 }
- (void)getAppVersionFromAppStore:(NSString *)iosAppId androidAppId:(NSString *)androidAppId url:(NSString *)url completionHandlerBlock:(CompletionHandlerBlock)completionHandlerBlock;

// response jsonData: { "jsbundleVersion": "10.0", message: "description", "code": 200 }
- (void)getJSBundleVersion:(NSString *)appId url:(NSString *)url completionHandlerBlock:(CompletionHandlerBlock)completionHandlerBlock;

/**
 *  向服务器请求获取app在app store上是否有新版本发布, 服务器响应数据如下：
     request{
         osVersion
         platform
         appId
         appVersion
     }
 
 
     response jsonData:
     {
        platForm: "iOS",
        latestAppVersion: "",
        isForceUpdate: "yes",
        isUpdate": "yes",
        updateUrl: "http://",
        updateContent: "description",
     }
 * @param osVersion                 当前手机操作系统版本号
 * @param platform                  平台：iOS/Android
 * @param appId                     app的唯一标识
 * @param appVersion                已经安装在手机上的app的版本号
 * @param url                       服务器URL
 * @param completionHandlerBlock    服务器回调数据
**/
- (void)getAppVersionIsUpdateFromAppStore:(NSString *)osVersion
                                 platform:(NSString *)platform
                                    appId:(NSString *)appId
                               appVersion:(NSString *)appVersion
                                      url:(NSString *)url
                   completionHandlerBlock:(CompletionHandlerBlock)completionHandlerBlock;

/**
 *  向服务器请求获取jsbundle是否有新版本发布, 服务器响应数据如下：
     request{
         osVersion
         platform
         bundleId
         bundleVersion
     }
 
 
     response jsonData:
     {
        isForceUpdate: "yes",
        isUpdate: "yes",
        version: "10.0",
        iconUrl: "http://util.yuanhengtech.cn/docs/eflow/Leave.png",
        androidBundleUrl: "http://util.yuanhengtech.cn/docs/eflow_dev/LeaveAndroid.zip",
        iosBundleUrl: "http://util.yuanhengtech.cn/docs/eflow_dev/SamsRNLeave.zip",
        bundleName: "SamsRNLeave",
        titleName: "Service Center",
        updateContent: "description",
     }
 * @param osVersion                 当前手机操作系统版本号
 * @param platform                  平台：iOS/Android
 * @param bundleId                  jsbundle的唯一标识
 * @param bundleVersion             当前app使用的jsbundle的版本号
 * @param url                       服务器URL
 * @param completionHandlerBlock    服务器回调数据
 **/
- (void)getJSBundleVersionIsUpdate:(NSString *)osVersion
                          platform:(NSString *)platform
                          bundleId:(NSString *)bundleId
                     bundleVersion:(NSString *)bundleVersion
                               url:(NSString *)url
            completionHandlerBlock:(CompletionHandlerBlock)completionHandlerBlock;

@end

