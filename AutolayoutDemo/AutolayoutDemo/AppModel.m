//
//  AppModel.m
//  AutolayoutDemo
//
//  Created by Binfeng Peng - Vendor on 2019/2/26.
//  Copyright © 2019年 Binfeng Peng - Vendor. All rights reserved.
//

#import "AppModel.h"
#import "SwiftXcoconfig.h"

@implementation AppModel

//序列化
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_cid forKey:@"cid"];
    [aCoder encodeObject:_iconUrl forKey:@"iconUrl"];
    [aCoder encodeObject:_moduleName forKey:@"moduleName"];
    [aCoder encodeObject:_sourceUrl forKey:@"sourceUrl"];
    [aCoder encodeObject:_titleName forKey:@"titleName"];
    
    [aCoder encodeObject:_version forKey:@"version"];
    [aCoder encodeObject:_iosBundle forKey:@"iosBundle"];
    [aCoder encodeObject:_domin forKey:@"domin"];
}
//反序列化
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.cid= [aDecoder decodeObjectForKey:@"cid"];
        self.domin = [aDecoder decodeObjectForKey:@"domin"];
        self.iconUrl = [aDecoder decodeObjectForKey:@"iconUrl"];
        
        self.iconUrl = [SwiftXcoconfig getIpWithAdress:self.iconUrl domin:self.domin];
        
        self.moduleName = [aDecoder decodeObjectForKey:@"moduleName"];
        self.sourceUrl = [aDecoder decodeObjectForKey:@"sourceUrl"];
        self.titleName = [aDecoder decodeObjectForKey:@"titleName"];
        self.version = [aDecoder decodeObjectForKey:@"version"];
        self.iosBundle = [aDecoder decodeObjectForKey:@"iosBundle"];
        
        self.iosBundle = [SwiftXcoconfig getIpWithAdress:self.iosBundle domin:self.domin];
    }else{
        return nil;
    }
    return self;
}

+(instancetype)AppModelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initAppModelWithDict:dict];
}

-(instancetype)initAppModelWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.cid =[dict objectForKey:@"cid"];
        self.iconUrl =[dict objectForKey:@"iconUrl"];
        self.moduleName =[dict objectForKey:@"moduleName"];
        self.sourceUrl =[dict objectForKey:@"sourceUrl"];
        self.titleName =[dict objectForKey:@"titleName"];
        self.version =[dict objectForKey:@"version"];
        self.iosBundle =[dict objectForKey:@"iosBundle"];
        self.domin =[dict objectForKey:@"domin"];
    }
    return self;
}

#pragma mark     单个对象进行归档及反归档
//归档
- (NSData *)archiverData {

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:YES error:nil];
    return data;
}
//反归档
+ (id)unarchiveData:(NSData *)data {

    id appModel = [NSKeyedUnarchiver unarchivedObjectOfClass:[self class] fromData:data error:nil];
    return appModel;
}

@end
