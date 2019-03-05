//
//  ZBRequestEngine.h
//  BaseProject
//
//  Created by bigfish on 2018/11/1.
//  Copyright © 2018 bigfish. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "ZBRequestConst.h"

/*
 Hard setting:
 1. The data returned by the server must be binary
 2. Certificate Settings
 3. Open chrysanthemum
 */
@interface ZBRequestEngine : AFHTTPSessionManager

+ (instancetype _Nullable )defaultEngine;

/**
 Initiating network request
 
 @param request ZBURLRequest
 @param zb_progress progress
 @param success Success callback
 @param failure Failure callback
 @return task
 */
- (NSURLSessionDataTask *_Nullable)dataTaskWithMethod:(ZBURLRequest *_Nullable)request
                                 zb_progress:(void (^_Nullable)(NSProgress * _Nonnull))zb_progress
                                              success:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                                              failure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

/**
 Upload file
 
 @param request ZBURLRequest
 @param zb_progress progress
 @param success Success callback
 @param failure Failure callback
 @return task
 */
- (NSURLSessionDataTask *_Nullable)uploadWithRequest:(ZBURLRequest *_Nullable)request
                                         zb_progress:(void (^_Nullable)(NSProgress * _Nonnull))zb_progress
                                             success:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                                             failure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

/**
 Download file
 
 @param request ZBURLRequest
 @param downloadProgressBlock progress
 @param completionHandler callback
 @return task
 */
- (NSURLSessionDownloadTask *_Nullable)downloadWithRequest:(ZBURLRequest *_Nullable)request
                                                  progress:(void (^_Nullable)(NSProgress * _Nullable downloadProgress)) downloadProgressBlock
                                         completionHandler:(void (^_Nullable)(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;

/**
 Cancel request task
 
 @param urlString           Protocol interfaces
 */
- (void)cancelRequest:(NSString *_Nullable)urlString  completion:(cancelCompletedBlock _Nullable )completion;


@end


