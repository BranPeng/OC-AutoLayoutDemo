//
//  AppModel.h
//  AutolayoutDemo
//
//  Created by Binfeng Peng - Vendor on 2019/2/26.
//  Copyright © 2019年 Binfeng Peng - Vendor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppModel : NSObject<NSCoding>

/* jsbundle 唯一标识 */
@property(nonatomic, copy) NSString *cid;
/* jsbundle 图标地址 */
@property(nonatomic, copy) NSString *iconUrl;
/* jsbundle 名称 */
@property(nonatomic, copy) NSString *moduleName;
/* jsbundle Android下载路径 */
@property(nonatomic, copy) NSString *sourceUrl;
/* jsbundle 标题 */
@property(nonatomic, copy) NSString *titleName;
/* jsbundle 版本号 */
@property(nonatomic, copy) NSString *version;
/* jsbundle iOS下载路径 */
@property(nonatomic, copy) NSString *iosBundle;
/* jsbundle 路径域名 */
@property(nonatomic, copy) NSString *domin;

+(instancetype)AppModelWithDict:(NSDictionary *)dict;
-(instancetype)initAppModelWithDict:(NSDictionary *)dict;
- (NSData *)archiverData;
+ (id)unarchiveData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
