//
//  FeaturedViewController.m
//  wptv
//
//  Created by Jorge Bernal on 8/7/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "FeaturedViewController.h"
#import "Video.h"

@interface FeaturedViewController ()

@end

@implementation FeaturedViewController

- (NSDictionary *)videoQuery {
    return @{ @"tag" : @"featured" };
}

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [super fetchRequest];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ANY(tags.slug) LIKE %@", @"featured"]];
    return fetchRequest;
}

@end
