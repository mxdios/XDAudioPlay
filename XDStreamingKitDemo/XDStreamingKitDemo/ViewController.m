//
//  ViewController.m
//  XDStreamingKitDemo
//
//  Created by miaoxiaodong on 2017/11/27.
//  Copyright © 2017年 mark. All rights reserved.
//

#import "ViewController.h"
#import "STKAudioPlayer.h"

typedef enum : NSUInteger {
    VoiceStatePlaying,
    VoiceStatePause,
    VoiceStateCease,
} VoiceState;

@interface ViewController ()<STKAudioPlayerDelegate>
{
    NSArray *_dataSourceArray;
    NSTimer *_stkTimer;
}
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UISlider *planSlider;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *allTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *voiceTitleLabel;
@property (nonatomic, strong) STKAudioPlayer *stkAudioPlayer;
@property (nonatomic, assign) VoiceState voiceState;
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
    self.voiceState = VoiceStateCease;
}
- (void)play:(NSInteger)index {
    NSDictionary *voiceDict = _dataSourceArray[index];
    self.voiceTitleLabel.text = voiceDict[@"title"];
    NSString *urlString = voiceDict[@"url"];
    [self.stkAudioPlayer play:urlString];
    if (_stkTimer) {
        [_stkTimer setFireDate:[NSDate distantPast]];
    } else {
        _stkTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(streamingKitPlay) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_stkTimer forMode:NSRunLoopCommonModes];
    }
}
- (IBAction)playBtnClick:(UIButton *)sender {
    switch (self.voiceState) {
        case VoiceStatePlaying:
        {
            [self.stkAudioPlayer pause];
            self.voiceState = VoiceStatePause;
            [_stkTimer setFireDate:[NSDate distantFuture]];
        }
            break;
        case VoiceStatePause:
        {
            [self.stkAudioPlayer resume];
            [_stkTimer setFireDate:[NSDate distantPast]];
            self.voiceState = VoiceStatePlaying;
        }
            break;
        case VoiceStateCease:
        {
            [self play:0];
            self.voiceState = VoiceStatePlaying;
        }
            break;
        default:
            break;
    }
    sender.selected = !sender.selected;
}
- (IBAction)lastBtnClick:(UIButton *)sender {
    
}
- (IBAction)nextBtnClick:(UIButton *)sender {
}
- (IBAction)loopBtnClick:(UIButton *)sender {
}
- (IBAction)listBtnClick:(UIButton *)sender {
}
- (IBAction)planSliderChanged:(UISlider *)sender {
}

- (void)streamingKitPlay {
    double progress = self.stkAudioPlayer.progress;
    double duration = self.stkAudioPlayer.duration;
    if (self.stkAudioPlayer.state == STKAudioPlayerStateBuffering){
        NSLog(@"stk 缓冲了");
    }
    if (duration > 0) {
        self.playTimeLabel.text = [self convertStringWithTime:progress];
        self.allTimeLabel.text = [self convertStringWithTime:duration];
        self.planSlider.value = progress / duration;
    }
}
- (NSString *)convertStringWithTime:(float)time {
    if (isnan(time)) time = 0.f;
    int min = time / 60.0;
    int sec = time - min * 60;
    NSString * minStr = min > 9 ? [NSString stringWithFormat:@"%d",min] : [NSString stringWithFormat:@"0%d",min];
    NSString * secStr = sec > 9 ? [NSString stringWithFormat:@"%d",sec] : [NSString stringWithFormat:@"0%d",sec];
    NSString * timeStr = [NSString stringWithFormat:@"%@:%@",minStr, secStr];
    return timeStr;
}
#pragma mark - StreamingKit代理方法
- (void)audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState {
    NSLog(@"当播放器 状态发生改变的时候调用，  暂停-开始播放都会调用");
}
- (void)audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode {
    NSLog(@"url无效, 此音频不能播放。");
    self.voiceState = VoiceStateCease;
    self.playBtn.selected = NO;
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
