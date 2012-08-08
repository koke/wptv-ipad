//
//  VideoGridViewCell.m
//  wptv
//
//  Created by Jorge Bernal on 8/8/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "VideoGridViewCell.h"

#import "UIImageView+AFNetworking.h"

@implementation VideoGridViewCell {
    UIProgressView *_progressView;
    UIView *_progressOverlay;
}

- (void)setVideo:(Video *)video {
    _video = video;

    self.backgroundColor = [UIColor redColor];
    UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame:self.bounds];
    [thumbnailView setImageWithURL:video.thumbnailURL];
    [self.contentView addSubview:thumbnailView];
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 250, 40)];
    background.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
    [self.contentView addSubview:background];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 105, 240, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.numberOfLines = 2;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:12.0f];
    if (video.speaker) {
        titleLabel.text = [NSString stringWithFormat:@"%@\n%@", video.speaker, video.title];
    } else {
        titleLabel.text = [NSString stringWithFormat:@"%@", video.title];
    }
    [self.contentView addSubview:titleLabel];
}

@end
