//
//  VideoGridViewController_Subclass.h
//  wptv
//
//  Created by Jorge Bernal on 8/8/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "VideoGridViewController.h"

@class Video;

@interface VideoGridViewController ()
- (NSFetchRequest *)fetchRequest;
- (void)configureCell:(KKGridViewCell *)cell forVideo:(Video *)video;
@end
