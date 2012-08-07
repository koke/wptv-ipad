//
//  Video.m
//  wptv
//
//  Created by Jorge Bernal on 6/19/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "Video.h"

#import "AFWordpressComClient.h"

NSString * const ApiSiteID = @"wordpress.tv";

@interface Video ()
+ (void)videosWithQuery:(NSDictionary *)query block:(void (^)(NSArray *videos))block;
@end

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
            _title = [fullTitle substringWithRange:[match rangeAtIndex:2]];
        } else {
            _speaker = @"";
            _title = fullTitle;
        }

        _date = [attributes valueForKeyPath:@"date"];
        _permalink = [attributes valueForKeyPath:@"URL"];
        _shortlink = [attributes valueForKeyPath:@"short_URL"];
        _categories = [[attributes valueForKeyPath:@"categories"] allKeys];
        _tags = [[attributes valueForKeyPath:@"tags"] allKeys];
        // TODO: add video/thumbnail URLs to the api
        NSDictionary *attachments = [attributes valueForKeyPath:@"attachments"];
        if (attachments && [attachments count] > 0) {
            NSDictionary *attachment = [[attachments allValues] objectAtIndex:0];
            _thumbnailURL = [NSURL URLWithString:[attachment valueForKeyPath:@"videopress_thumbnail"]];
            _sdVideoURL = [NSURL URLWithString:[attachment valueForKeyPath:@"videopress_files.std.url"]];
            _hdVideoURL = [NSURL URLWithString:[attachment valueForKeyPath:@"videopress_files.hd.url"]];
        }
        if (!self.thumbnailURL) {
            NSLog(@"No thumbnail for: %@", self);
        }
    }
    return self;
}

#pragma mark - Query methods

+ (void)latestVideosWithBlock:(void (^)(NSArray *videos))block {
    [self videosWithQuery:nil block:block];
}

+ (void)featuredVideosWithBlock:(void (^)(NSArray *videos))block {
    [self videosWithQuery:[NSDictionary dictionaryWithObject:@"featured" forKey:@"tag"] block:block];
}

+ (void)videosWithCategory:(NSString *)categorySlug block:(void (^)(NSArray *videos))block {
    [self videosWithQuery:[NSDictionary dictionaryWithObject:categorySlug forKey:@"category"] block:block];
}

+ (void)videosWithSearchString:(NSString *)searchString block:(void (^)(NSArray *videos))block {
    [self videosWithQuery:[NSDictionary dictionaryWithObject:searchString forKey:@"search"] block:block];
}

+ (void)videosWithQuery:(NSDictionary *)query block:(void (^)(NSArray *))block {
    NSString *path = [NSString stringWithFormat:@"sites/%@/posts/", ApiSiteID];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:@24 forKey:@"number"];
    [parameters addEntriesFromDictionary:query];

    [[AFWordpressComClient sharedClient] getPath:path
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             NSArray *posts = [responseObject valueForKeyPath:@"posts"];
                                             NSMutableArray *mutableVideos = [NSMutableArray arrayWithCapacity:[posts count]];
                                             for (NSDictionary *attributes in posts) {
                                                 Video *video = [[Video alloc] initWithAttributes:attributes];
                                                 [mutableVideos addObject:video];
                                             }

                                             if (block) {
                                                 block([NSArray arrayWithArray:mutableVideos]);
                                             }
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];

                                             if (block) {
                                                 block(nil);
                                             }
                                         }];
}

#pragma mark - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"<Video: %p, ID: %d, Title: %@, URL: %@", self, self.postID, self.title, self.permalink];
}

#pragma mark - Custom accessors

- (NSURL *)videoURL {
    if (self.hdVideoURL) {
        return self.hdVideoURL;
    } else {
        return self.sdVideoURL;
    }
}

@end
