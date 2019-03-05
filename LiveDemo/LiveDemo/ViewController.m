//
//  ViewController.m
//  LiveDemo
//
//  Created by bigfish on 2019/1/29.
//  Copyright © 2019 zzb. All rights reserved.
//

#import "ViewController.h"
#import "LiveViewModel.h"

typedef NS_ENUM(NSUInteger,LiveStatus){
    LiveStatusWait,//初始状态
    LiveStatusYTCreatingLive,//创建直播中
    LiveStatusFBCreatingLive,//创建直播中
    LiveStatusLive,//直播中
};

@interface ViewController ()<GIDSignInDelegate,GIDSignInUIDelegate>

/** youtube直播 */
@property (nonatomic,strong) GIDSignIn *YTSignIn;

/** facebook直播 */
@property (nonatomic,strong) FBSDKLoginManager *FBSignIn;

/** 直播状态 */
@property (nonatomic,assign) LiveStatus currentLiveStatus;

@property (nonatomic, strong) LiveViewModel *liveViewModel;

@property (nonatomic, strong) NSString *rtmpUrl;

@property (nonatomic,copy) NSString * liveStreamId;

@property (nonatomic,copy) NSString * boardingcastId;

@property (nonatomic,strong) NSMutableDictionary * broadCastDict;

@property (nonatomic,strong) NSMutableDictionary * streamDict;

@end

@implementation ViewController


#pragma mark - Life Cycle Methods
- (void)viewDidLoad
{
   [super viewDidLoad];
    
   [self initializationLiveStatus];
   
   [self binARC];
    
}


#pragma mark - Private Methods

- (void)initializationLiveStatus {
    
    self.currentLiveStatus = LiveStatusWait;
    
}

- (void)binARC {
    ZBWeak;
    
    //creat Facebook Broadcast Command
    [self.liveViewModel.creatFacebookBroadcastCommand.executionSignals.switchToLatest subscribeNext:^(NSDictionary *result) {
        NSString * reString =result[@"msg"];
        if ( [reString isEqualToString:NET_WORK_SUCCESS]) {
            NSLog(@"===============   creat Facebook Broadcast success   ===============");
            NSLog(@"Please start the live broadcast");
            weakSelf.rtmpUrl = result[@"streamInfo"][@"stream_url"];
            
            #pragma mark - TODO
            //push liveStream to rtmpUrl and check Live Status
            
        }else{
            NSLog(@"=============== creat Live stream failed!: %@",reString);
            weakSelf.currentLiveStatus = LiveStatusWait;
            [weakSelf facebookLogin];
        }
    }];
    
    [self.liveViewModel.creatYoutubeBroadcastCommand.executionSignals.switchToLatest subscribeNext:^(NSDictionary *result) {
        NSString * reString =result[@"msg"];
        if ( [reString isEqualToString:NET_WORK_SUCCESS]) {
            NSLog(@"=============== 1  creat Youtube Broadcast success   ===============");
            NSLog(@"creatYoutubeBroadcast: %@",reString);
            weakSelf.boardingcastId = nil;
            weakSelf.boardingcastId = result[@"boardingcastId"];
            if (weakSelf.boardingcastId) {
                [weakSelf.liveViewModel.creatYoutubeLiveStreamCommand execute:weakSelf.boardingcastId];
            }
        }else{
            NSLog(@"=============== creat Broadcast failed!: %@",reString);
            weakSelf.currentLiveStatus = LiveStatusWait;
            [weakSelf.YTSignIn signOut];
            // check login status
        }
    }];
    
    [self.liveViewModel.creatYoutubeLiveStreamCommand.executionSignals.switchToLatest subscribeNext:^(NSDictionary *result) {
        NSString * reString =result[@"msg"];
        if ( [reString isEqualToString:NET_WORK_SUCCESS]) {
            NSLog(@"=============== 2  creat Live Stream success   ===============");
            NSLog(@"creatYoutubeLiveStream: %@",reString);
            weakSelf.liveStreamId = nil;
            weakSelf.liveStreamId = result[@"liveStreamId"];
            if (weakSelf.liveStreamId && weakSelf.boardingcastId) {
                NSDictionary *bindInfo  = @{ @"liveStreamId":weakSelf.liveStreamId,
                                             @"boardingcastId":weakSelf.boardingcastId
                                             };
                [weakSelf.liveViewModel.bindLiveStreamWithBoardCastCommand execute:bindInfo];
            }
        }else{
            NSLog(@"=============== creat Live stream failed!: %@",reString);
            weakSelf.currentLiveStatus = LiveStatusWait;
        }
    }];
    
    [self.liveViewModel.bindLiveStreamWithBoardCastCommand.executionSignals.switchToLatest subscribeNext:^(NSDictionary *result) {
        NSString * reString =result[@"msg"];
        if ( [reString isEqualToString:NET_WORK_SUCCESS]) {
            NSLog(@"=============== 3  bind LiveStream With BoardCast success   ===============");
            if (weakSelf.liveStreamId && weakSelf.boardingcastId) {
                NSDictionary *bindInfo  = @{ @"liveStreamId":weakSelf.liveStreamId,
                                             @"boardingcastId":weakSelf.boardingcastId
                                             };
                [weakSelf.liveViewModel.fetchBroadCasstCommand execute:bindInfo];
                [weakSelf.liveViewModel.fetchLiveStreamCommand execute:bindInfo];
            }
        }else{
            NSLog(@"=============== bindLiveStreamWithBoardCastCommand failed!: %@",reString);
            weakSelf.currentLiveStatus = LiveStatusWait;
        }
    }];
    
    //不是必须的
    [self.liveViewModel.fetchBroadCasstCommand.executionSignals.switchToLatest subscribeNext:^(NSDictionary *result) {
        NSString * reString =result[@"msg"];
        if ( [reString isEqualToString:NET_WORK_SUCCESS]) {
            NSLog(@"=============== 4  fetch BroadCasst info  success   ===============");
            //save broadcast info
            weakSelf.broadCastDict = result[@"broadcastResponse"][@"items"][0];
        }else{
            NSLog(@"=============== fetchBroadCasstCommand failed!: %@",reString);
            weakSelf.currentLiveStatus = LiveStatusWait;
        }
    }];
    
    [self.liveViewModel.fetchLiveStreamCommand.executionSignals.switchToLatest subscribeNext:^(NSDictionary *result) {
        NSString * reString =result[@"msg"];
        if ( [reString isEqualToString:NET_WORK_SUCCESS]) {
            NSLog(@"=============== 5  fetch LiveStream info  success   ===============");
            weakSelf.streamDict = result[@"liveStreamResponse"];
            NSString* ingestionAddress = weakSelf.streamDict[@"items"][0][@"cdn"][@"ingestionInfo"][@"ingestionAddress"];
            NSString* streamName = weakSelf.streamDict[@"items"][0][@"cdn"][@"ingestionInfo"][@"streamName"];
            weakSelf.rtmpUrl = [NSString stringWithFormat:@"%@/%@",ingestionAddress,streamName];
            #pragma mark - TODO
            //1 往 rtmpUrl 推流
            //2 循环调用 transitionYoutubeLiveStatusCommand 修改直播状态（中间根据业务需求可以做预览功能） 直到直播状态是 liveStarting
            
        }else{
            NSLog(@"=============== fetchLiveStreamCommand failed!: %@",reString);
            weakSelf.currentLiveStatus = LiveStatusWait;
            
        }
    }];
    
    [self.liveViewModel.transitionYoutubeLiveStatusCommand.executionSignals.switchToLatest subscribeNext:^(NSDictionary *result) {
        NSString * reString =result[@"msg"];
        if ( [reString isEqualToString:NET_WORK_SUCCESS]) {
            NSString *lifeCycleStatus =result[@"responseObject"][@"status"][@"lifeCycleStatus"];
            if ([lifeCycleStatus isEqualToString:@"liveStarting"]){
                NSLog(@"！！！！！!!!！！！！！！！Begin to live！！！！！！！！！！！！！！！");
                weakSelf.currentLiveStatus = LiveStatusLive;
            }else{
                
                 //2 循环调用 transitionYoutubeLiveStatusCommand 修改直播状态（中间根据业务需求可以做预览功能） 直到直播状态是 liveStarting
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    NSDictionary *bindInfo =@{
//                                              @"status":@"live", //修改直播状态为 live
//                                              @"boardingcastId":weakSelf.boardingcastId
//                                              };
//                    [weakSelf.liveViewModel.transitionYoutubeLiveStatusCommand execute:bindInfo];
//                });
            }
        }else{
            //2 循环调用 transitionYoutubeLiveStatusCommand 修改直播状态（中间根据业务需求可以做预览功能） 直到直播状态是 liveStarting
            //                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //                    NSDictionary *bindInfo =@{
            //                                              @"status":@"live", //修改直播状态为 live
            //                                              @"boardingcastId":weakSelf.boardingcastId
            //                                              };
            //                    [weakSelf.liveViewModel.transitionYoutubeLiveStatusCommand execute:bindInfo];
            //                });
        }
    }];
    
    [self.liveViewModel.stopYoutubeLiveStreamCommand.executionSignals.switchToLatest subscribeNext:^(NSDictionary *result) {
        NSString * reString =result[@"msg"];
        if ( [reString isEqualToString:NET_WORK_SUCCESS]) {
            NSLog(@"Live closed ... success");
        }else{
            NSLog(@"Live closed ... failed! %@",result);
        }
    }];
}


//如果要切换账号的话，要调用注销方法，不然的话会一直自动登录
- (void)facebookLogin {
    
    [self.FBSignIn logInWithPublishPermissions:@[@"publish_video"]
                            fromViewController:nil
                                       handler:^(FBSDKLoginManagerLoginResult *result,
                                                 NSError *error) {
            if (error) {
                    
              NSLog(@"facebook auth failed");
                
            }else if (result.isCancelled) {
                                        
              NSLog(@"facebook auth canceled");
                
            }else{
              NSLog(@"facebook auth success");
                
              [self.liveViewModel.creatFacebookBroadcastCommand execute:nil];
            }
    }];
}

- (void)youtubeLogin {
    
    if(self.YTSignIn.hasAuthInKeychain){
        NSLog(@"Cached, login in quickly");
        [self.YTSignIn signInSilently];
    }else{
        NSLog(@"NO cached,jump to login");
        [self.YTSignIn signIn];
    }
}

- (void)finishYoutuLive{
    
    NSDictionary *bindInfo =@{
                              @"status":@"complete",
                              @"boardingcastId":self.boardingcastId
                              };
    [self.liveViewModel.stopYoutubeLiveStreamCommand execute:bindInfo];
}
#pragma mark - Delegate Methods
//Youtube 登录返回代理方法
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error == nil) {//登录成功
        NSLog(@"Youtube login success : %@",user);
        [UserDefaultUtil setValue:user.authentication.accessToken forKey:YT_ACCESS_TOKEN];
        // do next job
        [self.liveViewModel.creatYoutubeBroadcastCommand execute:nil];
        
    }else{//登录失败
        NSLog(@"Youtube login error   : %@",error);
        [self.YTSignIn signOut];
    }
}


#pragma mark - Network




#pragma mark - IBAction Methods

- (IBAction)youtubeIBAction:(id)sender {
    [self youtubeLogin];
}

- (IBAction)facebookIBAction:(id)sender {
    [self facebookLogin];
}

#pragma mark - Lazy Methods

- (GIDSignIn *)YTSignIn {
    if (!_YTSignIn) {
        _YTSignIn = [GIDSignIn sharedInstance];
        _YTSignIn.delegate = self;
        _YTSignIn.uiDelegate = self;
        _YTSignIn.clientID  = CLIENT_ID;
        //登录界面要获取的权限，根据需求进行修改
        _YTSignIn.scopes  =  @[@"https://www.googleapis.com/auth/youtube"];
    }
    return _YTSignIn;
}

- (FBSDKLoginManager *)FBSignIn {
    if (!_FBSignIn) {
        _FBSignIn = [[FBSDKLoginManager alloc] init];
        _FBSignIn.loginBehavior = FBSDKLoginBehaviorNative;
    }
    return _FBSignIn;
}

- (LiveViewModel *)liveViewModel {
    if (!_liveViewModel) {
        _liveViewModel = [[LiveViewModel alloc] init];
    }
    return _liveViewModel;
}

- (NSMutableDictionary *)broadCastDict
{
    if (!_broadCastDict) {
        _broadCastDict = [[NSMutableDictionary alloc] init];
    }
    return _broadCastDict;
}

- (NSMutableDictionary *)streamDict
{
    if (!_streamDict) {
        _streamDict = [[NSMutableDictionary alloc] init];
    }
    return _streamDict;
}

@end
