//
//  ZBRequestManager.m
//  BaseProject
//
//  Created by bigfish on 2018/11/1.
//  Copyright © 2018 bigfish. All rights reserved.
//

#import "ZBRequestManager.h"
#import "ZBCacheManager.h"
#import "ZBURLRequest.h"
#import "NSString+ZBUTF8Encoding.h"

@implementation ZBRequestManager

#pragma mark - 配置请求
+ (void)requestWithConfig:(requestConfig)config
                  success:(requestSuccess)success
                  failure:(requestFailure)failure{
    [self requestWithConfig:config progress:nil success:success failure:failure];
}

+ (void)requestWithConfig:(requestConfig)config
                 progress:(progressBlock)progress
                  success:(requestSuccess)success
                  failure:(requestFailure)failure {
    ZBURLRequest *request=[[ZBURLRequest alloc]init];
    config ? config(request) : nil;
    [self sendRequest:request progress:progress success:success failure:failure];
}

+ (ZBBatchRequest *)sendBatchRequest:(batchRequestConfig)config
                             success:(requestSuccess)success
                             failure:(requestFailure)failure{
    return [self sendBatchRequest:config progress:nil success:success failure:failure];
}

+ (ZBBatchRequest *)sendBatchRequest:(batchRequestConfig)config
                            progress:(progressBlock)progress
                             success:(requestSuccess)success
                             failure:(requestFailure)failure{
    ZBBatchRequest *batchRequest=[[ZBBatchRequest alloc]init];
    config ? config(batchRequest) : nil;
    
    if (batchRequest.urlArray.count==0)return nil;
    [batchRequest.urlArray enumerateObjectsUsingBlock:^(ZBURLRequest *request , NSUInteger idx, BOOL *stop) {
        [self sendRequest:request progress:progress success:success failure:failure];
    }];
    return batchRequest;
}

#pragma mark - 发起请求
+ (void)sendRequest:(ZBURLRequest *)request
           progress:(progressBlock)progress
            success:(requestSuccess)success
            failure:(requestFailure)failure{
    
    if([request.URLString isEqualToString:@""]||request.URLString==nil)return;
    
    if (request.methodType==ZBMethodTypeUpload) {
        [self sendUploadRequest:request progress:progress success:success failure:failure];
    }else if (request.methodType==ZBMethodTypeDownLoad){
        [self sendDownLoadRequest:request progress:progress success:success failure:failure];
    }else{
        if ([UserDefaultUtil valueForKey:YT_ACCESS_TOKEN]) {
            NSString *authValue = [NSString stringWithFormat:@"Bearer %@", [UserDefaultUtil valueForKey:YT_ACCESS_TOKEN]];
            [request.mutableHTTPRequestHeaders setValue:authValue forKey:@"Authorization"];
        }else{
            NSLog(@"===== miss YT_ACCESS_TOKEN ===== ");
        }
        [self sendHTTPRequest:request progress:progress success:success failure:failure];
    }
}

+ (void)sendUploadRequest:(ZBURLRequest *)request
                 progress:(progressBlock)progress
                  success:(requestSuccess)success
                  failure:(requestFailure)failure{
    [[ZBRequestEngine defaultEngine] uploadWithRequest:request zb_progress:progress success:^(NSURLSessionDataTask *task, id responseObject) {
        success ? success(responseObject,0,NO) : nil;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure ? failure(error) : nil;
    }];
}

+ (void)sendDownLoadRequest:(ZBURLRequest *)request
                   progress:(progressBlock)progress
                    success:(requestSuccess)success
                    failure:(requestFailure)failure{
    [[ZBRequestEngine defaultEngine] downloadWithRequest:request progress:progress completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        failure ? failure(error) : nil;
        success ? success([filePath path],request.apiType,NO) : nil;
    }];
}

+ (void)sendHTTPRequest:(ZBURLRequest *)request
               progress:(progressBlock)progress
                success:(requestSuccess)success
                failure:(requestFailure)failure{
    
    NSString *key = [self keyWithParameters:request];
    if ([[ZBCacheManager sharedInstance]diskCacheExistsWithKey:key]&&request.apiType!=ZBRequestTypeRefresh&&request.apiType!=ZBRequestTypeRefreshMore){
        [[ZBCacheManager sharedInstance]getCacheDataForKey:key value:^(NSData *data,NSString *filePath) {
            id result=[self responsetSerializerConfig:request responseObject:data];
            success ? success(result ,request.apiType,YES) : nil;
        }];
    }else{
        [self dataTaskWithHTTPRequest:request progress:progress success:success failure:failure];
    }
}

+ (void)dataTaskWithHTTPRequest:(ZBURLRequest *)request
                       progress:(progressBlock)progress
                        success:(requestSuccess)success
                        failure:(requestFailure)failure{
    
    [[ZBRequestEngine defaultEngine]dataTaskWithMethod:request zb_progress:^(NSProgress * _Nonnull zb_progress) {
        progress ? progress(zb_progress) : nil;
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [self storeObject:responseObject request:request];
        id result=[self responsetSerializerConfig:request responseObject:responseObject];
        success ? success(result,request.apiType,NO) : nil;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure ? failure(error) : nil;
    }];
}

#pragma mark - 其他配置
+ (NSString *)keyWithParameters:(ZBURLRequest *)request{
    if (request.parametersfiltrationCacheKey.count>0) {
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:request.parameters];
        [mutableParameters removeObjectsForKeys:request.parametersfiltrationCacheKey];
        request.parameters =  [mutableParameters copy];
    }
    NSString *URLStringCacheKey;
    if (request.customCacheKey) {
        URLStringCacheKey=request.customCacheKey;
    }else{
        URLStringCacheKey=request.URLString;
    }
    return [NSString zb_stringUTF8Encoding:[NSString zb_urlString:URLStringCacheKey appendingParameters:request.parameters]];
}

+ (void)storeObject:(NSObject *)object
            request:(ZBURLRequest *)request{
    NSString * key= [self keyWithParameters:request];
    [[ZBCacheManager sharedInstance] storeContent:object forKey:key isSuccess:^(BOOL isSuccess) {
        if (isSuccess) {
           // NSLog(@"store successful");
        }else{
            //NSLog(@"store failure");
        }
    }];
}

+ (id)responsetSerializerConfig:(ZBURLRequest *)request responseObject:(id)responseObject{
    if (request.responseSerializer==ZBHTTPResponseSerializer) {
        return responseObject;
    }else{
        NSError *serializationError = nil;
        NSData *data = (NSData *)responseObject;
        // Workaround for behavior of Rails to return a single space for `head :ok` (a workaround for a bug in Safari), which is not interpreted as valid input by NSJSONSerialization.
        // See https://github.com/rails/rails/issues/1742
        BOOL isSpace = [data isEqualToData:[NSData dataWithBytes:" " length:1]];
        if (data.length > 0 && !isSpace) {
            id result=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serializationError];
            return result;
        } else {
            return nil;
        }
    }
}

+ (void)cancelRequest:(NSString *)URLString completion:(cancelCompletedBlock)completion{
    if([URLString isEqualToString:@""]||URLString==nil)return;
    [[ZBRequestEngine defaultEngine]cancelRequest:URLString completion:completion];
}

@end
