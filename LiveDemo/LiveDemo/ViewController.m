//
//  ViewController.m
//  LiveDemo
//
//  Created by bigfish on 2019/1/29.
//  Copyright © 2019 zzb. All rights reserved.
//

#import "ViewController.h"
#import "LiveViewModel.h"

#define CLIENT_ID  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CLIENT_ID"]

@interface ViewController ()<GIDSignInDelegate,GIDSignInUIDelegate>

@property (nonatomic,strong) GIDSignIn *YTSignIn;

@property (nonatomic,strong) FBSDKLoginManager *FBSignIn;

@end

@implementation ViewController

#pragma mark - Life Cycle Methods

- (void)viewDidLoad
{
   [super viewDidLoad];
}

#pragma mark - Private Methods
//如果要切换账号的话，要调用注销方法，不然的话会一直自动登录

- (void)facebookLogin {
    
    [self.FBSignIn logInWithPublishPermissions:@[@"manage_pages", @"publish_pages"]
                            fromViewController:nil
                                       handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                    
              NSLog(@"facebook auth failed");
            }else if (result.isCancelled) {
                                        
              NSLog(@"facebook auth canceled");
            }else{
              NSLog(@"facebook auth success");
             // [self.liveViewModel.bindFaceBookCommand execute:result];
                //todo
            }
    }];
}

- (void)youtubeLogin
{
    if(self.YTSignIn.hasAuthInKeychain){
        NSLog(@"Cached, login in quickly");
        [self.YTSignIn signInSilently];
    }else{
        NSLog(@"NO cached,jump to login");
        [self.YTSignIn signIn];
    }
}


#pragma mark - Lazy Methods
- (GIDSignIn *)YTSignIn
{
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

- (FBSDKLoginManager *)FBSignIn
{
    if (!_FBSignIn) {
        _FBSignIn = [[FBSDKLoginManager alloc] init];
        _FBSignIn.loginBehavior = FBSDKLoginBehaviorNative;
    }
    return _FBSignIn;
}

#pragma mark - Delegate Methods

//Youtube 登录返回代理方法
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error;
{
    if (error == nil) {//登录成功
      
        NSLog(@"Youtube login success : %@",user);
        // do next job
        
         // [self.liveViewModel.bindYoutubeCommand execute:user];
        
    }else{//登录失败
        NSLog(@"Youtube login error   : %@",error);
        [self.YTSignIn signOut];
    }
}






#pragma mark - IBAction Methods

- (IBAction)youtubeIBAction:(id)sender
{
    [self youtubeLogin];
}

- (IBAction)facebookIBAction:(id)sender
{
    [self facebookLogin];
}


@end
