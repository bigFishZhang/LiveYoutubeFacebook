//
//  ZBURLRequest.m
//  BaseProject
//
//  Created by bigfish on 2018/11/1.
//  Copyright © 2018 bigfish. All rights reserved.
//

#import "ZBURLRequest.h"
#import "ZBRequestManager.h"

#pragma mark - ZBURLRequest
@implementation ZBURLRequest

- (void)dealloc{
    NSLog(@"%s",__func__);
}

#pragma mark - Request header
- (void)setValue:(NSString *)value forHeaderField:(NSString *)field{
    if (value) {
        [self.mutableHTTPRequestHeaders setValue:value forKey:field];
    }
    else {
        [self removeHeaderForkey:field];
    }
}

- (NSString *)objectHeaderForKey:(NSString *)key{
    return  [self.mutableHTTPRequestHeaders objectForKey:key];
}

- (void)removeHeaderForkey:(NSString *)key{
    if(!key)return;
    [self.mutableHTTPRequestHeaders removeObjectForKey:key];
}

#pragma mark - Upload request parameters
- (void)addFormDataWithName:(NSString *)name fileData:(NSData *)fileData {
    ZBUploadData *formData = [ZBUploadData formDataWithName:name fileData:fileData];
    [self.uploadDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData {
    ZBUploadData *formData = [ZBUploadData formDataWithName:name fileName:fileName mimeType:mimeType fileData:fileData];
    [self.uploadDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name fileURL:(NSURL *)fileURL {
    ZBUploadData *formData = [ZBUploadData formDataWithName:name fileURL:fileURL];
    [self.uploadDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL {
    ZBUploadData *formData = [ZBUploadData formDataWithName:name fileName:fileName mimeType:mimeType fileURL:fileURL];
    [self.uploadDatas addObject:formData];
}

#pragma mark - Lazy loading

- (NSMutableDictionary *)mutableHTTPRequestHeaders{
    
    if (!_mutableHTTPRequestHeaders) {
        _mutableHTTPRequestHeaders  = [[NSMutableDictionary alloc]init];
    }
    return _mutableHTTPRequestHeaders;
}

- (NSMutableArray<ZBUploadData *> *)uploadDatas {
    if (!_uploadDatas) {
        _uploadDatas = [[NSMutableArray alloc]init];
    }
    return _uploadDatas;
}

@end

#pragma mark - ZBBatchRequest

@interface ZBBatchRequest()
/**
 *  Offline download column url container
 */
@property (nonatomic,strong) NSMutableArray *channelUrlArray;

/**
 *  Offline download column name container
 */
@property (nonatomic,strong) NSMutableArray *channelKeyArray;

@end

@implementation ZBBatchRequest

- (NSMutableArray *)batchUrlArray{
    return self.channelUrlArray;
}

- (NSMutableArray *)batchKeyArray{
    return self.channelKeyArray;
}

- (void)addObjectWithUrl:(NSString *)urlString{
    [self addObjectWithForKey:urlString isUrl:YES];
}

- (void)removeObjectWithUrl:(NSString *)urlString{
    [self removeObjectWithForkey:urlString isUrl:YES];
}

- (void)addObjectWithKey:(NSString *)key{
    [self addObjectWithForKey:key isUrl:NO];
}

- (void)removeObjectWithKey:(NSString *)key{
    [self removeObjectWithForkey:key isUrl:NO];
}

- (void)removeBatchArray{
    [self.batchUrlArray removeAllObjects];
    [self.batchKeyArray removeAllObjects];
}

- (BOOL)isAddForKey:(NSString *)key isUrl:(BOOL)isUrl{
    
    if (isUrl==YES) {
        @synchronized (self.channelUrlArray) {
            return  [self.channelUrlArray containsObject: key];
        }
    }else{
        @synchronized (self.channelKeyArray) {
            return  [self.channelKeyArray containsObject: key];
        }
    }
}

- (void)addObjectWithForKey:(NSString *)key isUrl:(BOOL)isUrl{
    if (isUrl==YES) {
        
        if ([self isAddForKey:key isUrl:isUrl]==1) {
            NSLog(@"已经包含该栏目URL");
        }else{
            @synchronized (self.channelUrlArray) {
                [self.channelUrlArray addObject:key];
            }
        }
    }else{
        
        if ([self isAddForKey:key isUrl:isUrl]==1) {
            NSLog(@"已经包含该栏目名字");
        }else{
            @synchronized (self.channelKeyArray ) {
                [self.channelKeyArray addObject:key];
            }
        }
    }
}

- (void)removeObjectWithForkey:(NSString *)key isUrl:(BOOL)isUrl{
    if (isUrl==YES) {
        if ([self isAddForKey:key isUrl:isUrl]==1) {
            @synchronized (self.channelUrlArray) {
                [self.channelUrlArray removeObject:key];
            }
        }else{
            NSLog(@"已经删除该栏目URL");
        }
        
    }else{
        
        if ([self isAddForKey:key isUrl:isUrl]==1) {
            @synchronized (self.channelKeyArray) {
                [self.channelKeyArray removeObject:key];
            }
        }else{
            NSLog(@"已经删除该栏目名字");
        }
    }
}

- (void)cancelbatchRequestWithCompletion:(cancelCompletedBlock)completion{
    if (_urlArray.count > 0) {
        [_urlArray enumerateObjectsUsingBlock:^(ZBURLRequest *request, NSUInteger idx, __unused BOOL *stop) {
            [ZBRequestManager cancelRequest:request.URLString completion:completion];
        }];
    }
}

- (NSMutableArray *)urlArray {
    if (!_urlArray) {
        _urlArray = [[NSMutableArray alloc]init];;
    }
    return _urlArray;
}

- (NSMutableArray *)channelUrlArray{
    
    if (!_channelUrlArray) {
        _channelUrlArray=[[NSMutableArray alloc]init];
    }
    return _channelUrlArray;
}

- (NSMutableArray *)channelKeyArray{
    
    if (!_channelKeyArray) {
        _channelKeyArray=[[NSMutableArray alloc]init];
    }
    return _channelKeyArray;
}

@end

#pragma mark - ZBUploadData

@implementation ZBUploadData

+ (instancetype)formDataWithName:(NSString *)name fileData:(NSData *)fileData {
    ZBUploadData *formData = [[ZBUploadData alloc] init];
    formData.name = name;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData {
    ZBUploadData *formData = [[ZBUploadData alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileURL:(NSURL *)fileURL {
    ZBUploadData *formData = [[ZBUploadData alloc] init];
    formData.name = name;
    formData.fileURL = fileURL;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL {
    ZBUploadData *formData = [[ZBUploadData alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileURL = fileURL;
    return formData;
}

@end
