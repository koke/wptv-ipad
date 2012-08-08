//
//  Video.h
//  wptv
//
//  Created by Jorge Bernal on 8/7/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Video : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * hdVideoUrl;
@property (nonatomic, retain) NSURL * hdVideoURL;
@property (nonatomic, retain) NSString * permalink;
@property (nonatomic, retain) NSNumber * postID;
@property (nonatomic, retain) NSString * sdVideoUrl;
@property (nonatomic, retain) NSURL * sdVideoURL;
@property (nonatomic, retain) NSString * shortlink;
@property (nonatomic, retain) NSString * speaker;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) NSURL * thumbnailURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic) BOOL isDownloaded;
@property (nonatomic) BOOL saved;
@property (nonatomic, retain) NSString *localUrl;
@property (nonatomic, retain) NSURL *localURL;

// Return best available video url (some videos don't have an HD version)
@property (readonly) NSURL *videoURL;

- (id)initWithAttributes:(NSDictionary *)attributes;
+ (Video *)videoWithId:(NSNumber *)postId attributes:(NSDictionary *)attributes;

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

@interface Video (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(NSManagedObject *)value;
- (void)removeCategoriesObject:(NSManagedObject *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
