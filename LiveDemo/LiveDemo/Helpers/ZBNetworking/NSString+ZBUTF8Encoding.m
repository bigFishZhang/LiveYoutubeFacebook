//
//  NSString+ZBUTF8Encoding.m
//  BaseProject
//
//  Created by bigfish on 2018/11/1.
//  Copyright © 2018 bigfish. All rights reserved.
//

#import "NSString+ZBUTF8Encoding.h"
//#import ""

#import <UIKit/UIKit.h>


@implementation NSString (ZBUTF8Encoding)

+ (NSString *)zb_stringUTF8Encoding:(NSString *)urlString{
        return [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

+ (NSString *)zb_urlString:(NSString *)urlString appendingParameters:(id)parameters{
    if (parameters==nil) {
        return urlString;
    }else{
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSString *key in parameters) {
            id obj = [parameters objectForKey:key];
            NSString *str = [NSString stringWithFormat:@"%@=%@",key,obj];
            [array addObject:str];
        }
        
        NSString *parametersString = [array componentsJoinedByString:@"&"];
        return  [urlString stringByAppendingString:[NSString stringWithFormat:@"?%@",parametersString]];
    }
}

@end
