//
//  DownloadsViewController.m
//  wptv
//
//  Created by Jorge Bernal on 8/8/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "DownloadsViewController.h"

@interface DownloadsViewController ()

@end

@implementation DownloadsViewController

- (NSDictionary *)videoQuery {
    return nil;
}

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [super fetchRequest];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"saved = %@", [NSNumber numberWithBool:YES]]];
    return fetchRequest;
}

@end
