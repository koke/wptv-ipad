//
//  VideoGridViewCell.h
//  wptv
//
//  Created by Jorge Bernal on 8/8/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "KKGridViewCell.h"

#import "Video.h"

@interface VideoGridViewCell : KKGridViewCell

@property (nonatomic, strong) Video *video;
@property BOOL showsProgress;

@end
