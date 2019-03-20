//
//  ConfigFileManager.m
//  RNContainer
//
//  Created by Binfeng Peng - Vendor on 2019/1/11.
//  Copyright © 2019年 Facebook. All rights reserved.
//

#import "ConfigFileManager.h"
#import <AFNetworking/AFNetworking.h>

// 用宏定义检测block是否可用!
#define BLOCK_EXEC(block, ...) if (block) { block(__VA_ARGS__); };
#define WEAKSELF typeof(self) __weak weakSelf = self;

@interface ConfigFileManager()
{
  // 下载句柄
  NSURLSessionDownloadTask *_downloadTask;
}

@property (nonatomic, strong) AFURLSessionManager *manager;

@end

@implementation ConfigFileManager

+ (ConfigFileManager *)shareInstance
{
  static ConfigFileManager *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[ConfigFileManager alloc] init];
  });
  
  return shared;
}

- (instancetype)init {
  self = [super init];
  if (self) {

    //默认配置
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //AFN3.0+基于封住URLSession的句柄
    _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  }
  return self;
}

- (void)downFileFromServer:(NSString *)urlString progressBlock:(DownloadProgressBlock)progressBlock completionHandlerBlock:(DownloadCompletionHandlerBlock)completionHandlerBlock{
  
  //远程地址
//  NSURL *URL = [NSURL URLWithString:urlString];
//  NSLog(@"urlString:%@", urlString);
  //请求
  NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:urlString parameters:nil error:nil];

//  NSURLRequest *request = [NSURLRequest requestWithURL:URL];
  [request setValue:@"identity" forHTTPHeaderField:@"Accept-Encoding"];
  
  //下载Task操作
  WEAKSELF;
  _downloadTask = [_manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
    
    // @property int64_t totalUnitCount;     需要下载文件的总大小
    // @property int64_t completedUnitCount; 当前已经下载的大小
    
    // 给Progress添加监听 KVO
//    NSLog(@"%f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
    // 回到主队列刷新UI
    dispatch_async(dispatch_get_main_queue(), ^{
      // 设置进度条的百分比
      
      float progress = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
      BLOCK_EXEC(progressBlock, progress);
      BLOCK_EXEC(weakSelf.progressBlock, progress);
    });
    
  } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
    
    //- block的返回值, 要求返回一个URL, 返回的这个URL就是文件的位置的路径
    
    /* 下载路径 */
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Announcement"];
//    NSString *filePath = [path stringByAppendingPathComponent:URL.lastPathComponent];
    
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
//    NSLog(@"path:%@", path);
//    NSLog(@"last:%@", URL.lastPathComponent);
    return [NSURL fileURLWithPath:path];
    
  } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
    //设置下载完成操作
//    NSLog(@"response:%@", response);
//    NSLog(@"filePath:%@", filePath);
    if (error == nil) {
      // filePath就是你下载文件的位置，你可以解压，也可以直接拿来使用
      NSString *imgFilePath = [filePath path];// 将NSURL转成NSString
      NSDictionary *configDic = [ConfigFileManager readLocalFileWithName:imgFilePath];
//      NSLog(@"configDic:%@", configDic);
      BLOCK_EXEC(completionHandlerBlock, configDic, error);
      BLOCK_EXEC(weakSelf.completionHandlerBlock, configDic, error);
      
      NSFileManager *fm = [NSFileManager defaultManager];
      if ([fm fileExistsAtPath:imgFilePath]) {
        [fm removeItemAtPath:imgFilePath error:nil];
      }
    }
  }];
  
  //开始下载
  [_downloadTask resume];
}

- (void)stopDownload{
  //暂停下载
  [_downloadTask suspend];
}

- (void)startDownload:(NSString *)urlString progressBlock:(DownloadProgressBlock)progressBlock completionHandlerBlock:(DownloadCompletionHandlerBlock)completionHandlerBlock {

  //网络监控句柄
//  AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager managerForDomain:@"util.yuanhengtech.cn"];
//
//  //要监控网络连接状态，必须要先调用单例的startMonitoring方法
//  [manager startMonitoring];
//
//  [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//    //status:
//    //AFNetworkReachabilityStatusUnknown          = -1,  未知
//    //AFNetworkReachabilityStatusNotReachable     = 0,   未连接
//    //AFNetworkReachabilityStatusReachableViaWWAN = 1,   3G
//    //AFNetworkReachabilityStatusReachableViaWiFi = 2,   无线连接
//    NSLog(@"%d", status);
//    if (status == AFNetworkReachabilityStatusNotReachable) {
//
//    } else {
//
//    }
//  }];
//
//  NSLog(@"networkReachabilityStatus:%d", manager.networkReachabilityStatus);
//  if (manager.reachable) {
//
//  }
//  NSLog(@"urlString:%@", urlString);
  //准备从远程下载文件.
  [self downFileFromServer:urlString progressBlock:progressBlock completionHandlerBlock:completionHandlerBlock];
}

// 读取本地JSON文件
+ (NSDictionary *)readLocalFileWithName:(NSString *)path {
  // 获取文件路径
//  NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
  // 将文件数据化
  NSData *data = [[NSData alloc] initWithContentsOfFile:path];
  // 对数据进行JSON格式化并返回字典形式
  return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

@end
