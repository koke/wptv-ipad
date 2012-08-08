//
//  Tag.m
//  wptv
//
//  Created by Jorge Bernal on 8/7/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "Tag.h"
#import "Video.h"

@implementation Tag

@dynamic name;
@dynamic postCount;
@dynamic slug;
@dynamic videos;

+ (Tag *)tagWithSlug:(NSString *)slug name:(NSString *)name postCount:(NSNumber *)postCount {
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Tag" inManagedObjectContext:managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"slug like %@", slug]];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];

    Tag *tag = nil;
    if ([results count] > 0) {
        tag = [results objectAtIndex:0];
    } else {
        tag = [[Tag alloc] initWithEntity:[NSEntityDescription entityForName:@"Tag" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
    }

    tag.slug = slug;
    tag.name = name;
    tag.postCount = postCount;

    return tag;
}

@end
