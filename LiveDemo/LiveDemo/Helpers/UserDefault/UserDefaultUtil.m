//
//  UserDefaultUtil.m
//  opsseeBaby
//
//  Created by zhangzb on 2018/2/28.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import "UserDefaultUtil.h"

@implementation UserDefaultUtil

/**
 *  setObject方法
 *
 *  @param value     设置的value
 *  @param defaultName  key名字
 */
+ (void)setObject:(id)value forKey:(NSString *)defaultName{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:defaultName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

/**
 *  objectForKey方法
 *
 *  @param defaultName     获取key对于的值
 */
+ (id)objectForKey:(NSString *)defaultName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:defaultName];
}

/**
 *  setValue方法
 *
 *  @param value     设置的value
 *  @param defaultName  key名字
 */
+(void)setValue:(id)value forKey:(NSString *)defaultName
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:defaultName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  valueForKey方法
 *
 *  @param defaultName     获取key对于的值
 */
+(id)valueForKey:(NSString *)defaultName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:defaultName];
}

/**
 *  removeObjectForKey方法
 *
 *  @param key     要移除的key
 */
+(void)removeObjectForKey:(NSString *)key
{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  清除所有的存储信息
 *
 */
+(void)clearAll {
    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = userDefatluts.dictionaryRepresentation;;
    for(NSString* key in [dictionary allKeys]){
        if ([key isEqualToString:@"isFirst"]) {
            continue;
        }
        [userDefatluts removeObjectForKey:key];
        [userDefatluts synchronize];
    }
}


+ (NSArray *)dicCompare:(NSDictionary *)dic{
    NSMutableArray* result = [[NSMutableArray alloc]init];
    NSArray *keys = [dic allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    for (NSString *categoryId in sortedArray) {
        [result addObject:[dic objectForKey:categoryId]];
    }
    return result;
}

@end
