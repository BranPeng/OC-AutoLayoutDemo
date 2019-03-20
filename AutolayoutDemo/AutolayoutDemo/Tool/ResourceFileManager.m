//
//  ResourceFileManager.m
//  RNContainer
//
//  Created by Sijun Pan - Vendor on 2018/11/9.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "ResourceFileManager.h"

//#import <Zip>
#import "ZipArchive.h"
#import <AFNetworking/AFNetworking.h>

@interface ResourceFileManager()<NSFileManagerDelegate, SSZipArchiveDelegate>

// 要下载的资源数组
@property (nonatomic, strong) NSMutableArray <ResourceModel *> *resourceArr;

/**
 下载管理者
 */
@property (nonatomic, strong) AFHTTPSessionManager *downloadManager;

// 下载的任务
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic, strong) ResourceModel *downloadResourceModel;

@end

@implementation ResourceFileManager

#pragma mark - share
+ (ResourceFileManager *)shareInstance {
  static ResourceFileManager *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[ResourceFileManager alloc]init];
  });
  return shared;
}

#pragma mark init

- (instancetype)init {
  self = [super init];
  if (self) {
    self.resourceArr = [NSMutableArray array];
    self.downloadManager = [AFHTTPSessionManager manager];
  }
  return self;
}

#pragma mark - func

#pragma mark download

- (void)installResourceArrWith:(NSArray <ResourceModel *> *) recArr {
  for (NSInteger i = 0; i < recArr.count; i++) {
    ResourceModel *recModel = recArr[i];
    [self installResourceWith:recModel];
  }
}


- (void)installResourceWith:(ResourceModel *) resourceModel {
  // 首先判断是否能够下载
  if (resourceModel == nil && resourceModel.sourceUrl.length == 0) {
    // 这里回调无法下载的错误信息
    return;
  }
  if (resourceModel.resourceType == ResourceDowmloadTypeDownloading) {
    return;
  }
  if ([_resourceArr containsObject:resourceModel]) {
    return;
  }
  // 判断可以下载之后
  if (_downloadTask) {// 如果已有下载任务，那么就转存到下载资源数组中，等待下载
    resourceModel.resourceType = ResourceDowmloadTypeWillInstall;
    if (resourceModel.changeResourceTypeBlock != NULL) {
      resourceModel.changeResourceTypeBlock(_downloadResourceModel.resourceType);
    }
    [_resourceArr addObject:resourceModel];
  }else {
    [self downloadFileWith:resourceModel];
  }
}

- (void)downloadFileWith:(ResourceModel *) resourceModel{
  _downloadResourceModel = resourceModel;
  resourceModel.resourceType = ResourceDowmloadTypeDownloading;
  if (resourceModel.changeResourceTypeBlock != NULL) {
    resourceModel.changeResourceTypeBlock(_downloadResourceModel.resourceType);
  }
  //2.创建请求对象
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:resourceModel.sourceUrl]];
  
  //3.创建下载Task
  __weak typeof(self) weakSelf = self;
  _downloadTask = [_downloadManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
    CGFloat progressFloat = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
    //    NSLog(@"progress -- %f", progressFloat);
    if (weakSelf.downloadResourceModel.changeProgressBlock) {
      weakSelf.downloadResourceModel.changeProgressBlock(progressFloat);
    }
    
  } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
    
    NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
    
    NSLog(@"destination: %@\n%@",targetPath,fullPath);
    weakSelf.downloadResourceModel.fileName = response.suggestedFilename;
    return [NSURL fileURLWithPath:fullPath];
    
  } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
    NSLog(@"completionHandler: %@",filePath);
    if (error) {
      weakSelf.downloadResourceModel.resourceType = ResourceDowmloadTypeNotInstall;
      if (weakSelf.downloadResourceModel.changeProgressBlock != NULL) {
        weakSelf.downloadResourceModel.changeResourceTypeBlock(weakSelf.downloadResourceModel.resourceType);
      }
      // 清空当前下载任务和状态 准备下一个下载
      [weakSelf finishCurrentWork];
    }else {
      // 下载完成，解压并迁移文件
      [weakSelf changeFilePathWith:filePath.path];
    }
  }];
  //4.执行Task
  [_downloadTask resume];
}

- (void)changeFilePathWith:(NSString *)filePath {
  NSLog(@"filePath -- %@", filePath);
  // 解压文件到指定目录
  NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"/zipFile"];
  //  NSString *fullPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  NSLog(@"fullPath -- %@", fullPath);
  NSError *error;
  // 解压指定路径文件到指定目录中，并且以覆盖到方式写入到指定目录下
  BOOL isSuccess = [SSZipArchive unzipFileAtPath:filePath toDestination:fullPath overwrite:YES password:nil error:&error delegate:self];
  if (isSuccess) {// 解压文件成功
    NSLog(@"unzipPath = %@",fullPath);
    // 删除原来的压缩包
    NSError *removeError;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
      NSLog(@"删除原来的压缩包");
      BOOL isRemoveSuccess = [fm removeItemAtPath:filePath error:&removeError];
      NSLog(@"%@    ERROR: %@", isRemoveSuccess ? @"删除下载的压缩包成功" : @"删除下载的压缩包失败", removeError);
    }
    // 迁移文件
    NSError *mergeError;
    NSLog(@"self.downloadResourceModel.fileName:%@", self.downloadResourceModel.fileName);
    NSString *fileName = @"";
    NSArray *names = [self.downloadResourceModel.fileName componentsSeparatedByString:@"."];
    if (names.count > 0) {
      fileName = names[0];
    }
    NSString *newFilePath = [self createFileDirectories];
    if (!newFilePath) {
      newFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    }
    [self mergeContentsOfPath:fullPath intoPath:newFilePath error:&mergeError];
    NSLog(@"mergeError   %@",mergeError);
    if (mergeError != nil) {
      _downloadResourceModel.resourceType = ResourceDowmloadTypeNotInstall;
    }else {// 下载并且安装完成
      _downloadResourceModel.resourceType = ResourceDowmloadTypeInstalled;
      _downloadResourceModel.filePath = [newFilePath stringByAppendingPathComponent:_downloadResourceModel.fileName];
    }
  }else {
    NSLog(@"unzipError   %@",error);
    _downloadResourceModel.resourceType = ResourceDowmloadTypeNotInstall;
  }
  if (_downloadResourceModel.changeResourceTypeBlock != NULL) {
    _downloadResourceModel.changeResourceTypeBlock(_downloadResourceModel.resourceType);
  }
  // 清空当前下载任务和状态 准备下一个下载
  [self finishCurrentWork];
}

- (NSString *)createFileDirectories
{
  NSString *fileName = @"";
  NSArray *names = [self.downloadResourceModel.fileName componentsSeparatedByString:@"."];
  if (names.count > 0) {
    fileName = names[0];
  }
  NSString *newFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
  
  // 判断存放bundle的文件夹是否存在，不存在则创建对应文件夹
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  BOOL isDir = FALSE;
  
  BOOL isDirExist = [fileManager fileExistsAtPath:newFilePath
                                      isDirectory:&isDir];
  
  
  
  if(!(isDirExist && isDir))
    
  {
    
    BOOL bCreateDir = [fileManager createDirectoryAtPath:newFilePath
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:nil];
    
    if(!bCreateDir){
      
      NSLog(@"Create buncle Directory Failed.");
      return nil;
    } else {
      return newFilePath;
    }
  } else {
    return newFilePath;
  }
}

- (void)finishCurrentWork {
  // 清空当前下载任务和状态 准备下一个下载
  if (_downloadResourceModel) {
    [_resourceArr removeObject:_downloadResourceModel];
  }
  _downloadResourceModel = nil;
  _downloadTask = nil;
  // 判断待安装数组中是否还有，有则继续下载安装新的资源
  if (_resourceArr.count > 0) {
    ResourceModel *nextModel = _resourceArr.firstObject;
    // 继续新的下载
    if (_downloadResourceModel == nil) {
      [self downloadFileWith:nextModel];
    }
  }
}

- (void)mergeContentsOfPath:(NSString *)srcDir intoPath:(NSString *)dstDir error:(NSError**)err {
  
  NSLog(@"mergeContentsOfPath: %@\n intoPath: %@", srcDir, dstDir);
  NSFileManager *fm = [NSFileManager defaultManager];
  NSDirectoryEnumerator *srcDirEnum = [fm enumeratorAtPath:srcDir];
  NSString *subPath;
  while ((subPath = [srcDirEnum nextObject])) {
    
//    NSLog(@" subPath: %@", subPath);
    NSString *srcFullPath =  [srcDir stringByAppendingPathComponent:subPath];
    NSString *potentialDstPath = [dstDir stringByAppendingPathComponent:subPath];
    
    // Need to also check if file exists because if it doesn't, value of `isDirectory` is undefined.
    BOOL isDirectory = ([[NSFileManager defaultManager] fileExistsAtPath:srcFullPath isDirectory:&isDirectory] && isDirectory);
    
    // Create directory, or delete existing file and move file to destination
    if (isDirectory) {
//      NSLog(@"   create directory");
      [fm createDirectoryAtPath:potentialDstPath withIntermediateDirectories:YES attributes:nil error:err];
      if (err && *err) {
        NSLog(@"ERROR: %@", *err);
        return;
      }
    }
    else {
      if ([fm fileExistsAtPath:potentialDstPath]) {
//        NSLog(@"   removeItemAtPath");
        [fm removeItemAtPath:potentialDstPath error:err];
        if (err && *err) {
          NSLog(@"ERROR: %@", *err);
          return;
        }
      }
      
//      NSLog(@"   moveItemAtPath");
      [fm moveItemAtPath:srcFullPath toPath:potentialDstPath error:err];
      if (err && *err) {
        NSLog(@"ERROR: %@", *err);
        return;
      }
    }
  }
}

#pragma mark - SSZipArchiveDelegate
- (void)zipArchiveWillUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo {
  NSLog(@"将要解压。%@", path);
}
- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPat uniqueId:(NSString *)uniqueId {
  NSLog(@"解压完成！%@", path);
  //  NSLog(@"zipInfo -- %@", zipInfo);
  NSLog(@"unzippedPat -- %@", unzippedPat);
}

-(void)dealloc {
  NSLog(@"%s", __FUNCTION__);
}
@end

#pragma mark - ResourceModel
@implementation ResourceModel

@end

