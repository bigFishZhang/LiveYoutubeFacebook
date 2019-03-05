//
//  LiveViewModel.h
//  LiveDemo
//
//  Created by bigfish on 2019/1/29.
//  Copyright © 2019 zzb. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LiveViewModel : NSObject

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


@end


