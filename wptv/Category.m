//
//  Category.m
//  wptv
//
//  Created by Jorge Bernal on 8/7/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "Category.h"
#import "Video.h"


@implementation Category

@dynamic name;
@dynamic postCount;
@dynamic slug;
@dynamic videos;

+ (Category *)categoryWithSlug:(NSString *)slug name:(NSString *)name postCount:(NSNumber *)postCount {
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Category" inManagedObjectContext:managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"slug like %@", slug]];
    
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    Category *category = nil;
    if ([results count] > 0) {
        category = [results objectAtIndex:0];
    } else {
        category = [[Category alloc] initWithEntity:[NSEntityDescription entityForName:@"Category" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
    }
    
    category.slug = slug;
    category.name = name;
    category.postCount = postCount;
    
    return category;
}

@end
