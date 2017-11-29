//
//  ViewController.m
//  XDStreamingKitDemo
//
//  Created by miaoxiaodong on 2017/11/27.
//  Copyright © 2017年 mark. All rights reserved.
//

#import "ViewController.h"
#import "STKAudioPlayer.h"
#import "XDTools.h"

typedef enum : NSUInteger {
    VoiceStatePlaying,
    VoiceStatePause,
    VoiceStateCease,
} VoiceState;

@interface ViewController ()<STKAudioPlayerDelegate>
{
    NSArray *_dataSourceArray;
    NSTimer *_stkTimer;
    NSInteger _index;
    BOOL _isSliderChange;
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
                         @{@"title": @"没那种命", @"url": @"http://download.lingyongqian.cn/music/ForElise.mp3"}];
    self.voiceState = VoiceStateCease;
    _index = 0;
    _isSliderChange = YES;
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
            [self play:_index];
            self.voiceState = VoiceStatePlaying;
        }
            break;
        default:
            break;
    }
    sender.selected = !sender.selected;
}
- (IBAction)lastBtnClick:(UIButton *)sender {
    _index ? (_index -= 1) : (_index = _dataSourceArray.count - 1);
    [self play:_index];
}
- (IBAction)nextBtnClick:(UIButton *)sender {
    _index == _dataSourceArray.count - 1 ? (_index = 0) : (_index += 1);
    [self play:_index];
}
- (IBAction)loopBtnClick:(UIButton *)sender {
}
- (IBAction)listBtnClick:(UIButton *)sender {
}
- (IBAction)planSliderBegingChanged:(UISlider *)sender {
    NSLog(@"down = %ld", sender.state);
    _isSliderChange = NO;
}
- (IBAction)planSliderEndChanged:(UISlider *)sender {
    NSLog(@"改变 = %ld", sender.state);
    _isSliderChange = YES;
    if (self.voiceState != VoiceStateCease) {
        [self.stkAudioPlayer seekToTime:sender.value * self.stkAudioPlayer.duration];
    }
}

- (void)streamingKitPlay {
    double progress = self.stkAudioPlayer.progress;
    double duration = self.stkAudioPlayer.duration;
    if (duration > 0 && _isSliderChange) {
        self.playTimeLabel.text = [XDTools convertStringWithTime:progress];
        self.allTimeLabel.text = [XDTools convertStringWithTime:duration];
        [self.planSlider setValue:progress / duration animated:YES];
    }
}

#pragma mark - StreamingKit代理方法
- (void)audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState {
    NSLog(@"暂停-开始播放都会调用");
}
- (void)audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode {
    NSLog(@"url无效, 此音频不能播放。");
    self.voiceState = VoiceStateCease;
    self.playBtn.selected = NO;
}
- (void)audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId {
    NSLog(@"音频开始播放");
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
