//
//  Video.m
//  wptv
//
//  Created by Jorge Bernal on 6/19/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "Video.h"

@implementation Video

@synthesize postID = _postID;
@synthesize speaker = _speaker;
@synthesize title = _title;
@synthesize date = _date;
@synthesize permalink = _permalink;
@synthesize shortlink = _shortlink;
@synthesize thumbnailURL = _thumbnailURL;
@synthesize sdVideoURL = _sdVideoURL;
@synthesize hdVideoURL = _hdVideoURL;
@synthesize categories = _categories;
@synthesize tags = _tags;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        _postID = [[attributes valueForKeyPath:@"ID"] integerValue];
        NSString *fullTitle = [attributes valueForKeyPath:@"title"];
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(.*?) *: *(.*)$" options:0 error:&error];
        NSArray *matches = [regex matchesInString:fullTitle options:0 range:NSMakeRange(0, [fullTitle length])];
        if ([matches count] > 0) {
            NSTextCheckingResult *match = [matches objectAtIndex:0];
            _speaker = [fullTitle substringWithRange:[match rangeAtIndex:1]];
            _title = [fullTitle substringWithRange:[match rangeAtIndex:1]];
        } else {
            _speaker = @"";
            _title = fullTitle;
        }

        _date = [attributes valueForKeyPath:@"date"];
        _permalink = [attributes valueForKeyPath:@"URL"];
        _shortlink = [attributes valueForKeyPath:@"short_URL"];
        _categories = [attributes valueForKeyPath:@"categories"];
        _tags = [attributes valueForKeyPath:@"tags"];
        // TODO: add video/thumbnail URLs to the api
    }
    return self;
}

@end
