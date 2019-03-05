//
//  ZBRequestConst.h
//  BaseProject
//
//  Created by bigfish on 2018/11/1.
//  Copyright © 2018 bigfish. All rights reserved.
//

#ifndef ZBRequestConst_h
#define ZBRequestConst_h
@class ZBURLRequest,ZBBatchRequest;

/**
 HTTP request type.
 */
typedef NS_ENUM(NSInteger,ZBMethodType) {
    /**GET*/
    ZBMethodTypeGET,
    /**POST*/
    ZBMethodTypePOST,
    /**Upload*/
    ZBMethodTypeUpload,
    /**DownLoad*/
    ZBMethodTypeDownLoad,
    /**PUT*/
    ZBMethodTypePUT,
    /**PATCH*/
    ZBMethodTypePATCH,
    /**DELETE*/
    ZBMethodTypeDELETE
};

/**
 Used to identify different types of requests
 add different type for different page requirements
 */
typedef NS_ENUM(NSInteger,ZBApiType) {
    /** rerequest: no cache read, rerequest */
    ZBRequestTypeRefresh,
    /** read cache: there is cache, read cache -- no cache, rerequest */
    ZBRequestTypeCache,
    /** load more: do not read the cache and rerequest */
    ZBRequestTypeRefreshMore,
    /** load more: has cache, reads cache - no cache, rerequests */
    ZBRequestTypeCacheMore,
//    /** details page: there is cache, read cache - no cache, rerequest */
//    ZBRequestTypeDetailCache,
//    /** custom items: have cache, read cache - no cache, rerequest */
//    ZBRequestTypeCustomCache
};

/**
 Format of request parameters. The default is HTTP
 */
typedef NS_ENUM(NSUInteger, ZBRequestSerializerType) {
    /** sets the request parameter to binary format */
    ZBHTTPRequestSerializer,
    /** sets the request parameter to JSON format */
    ZBJSONRequestSerializer
};

/**
 The format of the response data returned. The default is JSON
 */
typedef NS_ENUM(NSUInteger, ZBResponseSerializerType) {
    /** sets the response data to be in JSON format */
    ZBJSONResponseSerializer,
    /** sets the response data to binary format */
    ZBHTTPResponseSerializer
};


/** batch request configured blocks */
typedef void (^batchRequestConfig)(ZBBatchRequest * batchRequest);
/** request configured blocks */
typedef void (^requestConfig)(ZBURLRequest * request);
/** successful Block */
typedef void (^requestSuccess)(id responseObject,ZBApiType type,BOOL isCache);
/** Block of failed request */
typedef void (^requestFailure)(NSError * error);
/** Block of request progress */
typedef void (^progressBlock)(NSProgress * progress);
/** Block requested to cancel */
typedef void (^cancelCompletedBlock)(BOOL results,NSString * urlString);


#endif /* ZBRequestConst_h */
