//
//  Category.h
//  wptv
//
//  Created by Jorge Bernal on 8/7/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Video;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * postCount;
@property (nonatomic, retain) NSString * slug;
@property (nonatomic, retain) NSSet *videos;

/**
 Returns a Category object with the given attributes
 
 If there is a Category with the given slug, the other attributes are updated.
 Otherwise a new object is created
 */
+ (Category *)categoryWithSlug:(NSString *)slug name:(NSString *)name postCount:(NSNumber *)postCount;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addVideosObject:(Video *)value;
- (void)removeVideosObject:(Video *)value;
- (void)addVideos:(NSSet *)values;
- (void)removeVideos:(NSSet *)values;

@end
