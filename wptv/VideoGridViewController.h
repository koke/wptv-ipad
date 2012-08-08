//
//  VideoGridViewController.h
//  wptv
//
//  Created by Jorge Bernal on 6/19/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "KKGridViewController.h"
#import <CoreData/CoreData.h>

@interface VideoGridViewController : KKGridViewController <NSFetchedResultsControllerDelegate>
// FIXME: move to subclass .h
- (NSFetchRequest *)fetchRequest;
@end
