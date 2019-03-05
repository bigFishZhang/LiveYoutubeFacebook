//
//  LiveViewModel.m
//  LiveDemo
//
//  Created by bigfish on 2019/1/29.
//  Copyright © 2019 zzb. All rights reserved.
//
/*
 // Youtube创建直播
 //(1) 创建Broadcast
 @property (nonatomic,strong) RACCommand *creatYoutubeBroadcastCommand;
 //(2) 创建LiveStream
 @property (nonatomic,strong) RACCommand *creatYoutubeLiveStreamCommand;
 //(3) 绑定Broadcast && LiveStream
 @property (nonatomic,strong) RACCommand *bindLiveStreamWithBoardCastCommand;
 //(4) 获取直播间id信息
 @property (nonatomic,strong) RACCommand *fetchBroadCasstCommand;
 //(5) 获取直播URL信息
 @property (nonatomic,strong) RACCommand *fetchLiveStreamCommand;
 //(6) 通过rul 进行推流后 检查直播状态 把直播间状态改成live 正式开始直播
 @property (nonatomic,strong) RACCommand *transitionYoutubeLiveStatusCommand;
 //(7)  结束直播
 @property (nonatomic,strong) RACCommand *stopYoutubeLiveStreamCommand;
 
 // Facebook创建直播
 //(1) 创建直播获取URL，自行推流
 @property (nonatomic,strong) RACCommand *creatFacebookBroadcastCommand;

 */

#import "LiveViewModel.h"

@implementation LiveViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    
    self.creatFacebookBroadcastCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
            
            //1
            FBSDKGraphRequest *UserIDRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                                 parameters:
                                                @{@"fields": @"id, name",}
                                                                                 HTTPMethod:@"GET"];
            //2
            [UserIDRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                        id requestResult, NSError *requestError) {
                if (requestError) {
                    NSLog(@"request fb user id failed%@",requestError);
                    NSMutableDictionary *result = [NSMutableDictionary new];
                    [result setObject:requestError.localizedDescription forKey:@"msg"];
                    [subscriber sendNext:result];
                    [subscriber sendCompleted];
                }else {
                    NSDictionary *userInfo = (NSDictionary *)requestResult;
                    NSLog(@"facebook user info: %@", userInfo);
                    NSString * userId = userInfo[@"id"];
                    //3
                    FBSDKGraphRequest *liveRequest = [[FBSDKGraphRequest alloc]
                                                      initWithGraphPath:[NSString stringWithFormat:@"%@/live_videos", userId]
                                                      parameters:@{
                                                                   @"description":@"Hello  World!",
                                                                   @"title":@"Hello  World!",
                                                                   @"privacy":@{@"value":@"EVERYONE"},
                                                                   }
                                                      HTTPMethod:@"POST"];
                    [liveRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *liveConnection,
                                                              id liveRequest, NSError *liveError) {
                        if (liveError) {
                            NSLog(@"request fb user id failed %@",liveError);
                            NSMutableDictionary *result = [NSMutableDictionary new];
                            [result setObject:liveError.localizedDescription forKey:@"msg"];
                            [subscriber sendNext:result];
                            [subscriber sendCompleted];
                        }else{
                            NSDictionary *streamInfo = (NSDictionary *)liveRequest;
                            NSLog(@"facebook live info: %@", streamInfo);
                            NSMutableDictionary *result = [NSMutableDictionary new];
                            [result setObject:NET_WORK_SUCCESS forKey:@"msg"];
                            [result setObject:streamInfo forKey:@"streamInfo"];
                            [subscriber sendNext:result];
                            [subscriber sendCompleted];
                        }
                    }];
                }
            }];
            return nil;
        }];
    }];
    
    
    // ==============================  youtube   ==============================
    
    self.creatYoutubeBroadcastCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
            
            [ZBRequestManager requestWithConfig:^(ZBURLRequest *request) {
                request.URLString=[NSString stringWithFormat:@"%@&key=%@",YT_API_CREATE_BROADCAST,API_KEY];
                request.methodType=ZBMethodTypePOST;
                request.apiType=ZBRequestTypeRefresh;
                request.requestSerializer = ZBJSONRequestSerializer;
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                NSTimeInterval secondsInEightHours = 1 * 60 ;
                NSDate *dateEightHoursAhead = [[NSDate date] dateByAddingTimeInterval:secondsInEightHours];
                NSString *dateString = [formatter stringFromDate:dateEightHoursAhead];
                NSString *time = [NSString stringWithFormat:@"%@+00:00",dateString];
                NSNumber *noMonitorStream = [NSNumber numberWithBool:NO];
                NSNumber *noDvr = [NSNumber numberWithBool:NO];
                request.parameters = @{ @"snippet": @{ @"title":@"Hello  World!",
                                                       @"scheduledStartTime":time,
                                                       @"description":@"Hello  World!"},
                                        @"status": @{ @"privacyStatus": @"public"},
                                        @"contentDetails":@{@"monitorStream":@{@"enableMonitorStream":noMonitorStream},
                                                            @"latencyPreference":@"ultraLow",//Ultra low delay mode
                                                            @"enableDvr": noDvr}
                                        };
            } success:^(id responseObject, ZBApiType type, BOOL isCache) {
                NSDictionary *re = responseObject;
                NSString *boardingcastId = re[@"id"];
                NSMutableDictionary *result = [NSMutableDictionary new];
                [result setObject:boardingcastId forKey:@"boardingcastId"];
                [result setObject:NET_WORK_SUCCESS forKey:@"msg"];
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                NSMutableDictionary *result = [NSMutableDictionary new];
                [result setObject:error.localizedDescription forKey:@"msg"];
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }];
    
    self.creatYoutubeLiveStreamCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(NSString *boardingcastId) {
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
            
            [ZBRequestManager requestWithConfig:^(ZBURLRequest *request) {
                request.URLString=[NSString stringWithFormat:@"%@&key=%@",YT_API_CREATE_LIVESTREAM,API_KEY];
                request.methodType=ZBMethodTypePOST;
                request.apiType=ZBRequestTypeRefresh;
                request.requestSerializer = ZBJSONRequestSerializer;
                request.parameters = @{
                                       @"snippet": @{ @"title": @"Hello Nuvelon Mirror",
                                                      @"description": @"Nuvelon Mirror"},
                                       @"cdn": @{ @"resolution": @"1080p",
                                                  @"frameRate": @"30fps" ,
                                                  @"ingestionType":@"rtmp"},
                                       @"ingestionInfo": @{ @"streamName": @"NuvelonMirror"}
                                       };
            } success:^(id responseObject, ZBApiType type, BOOL isCache) {
                NSDictionary *re = responseObject;
                NSString *boardingcastId = re[@"id"];
                NSMutableDictionary *result = [NSMutableDictionary new];
                [result setObject:boardingcastId forKey:@"liveStreamId"];
                [result setObject:NET_WORK_SUCCESS forKey:@"msg"];
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                NSLog(@" error %@",error.localizedDescription);
                NSMutableDictionary *result = [NSMutableDictionary new];
                [result setObject:error.localizedDescription forKey:@"msg"];
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }];
    
    self.bindLiveStreamWithBoardCastCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(NSDictionary * bindInfo) {

        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
            
            [ZBRequestManager requestWithConfig:^(ZBURLRequest *request) {
                NSString *liveStreamId = bindInfo[@"liveStreamId"];
                NSString *boardingcastId = bindInfo[@"boardingcastId"];
                request.URLString=[NSString stringWithFormat:@"%@&key=%@&id=%@&streamId=%@",YT_API_CREATE_BIND,API_KEY,boardingcastId,liveStreamId];;
                request.methodType=ZBMethodTypePOST;
                request.apiType=ZBRequestTypeRefresh;
                request.requestSerializer = ZBJSONRequestSerializer;
            } success:^(id responseObject, ZBApiType type, BOOL isCache) {
                NSMutableDictionary *result = [NSMutableDictionary new];
                [result setObject:NET_WORK_SUCCESS forKey:@"msg"];
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                NSLog(@" error %@",error.localizedDescription);
                NSMutableDictionary *result = [NSMutableDictionary new];
                [result setObject:error.localizedDescription forKey:@"msg"];
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }];
    
    
    self.fetchBroadCasstCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(NSDictionary * bindInfo) {
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
            
            [ZBRequestManager requestWithConfig:^(ZBURLRequest *request) {
                NSString *boardingcastId = bindInfo[@"boardingcastId"];
                request.URLString=[NSString stringWithFormat:@"%@&key=%@&id=%@",YT_API_GET_BROADCASTS,API_KEY,boardingcastId];
                request.methodType=ZBMethodTypeGET;
                request.apiType=ZBRequestTypeRefresh;
                request.requestSerializer = ZBJSONRequestSerializer;
            } success:^(id responseObject, ZBApiType type, BOOL isCache) {
                NSMutableDictionary *result = [NSMutableDictionary new];
                [result setObject:NET_WORK_SUCCESS forKey:@"msg"];
                [result setObject:responseObject forKey:@"broadcastResponse"];
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                NSLog(@" error %@",error.localizedDescription);
                NSMutableDictionary *result = [NSMutableDictionary new];
                [result setObject:error.localizedDescription forKey:@"msg"];
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }];
    
    self.fetchLiveStreamCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(NSDictionary * bindInfo) {
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
            
            [ZBRequestManager requestWithConfig:^(ZBURLRequest *request) {
                NSString *liveStreamId = bindInfo[@"liveStreamId"];
                request.URLString=[NSString stringWithFormat:@"%@&key=%@&id=%@",YT_API_GET_LIVESTREAM,API_KEY,liveStreamId];
                request.methodType=ZBMethodTypeGET;
                request.apiType=ZBRequestTypeRefresh;
                request.requestSerializer = ZBJSONRequestSerializer;
            } success:^(id responseObject, ZBApiType type, BOOL isCache) {
                NSMutableDictionary *result = [NSMutableDictionary new];
                [result setObject:NET_WORK_SUCCESS forKey:@"msg"];
                [result setObject:responseObject forKey:@"liveStreamResponse"];
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                NSLog(@" error %@",error.localizedDescription);
                NSMutableDictionary *result = [NSMutableDictionary new];
                [result setObject:error.localizedDescription forKey:@"msg"];
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }];
    
    self.transitionYoutubeLiveStatusCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(NSDictionary * bindInfo) {
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
            
            [ZBRequestManager requestWithConfig:^(ZBURLRequest *request) {
                NSString *boardingcastId = bindInfo[@"boardingcastId"];
                NSString *status = bindInfo[@"status"];
                request.URLString=[NSString stringWithFormat:@"%@&key=%@&id=%@&broadcastStatus=%@",YT_API_GET_TRABSUTION,API_KEY,boardingcastId,status];
                request.methodType=ZBMethodTypePOST;
                request.apiType=ZBRequestTypeRefresh;
                request.requestSerializer = ZBJSONRequestSerializer;
            } success:^(id responseObject, ZBApiType type, BOOL isCache) {
                NSMutableDictionary *result = [NSMutableDictionary new];
                [result setObject:NET_WORK_SUCCESS forKey:@"msg"];
                [result setObject:responseObject forKey:@"responseObject"];
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                NSLog(@" transitionYoutubeLiveStatusCommand error %@",error.localizedDescription);
                NSMutableDictionary *result = [NSMutableDictionary new];
                [result setObject:error.localizedDescription forKey:@"msg"];
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }];
    
    
    self.stopYoutubeLiveStreamCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(NSDictionary * bindInfo) {
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
            
            [ZBRequestManager requestWithConfig:^(ZBURLRequest *request) {
                NSString *boardingcastId = bindInfo[@"boardingcastId"];
                NSString *status = bindInfo[@"status"];
                request.URLString=[NSString stringWithFormat:@"%@&key=%@&id=%@&broadcastStatus=%@",YT_API_GET_TRABSUTION,API_KEY,boardingcastId,status];
                request.methodType=ZBMethodTypePOST;
                request.apiType=ZBRequestTypeRefresh;
                request.requestSerializer = ZBJSONRequestSerializer;
            } success:^(id responseObject, ZBApiType type, BOOL isCache) {
                NSMutableDictionary *result = [NSMutableDictionary new];
                [result setObject:NET_WORK_SUCCESS forKey:@"msg"];
                [result setObject:responseObject forKey:@"responseObject"];
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                NSLog(@" error %@",error.localizedDescription);
                NSMutableDictionary *result = [NSMutableDictionary new];
                [result setObject:error.localizedDescription forKey:@"msg"];
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }];

    
    
    
}

@end
