//
//  SwiftXcoconfig.h
//  RNContainer
//
//  Created by Binfeng Peng - Vendor on 2019/1/23.
//  Copyright © 2019年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

NS_ASSUME_NONNULL_BEGIN

@interface SwiftXcoconfig : NSObject
singleton_interface(SwiftXcoconfig)

+ (NSString*)getIPAddressByHostName:(NSString*)strHostName;
+ (NSString *)getIpWithAdress:(NSString *)adress domin:(NSString *)domin;
  
@end

NS_ASSUME_NONNULL_END
