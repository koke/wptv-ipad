//
//  HowtoViewController.m
//  wptv
//
//  Created by Jorge Bernal on 8/7/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "HowtoViewController.h"

@interface HowtoViewController ()

@end

@implementation HowtoViewController

- (NSDictionary *)videoQuery {
    return @{ @"category" : @"how-to" };
}

@end