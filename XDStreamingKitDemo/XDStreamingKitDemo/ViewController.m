//
//  ViewController.m
//  XDStreamingKitDemo
//
//  Created by miaoxiaodong on 2017/11/27.
//  Copyright © 2017年 mark. All rights reserved.
//

#import "ViewController.h"
#import "STKAudioPlayer.h"

@interface ViewController ()<STKAudioPlayerDelegate>
{
    NSArray *_dataSourceArray;
    NSTimer *_stkTimer;
}
@property (nonatomic, strong) STKAudioPlayer *stkAudioPlayer;
@end

@implementation ViewController
- (STKAudioPlayer *)stkAudioPlayer {
    if (!_stkAudioPlayer) {
        STKAudioPlayerOptions options = {.flushQueueOnSeek = YES,.enableVolumeMixer = YES};
        _stkAudioPlayer = [[STKAudioPlayer alloc] initWithOptions:options];
        _stkAudioPlayer.meteringEnabled = YES;
        _stkAudioPlayer.volume = 1;
        _stkAudioPlayer.delegate = self;
    }
    return _stkAudioPlayer;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _dataSourceArray = @[@{@"title": @"夏天的味道", @"url": @"http://download.lingyongqian.cn/music/AdagioSostenuto.mp3"},
                         @{@"title": @"没那种命", @"url": @"http://download.lingyongqian.cn/music/ForElise.mp3"},
                         @{@"title": @"不得不爱", @"url": @"http://mr7.doubanio.com/39ec9c9b5bbac0af7b373d1c62c294a3/1/fm/song/p1393354_128k.mp4"},
                         @{@"title": @"海阔天空", @"url": @"http://mr7.doubanio.com/16c59061a6a82bbb92bdd21e626db152/0/fm/song/p966452_128k.mp4"}];
    
    NSString *urlString = _dataSourceArray.firstObject[@"url"];
    [self.stkAudioPlayer play:urlString];
    if (_stkTimer) {
        [_stkTimer setFireDate:[NSDate distantPast]];
    } else {
        _stkTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(streamingKitPlay) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_stkTimer forMode:NSRunLoopCommonModes];
    }
}
- (void)streamingKitPlay {
    //获取当前播放音频的总时间时间
    double duration = self.stkAudioPlayer.duration;
    //当前播放的时间
    double progress = self.stkAudioPlayer.progress;
    NSLog(@"stk 播放总时间 = %f 当前播放时间 = %f",duration, progress);
    if (self.stkAudioPlayer.state == STKAudioPlayerStateBuffering){
        NSLog(@"stk 缓冲了");
    }
    
}
#pragma mark - StreamingKit代理方法
- (void)audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState {
    NSLog(@"当播放器 状态发生改变的时候调用，  暂停-开始播放都会调用");
}
- (void)audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode {
    NSLog(@"引发的意外和可能发生的不可恢复的错误，极少概率会调用。  就是此歌曲不能加载，或者url是不可用的");
//    [MBProgressHUD showText:[self getErrorMsg:errorCode]];
    //    [self.stkAudioPlayer stop];
    //    [_stkTimer setFireDate:[NSDate distantFuture]];
}
- (void)audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId {
    NSLog(@"当一个项目开始播放调用");
//    self.playBtn.selected = YES;
//    self.isPlay = YES;
//    if (_playPlan != 0) {
//        [self.stkAudioPlayer seekToTime:_playPlan];
//        _playPlan = 0;
//    }
}
- (void)audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId {
    NSLog(@"完成缓冲。。。%@", queueItemId);
}
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration {
    if (audioPlayer.state == STKAudioPlayerStateStopped && duration > 0) {
//        [self playbackFinished];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
