//
//  ZBURLRequest.h
//  BaseProject
//
//  Created by bigfish on 2018/11/1.
//  Copyright © 2018 bigfish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBRequestConst.h"

@class ZBUploadData;
@interface ZBURLRequest : NSObject
/**
 *  Used to identify different types of request state
 */
@property (nonatomic,assign) ZBApiType apiType;

/**
 *  Use to identify different types of requests
 */
@property (nonatomic,assign) ZBMethodType methodType;

/**
 *  The type of the request parameter
 */
@property (nonatomic,assign) ZBRequestSerializerType requestSerializer;

/**
 *  Type of response data
 */
@property (nonatomic,assign) ZBResponseSerializerType responseSerializer;

/**
 *  Interface (request address)
 */
@property (nonatomic,copy) NSString * _Nonnull URLString;

/**
 *  Provides external configuration parameters for use
 */
@property (nonatomic,strong) id __nullable parameters;

/**
 *  Custom cache key, used when URLString cannot be used as cache key
 */
@property (nonatomic,copy) NSString * _Nullable customCacheKey;

/**
 Filter the random parameters in the parameters
 */
@property (nonatomic,strong) NSArray * _Nullable parametersfiltrationCacheKey;

/**
 *  Set the timeout to 30 seconds by default
 *   The timeout interval, in seconds, for created requests. The default timeout interval is 30 seconds.
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  The storage path is only useful for downloading files
 */
@property (nonatomic,copy,nullable) NSString *downloadSavePath;

/**
 *  Provide data for upload requests
 */
@property (nonatomic, strong, nullable) NSMutableArray<ZBUploadData *> *uploadDatas;

/**
 *  The request object used to maintain the request header
 */
@property ( nonatomic, strong) NSMutableDictionary * _Nonnull mutableHTTPRequestHeaders;

/**
 *  Add request header
 *
 *  @param value value
 *  @param field field
 */
- (void)setValue:(NSString *_Nonnull)value forHeaderField:(NSString *_Nonnull)field;

/**
 *
 *  @param key request object
 *
 *  @return request object
 */
- (NSString *_Nonnull)objectHeaderForKey:(NSString *_Nonnull)key;

/**
 *  Delete the key of the request header
 *
 *  @param key key
 */

- (void)removeHeaderForkey:(NSString *_Nonnull)key;

//============================================================
- (void)addFormDataWithName:(NSString *_Nonnull)name
                   fileData:(NSData *_Nonnull)fileData;

- (void)addFormDataWithName:(NSString *_Nonnull)name
                   fileName:(NSString *_Nonnull)fileName
                   mimeType:(NSString *_Nonnull)mimeType
                   fileData:(NSData *_Nonnull)fileData;

- (void)addFormDataWithName:(NSString *_Nonnull)name
                    fileURL:(NSURL *_Nonnull)fileURL;

- (void)addFormDataWithName:(NSString *_Nonnull)name
                   fileName:(NSString *_Nonnull)fileName
                   mimeType:(NSString *_Nonnull)mimeType
                    fileURL:(NSURL *_Nonnull)fileURL;
@end


#pragma mark - ZBBatchRequest
/**
 Class for batch request
 */
@interface ZBBatchRequest : NSObject

/**
Request url queue container
 */
@property (nonatomic,strong) NSMutableArray * _Nullable urlArray;

/**
 *  @return urlArray url array
 */
- (NSMutableArray *_Nonnull)batchUrlArray;

/**
 *  @return urlArray an array of other parameters
 */
- (NSMutableArray *_Nonnull)batchKeyArray;

/**
 Offline downloads add the url to the request queue
 
 @param urlString Request address
 */
- (void)addObjectWithUrl:(NSString *_Nonnull)urlString;

/**
 Offline downloads remove urls from requests queue
 
 @param urlString Request address
 */
- (void)removeObjectWithUrl:(NSString *_Nonnull)urlString;

/**
 Offline downloads add additional column parameters to the container
 
 @param name Column name or other key
 */
- (void)addObjectWithKey:(NSString *_Nonnull)name;

/**
 Offline downloads remove other column parameters from the container
 
 @param name Request address or other key
 */
- (void)removeObjectWithKey:(NSString *_Nonnull)name;

/**
 Offline downloads Delete all request queues
 */
- (void)removeBatchArray;

/**
 The offline download determines whether the column url or other parameters have been added to the request container
 
 @param key   Request address or other parameters
 @param isUrl Whether url
 
 @return 1:0
 */
- (BOOL)isAddForKey:(NSString *_Nonnull)key isUrl:(BOOL)isUrl;

/**
Offline downloads add urls or other parameters to the request queue
 
 @param key   Request address or other parameters
 @param isUrl Whether url
 */
- (void)addObjectWithForKey:(NSString *_Nonnull)key isUrl:(BOOL)isUrl;

/**
Offline downloads queue urls or other parameters from the request
 
 @param key   Request address or other parameters
 @param isUrl Whether url
 */
- (void)removeObjectWithForkey:(NSString *_Nonnull)key isUrl:(BOOL)isUrl;

/**
Batch cancel request
 
 @param completion block The subsequent operation
 */
- (void)cancelbatchRequestWithCompletion:(cancelCompletedBlock _Nullable )completion;


@end


#pragma mark - ZBUploadData
/**
Class for uploading file data
*/

@interface ZBUploadData : NSObject
/**
The file corresponds to the field on the server
 */
@property (nonatomic, copy) NSString * _Nonnull name;
/**
 The file name
 */
@property (nonatomic, copy, nullable) NSString *fileName;
/**
 Image file type, example: PNG, jpeg...
 */
@property (nonatomic, copy, nullable) NSString *mimeType;

/**
 The data to be encoded and appended to the form data, and it is prior than `fileURL`.
 */
@property (nonatomic, strong, nullable) NSData *fileData;

/**
 The URL corresponding to the file whose content will be appended to the form, BUT, when the `fileData` is assigned，the `fileURL` will be ignored.
 */
@property (nonatomic, strong, nullable) NSURL *fileURL;



// note: neither "fileData" nor "fileURL" should be "nil",
// and "fileName" and "mimeType" must be "nil," or both be assigned,

+ (instancetype _Nonnull )formDataWithName:(NSString *_Nonnull)name
                                  fileData:(NSData *_Nonnull)fileData;

+ (instancetype _Nonnull )formDataWithName:(NSString *_Nonnull)name
                                  fileName:(NSString *_Nonnull)fileName
                                  mimeType:(NSString *_Nonnull)mimeType
                                  fileData:(NSData *_Nonnull)fileData;

+ (instancetype _Nonnull )formDataWithName:(NSString *_Nonnull)name
                                   fileURL:(NSURL *_Nonnull)fileURL;

+ (instancetype _Nonnull )formDataWithName:(NSString *_Nonnull)name
                                  fileName:(NSString *_Nonnull)fileName
                                  mimeType:(NSString *_Nonnull)mimeType
                                   fileURL:(NSURL *_Nonnull)fileURL;

@end



