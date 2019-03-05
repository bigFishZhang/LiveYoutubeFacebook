//
//  VendorMarcos.h
//  LiveDemo
//
//  Created by bigfish on 2019/3/5.
//  Copyright © 2019 zzb. All rights reserved.
//

#ifndef VendorMarcos_h
#define VendorMarcos_h

#define NET_WORK_SUCCESS  @"success"

#define CLIENT_ID  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CLIENT_ID"]

#define API_KEY    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"API_KEY"]

// weakSelf
#define ZBWeak  __weak __typeof(self) weakSelf = self


// =========================YouTube API ========================================

#define YT_ACCESS_TOKEN @"YT_ACCESS_TOKEN"

#define YT_API_CREATE_BROADCAST  @"https://www.googleapis.com/youtube/v3/liveBroadcasts?part=id,snippet,contentDetails,status"

#define YT_API_CREATE_LIVESTREAM  @"https://www.googleapis.com/youtube/v3/liveStreams?part=id,snippet,cdn,status"

#define YT_API_CREATE_BIND  @"https://www.googleapis.com/youtube/v3/liveBroadcasts/bind?part=id,snippet,contentDetails,status"

#define YT_API_LIVEBROADCASTS @"https://www.googleapis.com/youtube/v3/liveBroadcasts?broadcastStatus=upcoming&maxResults=50&part=id,snippet,contentDetails"

#define YT_API_GET_BROADCASTS @"https://www.googleapis.com/youtube/v3/liveBroadcasts?part=id,snippet,contentDetails,status"

#define YT_API_GET_LIVESTREAM @"https://www.googleapis.com/youtube/v3/liveStreams?part=id,snippet,cdn,status"

#define YT_API_GET_TRABSUTION @"https://www.googleapis.com/youtube/v3/liveBroadcasts/transition?part=id,snippet,contentDetails,status"

#define YT_API_PUT_UPDATE @"https://www.googleapis.com/youtube/v3/liveStreams/update?part=id,snippet,contentDetails,status"


#endif /* VendorMarcos_h */
