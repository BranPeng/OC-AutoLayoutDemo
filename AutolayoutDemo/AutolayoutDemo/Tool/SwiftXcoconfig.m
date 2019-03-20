//
//  SwiftXcoconfig.m
//  RNContainer
//
//  Created by Binfeng Peng - Vendor on 2019/1/23.
//  Copyright © 2019年 Facebook. All rights reserved.
//

#import "SwiftXcoconfig.h"
#include <netdb.h>

#include <sys/socket.h>

#include <arpa/inet.h>

@implementation SwiftXcoconfig
singleton_implementation(SwiftXcoconfig)

+ (NSString *)getIpWithAdress:(NSString *)adress domin:(NSString *)domin{
  if ([adress containsString:domin]) {
    NSArray *domins = [adress componentsSeparatedByString:domin];
    if (domins.count > 1) {
      NSString *ipString = [SwiftXcoconfig getIPAddressByHostName:domin];
      NSString *ip = [NSString stringWithFormat:@"%@%@%@", domins[0], ipString, domins[1]];
      return ip;
    }
  }
  return adress;
}

//思路：1.gethostbyname(szname);取得主机信息结构体

//     2.memcpy(&ip_addr,phot->h_addr_list[0],4);从主机信息结构体中取出需要的32位ip地址ip_addr（二进制的）

//     3.inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));//将二进制整数转换为点分十进制
#pragma mark 域名解析ip
+ (NSString*)getIPAddressByHostName:(NSString*)strHostName
{
  //hostent是一个结构体，记录主机的相关信息，该结构记录主机的信息，包括主机名、别名、地址类型、地址长度和地址列表。
  
  //struct hostent *gethostbyname(const char *name)，gethostbyname函数根据域名解析出服务器的ip地址，它返回一个结构体struct hostent
  
  const char* szname = [strHostName UTF8String];
  
  struct hostent* phot ;
  
  
  
  @try
  
  {
    
    phot = gethostbyname(szname);
    
  }
  
  @catch (NSException * e)
  
  {
    
    return nil;
    
  }
  
  
  
  //    struct in_addr {
  
  //        in_addr_t s_addr;
  
  //    };
  
  
  
  //    结构体in_addr 用来表示一个32位的IPv4地址.
  
  //    in_addr_t 一般为 32位的unsigned int，其字节顺序为网络顺序（network byte ordered)，即该无符号整数采用大端字节序[1]  。.
  
  //    其中每8位代表一个IP地址位中的一个数值.
  
  //    例如192.168.3.144记为0xc0a80390,其中 c0 为192 ,a8 为 168, 03 为 3 , 90 为 144
  
  //    打印的时候可以调用inet_ntoa()函数将其转换为char *类型.
  
  
  
  struct in_addr ip_addr;
  
  if(phot)
    
  {
    
    memcpy(&ip_addr,phot->h_addr_list[0],4);
    
    //void *memcpy(void *dest, const void *src, size_t n);
    
    //从源src所指的内存地址的起始位置开始拷贝n个字节到目标dest所指的内存地址的起始位置中
    
    //h_addr_list[0]里4个字节,每个字节8位，此处为一个数组，一个域名对应多个ip地址或者本地时一个机器有多个网卡
    
  }
  
  else
    
  {
    
    return nil;
    
  }
  
  
  
  
  
  char ip[20] = {0};
  
  inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));//将二进制整数转换为点分十进制
  
  
  
  NSString* strIPAddress = [NSString stringWithUTF8String:ip];
  NSLog(@"ip02=====%@",strIPAddress);
  return strIPAddress;
  
}

///根据域名获取ip地址 - 可以用于控制APP的开关某一个入口，比接口方式速度快的多
+ (NSString*)getIPWithHostName:(const NSString*)hostName {
  const char *hostN= [hostName UTF8String];
  struct hostent* phot;
  @try {
    phot = gethostbyname(hostN);
  } @catch (NSException *exception) {
    return nil;
  }
  struct in_addr ip_addr;
  if (phot == NULL) {
    NSLog(@"获取失败");
    return nil;
  }
  memcpy(&ip_addr, phot->h_addr_list[0], 4);
  char ip[20] = {0}; inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
  NSString* strIPAddress = [NSString stringWithUTF8String:ip];
  NSLog(@"ip=====%@",strIPAddress);
  return strIPAddress;
}

//根据域名获取ip地址
+ (NSString*)getIPAddressWithHostName:(NSString*)strHostName
{
  const char* szname = [strHostName UTF8String];
  struct hostent* phot ;
  @try
  {
    phot = gethostbyname(szname);
  }
  @catch (NSException * e)
  {
    return nil;
  }
  
  struct in_addr ip_addr;
  //h_addr_list[0]里4个字节,每个字节8位，此处为一个数组，一个域名对应多个ip地址或者本地时一个机器有多个网卡
  memcpy(&ip_addr,phot->h_addr_list[0],4);
  
  char ip[20] = {0};
  inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
  
  NSString* strIPAddress = [NSString stringWithUTF8String:ip];
  NSLog(@"ip12=====%@",strIPAddress);
  return strIPAddress;
}

@end
