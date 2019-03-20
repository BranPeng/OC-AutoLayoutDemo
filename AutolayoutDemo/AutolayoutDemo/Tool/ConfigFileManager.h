//
//  ConfigFileManager.h
//  RNContainer
//
//  Created by Binfeng Peng - Vendor on 2019/1/11.
//  Copyright © 2019年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DownloadProgressBlock)(float progress);
typedef void (^DownloadCompletionHandlerBlock)(NSDictionary *configDic, NSError * _Nullable error);

@interface ConfigFileManager : NSObject

+ (ConfigFileManager *)shareInstance;
- (void)startDownload:(NSString *)urlString progressBlock:(DownloadProgressBlock)progressBlock completionHandlerBlock:(DownloadCompletionHandlerBlock)completionHandlerBlock;

@property (nonatomic, copy) DownloadProgressBlock progressBlock;

@property (nonatomic, copy) DownloadCompletionHandlerBlock completionHandlerBlock;

@end

NS_ASSUME_NONNULL_END
