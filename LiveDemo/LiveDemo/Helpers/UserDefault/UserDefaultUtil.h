//
//  UserDefaultUtil.h
//  opsseeBaby
//
//  Created by zhangzb on 2018/2/28.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultUtil : NSObject
/**
 *  setObject方法
 *
 *  @param value     设置的value
 *  @param defaultName  key名字
 */
+ (void)setObject:(id)value forKey:(NSString *)defaultName;

/**
 *  objectForKey方法
 *
 *  @param defaultName     获取key对于的值
 */
+ (id)objectForKey:(NSString *)defaultName;

/**
 *  setValue方法
 *
 *  @param value     设置的value
 *  @param defaultName  key名字
 */
+ (void)setValue:(id)value forKey:(NSString *)defaultName;

/**
 *  valueForKey方法
 *
 *  @param defaultName     获取key对于的值
 */
+ (id)valueForKey:(NSString *)defaultName;

/**
 *  removeObjectForKey方法
 *
 *  @param key     要移除的key
 */
+(void)removeObjectForKey:(NSString*)key;

/**
 *  清除所有的存储信息
 *
 */
+(void)clearAll;

// dic 按照key排序
+ (NSArray *)dicCompare:(NSDictionary *)dic;
@end
