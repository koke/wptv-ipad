//
//  DownloadsViewController.m
//  wptv
//
//  Created by Jorge Bernal on 8/8/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "DownloadsViewController.h"
#import "VideoGridViewController_Subclass.h"
#import "Video.h"

@interface DownloadsViewController ()

@end

@implementation DownloadsViewController

- (void)configureCell:(KKGridViewCell *)cell forVideo:(Video *)video {
    [super configureCell:cell forVideo:video];
}

- (NSDictionary *)videoQuery {
    return nil;
}

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [super fetchRequest];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"saved = %@", [NSNumber numberWithBool:YES]]];
    return fetchRequest;
}

@end
