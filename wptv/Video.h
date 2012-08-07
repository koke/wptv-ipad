//
//  Video.h
//  wptv
//
//  Created by Jorge Bernal on 6/19/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Video : NSObject

@property (readonly) NSUInteger postID;
@property (readonly) NSString *speaker;
@property (readonly) NSString *title;
@property (readonly) NSDate *date;
@property (readonly) NSString *permalink;
@property (readonly) NSString *shortlink;
@property (readonly) NSURL *thumbnailURL;
@property (readonly) NSURL *sdVideoURL;
@property (readonly) NSURL *hdVideoURL;
@property (readonly) NSArray *categories;
@property (readonly) NSArray *tags;
// Return best available video url (some videos don't have an HD version)
@property (readonly) NSURL *videoURL;


- (id)initWithAttributes:(NSDictionary *)attributes;

// Expected queries:
// - all (paged)
// - tag=featured (paged)
// - category=... (paged)
// - search=... (paged)

// Pagination:
// - On refresh, add [after] with the last video date
// - On scroll, add [before] with the last video date, [offset] with the count offset. Never ask for more than "found"

+ (void)latestVideosWithBlock:(void (^)(NSArray *videos))block;
+ (void)featuredVideosWithBlock:(void (^)(NSArray *videos))block;
+ (void)videosWithCategory:(NSString *)categorySlug block:(void (^)(NSArray *videos))block;
+ (void)videosWithSearchString:(NSString *)searchString block:(void (^)(NSArray *videos))block;
+ (void)videosWithQuery:(NSDictionary *)query block:(void (^)(NSArray *videos))block;

@end
