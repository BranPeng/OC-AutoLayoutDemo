//
//  ResourceFileManager.h
//  RNContainer
//
//  Created by Sijun Pan - Vendor on 2018/11/9.
//  Copyright © 2018年 Facebook. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ResourceModel;
NS_ASSUME_NONNULL_BEGIN

// 资源的枚举类型
typedef enum {
  ResourceDowmloadTypeNotInstall = 0,// 未安装的
  ResourceDowmloadTypeInstalled = 1,// 已安装的
  ResourceDowmloadTypeWillInstall = 2,// 等待下载安装
  ResourceDowmloadTypeDownloading = 3,// 正在下载安装
} ResourceType;

#pragma mark - ResourceFileManager
@interface ResourceFileManager : NSObject


+ (ResourceFileManager *)shareInstance;

- (void)installResourceArrWith:(NSArray <ResourceModel *> *) recArr;

- (void)installResourceWith:(ResourceModel *) resourceModel;

@end

#pragma mark - ResourceModel
@interface ResourceModel : NSObject

@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *icoUrl;
@property (nonatomic, copy) NSString *moduleName;
@property (nonatomic, copy) NSString *titleName;
//
@property (nonatomic, copy) NSString *sourceUrl;
@property (nonatomic, copy) NSString *version;

@property (nonatomic, copy) NSString *fileName;// 资源文名
@property (nonatomic, copy) NSString *filePath;// 资源文件存储的本地路径

@property (nonatomic, assign) ResourceType resourceType;// 资源的状态

// block
// 资源状态改变对调的block
@property (nonatomic, copy) void(^changeResourceTypeBlock)(ResourceType resourceType);
// 下载的进度
@property (nonatomic, copy) void(^changeProgressBlock)(CGFloat progress);

// func

// 模型中回调当前数据下载状态的block



@end

NS_ASSUME_NONNULL_END
