//
//  Video.m
//  wptv
//
//  Created by Jorge Bernal on 8/7/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "Video.h"
#import "Category.h"
#import "Tag.h"
#import "AppDelegate.h"

#import "AFWordpressComClient.h"
#import "AFHTTPRequestOperation.h"

#import "ISO8601DateFormatter.h"

NSString * const ApiSiteID = @"wordpress.tv";

@interface Video ()
- (void)setAttributes:(NSDictionary *)attributes;
- (void)startDownload;
- (void)stopDownload;
- (void)removeDownload;
- (NSURL *)documentsDirectory;
@end

@implementation Video {
    AFHTTPRequestOperation *_downloadOperation;
}

@dynamic date;
@dynamic hdVideoUrl;
@dynamic permalink;
@dynamic postID;
@dynamic sdVideoUrl;
@dynamic shortlink;
@dynamic speaker;
@dynamic thumbnailUrl;
@dynamic title;
@dynamic categories;
@dynamic tags;
@dynamic localUrl;

- (id)initWithAttributes:(NSDictionary *)attributes {
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    self = [super initWithEntity:[NSEntityDescription entityForName:@"Video" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
    if (self) {
        self.postID = [attributes objectForKey:@"ID"];
        [self setAttributes:attributes];
    }
    return self;
}

+ (Video *)videoWithId:(NSNumber *)postId attributes:(NSDictionary *)attributes {
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Video" inManagedObjectContext:managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"postID = %@", postId]];
    
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    Video *video = nil;
    if ([results count] > 0) {
        video = [results objectAtIndex:0];
        [video setAttributes:attributes];
    } else {
        video = [[Video alloc] initWithAttributes:attributes];
    }
    return video;
}

- (void)setAttributes:(NSDictionary *)attributes {
    NSString *fullTitle = [attributes objectForKey:@"title"];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(.*?) *: *(.*)$" options:0 error:&error];
    NSArray *matches = [regex matchesInString:fullTitle options:0 range:NSMakeRange(0, [fullTitle length])];
    if ([matches count] > 0) {
        NSTextCheckingResult *match = [matches objectAtIndex:0];
        self.speaker = [fullTitle substringWithRange:[match rangeAtIndex:1]];
        self.title = [fullTitle substringWithRange:[match rangeAtIndex:2]];
    } else {
        self.speaker = nil;
        self.title = fullTitle;
    }
    
    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    NSString *dateString = [attributes objectForKey:@"date"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    self.date = date;
    self.permalink = [attributes objectForKey:@"URL"];
    self.shortlink = [attributes objectForKey:@"short_URL"];
    [[attributes objectForKey:@"categories"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj objectForKey:@"slug"]) {
            Category *category = [Category categoryWithSlug:[obj objectForKey:@"slug"] name:[obj objectForKey:@"name"] postCount:[obj objectForKey:@"post_count"]];
            [self addCategoriesObject:category];
        }
    }];
    [[attributes objectForKey:@"tags"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj objectForKey:@"slug"]) {
            Tag *tag = [Tag tagWithSlug:[obj objectForKey:@"slug"] name:[obj objectForKey:@"name"] postCount:[obj objectForKey:@"post_count"]];
            [self addTagsObject:tag];
        }
    }];
    
    NSDictionary *attachments = [attributes objectForKey:@"attachments"];
    if (attachments && [attachments count] > 0) {
        NSDictionary *attachment = [[attachments allValues] objectAtIndex:0];
        self.thumbnailUrl = [attachment objectForKey:@"videopress_thumbnail"];
        NSDictionary *videopressFiles = [attachment objectForKey:@"videopress_files"];
        self.sdVideoUrl = [[videopressFiles objectForKey:@"std"] objectForKey:@"url"];
        self.hdVideoUrl = [[videopressFiles objectForKey:@"hd"] objectForKey:@"url"];
    }
    if (!self.thumbnailUrl) {
        NSLog(@"No thumbnail for: %@", self);
    }
}

#pragma mark - Video Download

- (void)startDownload {
    BOOL append = YES;
    if (!self.localURL) {
        NSString *filename = [NSString stringWithFormat:@"%@.mp4", [[NSProcessInfo processInfo] globallyUniqueString]];
        self.localURL = [[self documentsDirectory] URLByAppendingPathComponent:filename];
        append = NO;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.videoURL];
    if (append) {
        NSError *error = nil;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[self.localURL path] error:&error];
        NSNumber *fileSize = [attributes objectForKey:NSFileSize];
        if (fileSize && [fileSize intValue] > 0) {
            int bytes = [fileSize intValue] + 1;
            [request addValue:[NSString stringWithFormat:@"bytes:%d-", bytes] forHTTPHeaderField:@"Range"];
        }
    }
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamWithURL:self.localURL append:append];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.isDownloaded = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed download: %@", [error localizedDescription]);
    }];
    [operation setDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"Downloaded %lld of %lld bytes for %@", totalBytesRead, totalBytesExpectedToRead, self.postID);
    }];
    [[AFWordpressComClient sharedClient] enqueueHTTPRequestOperation:operation];
}

- (void)stopDownload {
    if (_downloadOperation) {
        [_downloadOperation cancel];
    }
}

- (void)removeDownload {
    [[NSFileManager defaultManager] removeItemAtURL:self.localURL error:nil];
    self.localURL = nil;
    self.isDownloaded = NO;
}

- (NSURL *)documentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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
    NSLog(@"Query: %@", query);
    NSString *path = [NSString stringWithFormat:@"sites/%@/posts/", ApiSiteID];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:@24 forKey:@"number"];
    [parameters addEntriesFromDictionary:query];
    
    [[AFWordpressComClient sharedClient] getPath:path
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             NSArray *posts = [responseObject valueForKeyPath:@"posts"];
                                             NSMutableArray *mutableVideos = [NSMutableArray arrayWithCapacity:[posts count]];
                                             for (NSDictionary *attributes in posts) {
                                                 NSNumber *postID = [attributes objectForKey:@"ID"];
                                                 if (postID) {
                                                     Video *video = [Video videoWithId:postID attributes:attributes];
                                                     [mutableVideos addObject:video];
                                                 }
                                                 AppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
                                                 [appDelegate saveContext];
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

#pragma mark - Custom accessors

- (NSURL *)thumbnailURL {
    return [NSURL URLWithString:self.thumbnailUrl];
}

- (void)setThumbnailURL:(NSURL *)thumbnailURL {
    [self setThumbnailUrl:[thumbnailURL absoluteString]];
}

- (NSURL *)sdVideoURL {
    return [NSURL URLWithString:self.sdVideoUrl];
}

- (void)setSdVideoURL:(NSURL *)sdVideoURL {
    [self setSdVideoUrl:[sdVideoURL absoluteString]];
}

- (NSURL *)hdVideoURL {
    return [NSURL URLWithString:self.hdVideoUrl];
}

- (void)setHdVideoURL:(NSURL *)hdVideoURL {
    [self setHdVideoUrl:[hdVideoURL absoluteString]];
}

- (NSURL *)videoURL {
    if (self.hdVideoUrl) {
        return self.hdVideoURL;
    } else {
        return self.sdVideoURL;
    }
}

- (NSURL *)localURL {
    return [NSURL URLWithString:self.localUrl];
}

- (void)setLocalURL:(NSURL *)localURL {
    [self setLocalUrl:[localURL absoluteString]];
}

- (BOOL)isDownloaded {
    BOOL tmpValue;
    
    [self willAccessValueForKey:@"isDownloaded"];
    tmpValue = [[self primitiveValueForKey:@"isDownloaded"] boolValue];
    [self didAccessValueForKey:@"isDownloaded"];
    
    return tmpValue;
}

- (void)setIsDownloaded:(BOOL)value {
    [self willChangeValueForKey:@"isDownloaded"];
    [self setPrimitiveValue:[NSNumber numberWithBool:value] forKey:@"isDownloaded"];
    [self didChangeValueForKey:@"isDownloaded"];
}

- (BOOL)saved {
    BOOL tmpValue;
    
    [self willAccessValueForKey:@"saved"];
    tmpValue = [[self primitiveValueForKey:@"saved"] boolValue];
    [self didAccessValueForKey:@"saved"];
    
    return tmpValue;
}

- (void)setSaved:(BOOL)value
{
    [self willChangeValueForKey:@"saved"];
    [self setPrimitiveValue:[NSNumber numberWithBool:value] forKey:@"saved"];
    [self didChangeValueForKey:@"saved"];
    
    if (self.saved) {
        [self startDownload];
    } else {
        [self removeDownload];
    }
}

@end
