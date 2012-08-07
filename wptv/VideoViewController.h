//
//  VideoViewController.h
//  wptv
//
//  Created by Jorge Bernal on 8/7/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Video.h"

@interface VideoViewController : UIViewController
@property (nonatomic, strong) Video *video;
@property (strong) IBOutlet UIView *videoView;
@property (strong) IBOutlet UILabel *titleLabel;
@end
