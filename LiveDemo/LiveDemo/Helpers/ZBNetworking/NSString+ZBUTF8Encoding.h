//
//  NSString+ZBUTF8Encoding.h
//  BaseProject
//
//  Created by bigfish on 2018/11/1.
//  Copyright © 2018 bigfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ZBUTF8Encoding)
/**
 UTF8
 
 @param urlString The url string before encoding
 @return Return the encoded url string
 */
+ (NSString *)zb_stringUTF8Encoding:(NSString *)urlString;

/**
 Splicing of the url string with the parameters parameter
 
 @param urlString url
 @param parameters parameters
 @return Return the spliced url string
 */
+ (NSString *)zb_urlString:(NSString *)urlString appendingParameters:(id)parameters;
@end


