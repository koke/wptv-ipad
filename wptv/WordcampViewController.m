//
//  WordcampViewController.m
//  wptv
//
//  Created by Jorge Bernal on 8/7/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "WordcampViewController.h"

@interface WordcampViewController ()

@end

@implementation WordcampViewController

- (NSDictionary *)videoQuery {
    return @{ @"category" : @"wordcamptv" };
}

@end
