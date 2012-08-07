//
//  VideoViewController.m
//  wptv
//
//  Created by Jorge Bernal on 8/7/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "VideoViewController.h"

#import <MediaPlayer/MediaPlayer.h>

@interface VideoViewController ()
@property (strong) MPMoviePlayerController *mplayer;
- (void)updateVideoDetails;
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.video) {
        [self updateVideoDetails];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.mplayer stop];
}

- (void)setVideo:(Video *)video {
    _video = video;
}

- (void)updateVideoDetails {
    self.title = self.video.title;
    self.titleLabel.text = self.video.title;
    self.mplayer = [[MPMoviePlayerController alloc] initWithContentURL:self.video.videoURL];
    self.mplayer.shouldAutoplay = NO;
    [self.mplayer prepareToPlay];
    if (self.videoView) {
        [self.mplayer.view setFrame:self.videoView.frame];
        [self.videoView removeFromSuperview];
    }
    [self.view addSubview:self.mplayer.view];
    self.videoView = self.mplayer.view;
}

@end
