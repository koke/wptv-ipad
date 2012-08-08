//
//  WordcampViewController.m
//  wptv
//
//  Created by Jorge Bernal on 8/7/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "WordcampViewController.h"
#import "VideoGridViewController_Subclass.h"

@interface WordcampViewController ()

@end

@implementation WordcampViewController

- (NSDictionary *)videoQuery {
    return @{ @"category" : @"wordcamptv" };
}

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [super fetchRequest];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ANY(categories.slug) LIKE %@", @"wordcamptv"]];
    return fetchRequest;
}

@end
