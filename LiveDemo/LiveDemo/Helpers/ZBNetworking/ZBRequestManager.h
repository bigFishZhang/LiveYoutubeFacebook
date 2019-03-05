//
//  ZBRequestManager.h
//  BaseProject
//
//  Created by bigfish on 2018/11/1.
//  Copyright © 2018 bigfish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBRequestEngine.h"

@interface ZBRequestManager : NSObject

/**
 *  Request method GET/POST/PUT/PATCH/DELETE
 *
 *  @param config           requests configuration  Block
 *  @param success          requests successful
 *  @param failure          requests failure Block
 */
+ (void)requestWithConfig:(requestConfig)config  success:(requestSuccess)success failure:(requestFailure)failure;

/**
 *  Request method GET/POST/PUT/PATCH/DELETE/Upload/DownLoad
 *
 *  @param config           requests configuration Block
 *  @param progress         requests progress  Block
 *  @param success          requests successful  Block
 *  @param failure          requests failure Block
 */
+ (void)requestWithConfig:(requestConfig)config  progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure;

/**
 *  Batch request method GET/POST/PUT/PATCH/DELETE
 *
 *  @param config           requests configuration Block
 *  @param success          requests successful  Block
 *  @param failure          requests failure Block
 */
+ (ZBBatchRequest *)sendBatchRequest:(batchRequestConfig)config success:(requestSuccess)success failure:(requestFailure)failure;

/**
 *  Batch request method GET/POST/PUT/PATCH/DELETE/Upload/DownLoad
 *
 *  @param config           requests configuration Block
 *  @param progress         requests progress  Block
 *  @param success          requests successful  Block
 *  @param failure          requests failure Block
 */
+ (ZBBatchRequest *)sendBatchRequest:(batchRequestConfig)config progress:(progressBlock)progress success:(requestSuccess)success failure:(requestFailure)failure;

/**
 Cancel request task
 
 @param URLString           Protocol interfaces
 @param completion          The subsequent operation
 */
+ (void)cancelRequest:(NSString *)URLString completion:(cancelCompletedBlock)completion;

@end

