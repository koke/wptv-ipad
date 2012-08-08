//
//  VideoGridViewController.m
//  wptv
//
//  Created by Jorge Bernal on 6/19/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "VideoGridViewController.h"
#import "VideoGridViewController_Subclass.h"
#import "VideoViewController.h"
#import "Video.h"

#import "UIImageView+AFNetworking.h"

NSIndexPath *NSIndexPathFromKKIndexPath(KKIndexPath *indexPath) {
    return [NSIndexPath indexPathForRow:indexPath.index inSection:indexPath.section];
}

KKIndexPath *KKIndexPathFromNSIndexPath(NSIndexPath *indexPath) {
    return [KKIndexPath indexPathForIndex:indexPath.row inSection:indexPath.section];
}

@interface VideoGridViewController ()
@property (nonatomic,strong) NSFetchedResultsController *resultsController;
@property (nonatomic,strong) UIBarButtonItem *reloadButton;
- (void)reload:(id)sender;
- (NSDictionary *)videoQuery;
@end

@implementation VideoGridViewController
@synthesize resultsController = _resultsController;

- (void)loadView {
    [super loadView];
    self.gridView.cellSize = CGSizeMake(250.0f, 140.0f);
    self.gridView.cellPadding = CGSizeMake(4.0f, 4.0f);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)];
    self.navigationItem.leftBarButtonItem = self.reloadButton;
    [self reload:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showVideo"] && [sender isKindOfClass:[Video class]] && [segue.destinationViewController isKindOfClass:[VideoViewController class]]) {
        VideoViewController *videoViewController = (VideoViewController *)segue.destinationViewController;
        videoViewController.video = (Video *)sender;
    }
}

#pragma mark - Custom methods

- (void)reload:(id)sender {
    self.reloadButton.enabled = NO;
    [Video videosWithQuery:[self videoQuery] block:^(NSArray *videos) {
        if (videos) {
            NSLog(@"loaded %d videos", [videos count]);
        }
        self.reloadButton.enabled = YES;
    }];
}

- (NSDictionary *)videoQuery {
    return nil;
}

#pragma mark - KKGRidViewDataSource

- (NSUInteger)numberOfSectionsInGridView:(KKGridView *)gridView {
    return [[self.resultsController sections] count];
}

- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.resultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (KKGridViewCell *)gridView:(KKGridView *)gridView cellForItemAtIndexPath:(KKIndexPath *)indexPath {
    KKGridViewCell *cell = [KKGridViewCell cellForGridView:gridView];
    Video *video = [self.resultsController objectAtIndexPath:NSIndexPathFromKKIndexPath(indexPath)];
    [self configureCell:cell forVideo:video];

    return cell;
}

- (void)configureCell:(KKGridViewCell *)cell forVideo:(Video *)video {
    cell.backgroundColor = [UIColor redColor];
    UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame:cell.bounds];
    [thumbnailView setImageWithURL:video.thumbnailURL];
    [cell.contentView addSubview:thumbnailView];
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 250, 40)];
    background.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
    [cell.contentView addSubview:background];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 105, 240, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.numberOfLines = 2;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:12.0f];
    if (video.speaker) {
        titleLabel.text = [NSString stringWithFormat:@"%@\n%@", video.speaker, video.title];
    } else {
        titleLabel.text = [NSString stringWithFormat:@"%@", video.title];
    }
    [cell.contentView addSubview:titleLabel];    
}

#pragma mark - KKGridViewDelegate

- (void)gridView:(KKGridView *)gridView didSelectItemAtIndexPath:(KKIndexPath *)indexPath {
    Video *video = [self.resultsController objectAtIndexPath:NSIndexPathFromKKIndexPath(indexPath)];
    [self performSegueWithIdentifier:@"showVideo" sender:video];
    [gridView deselectItemsAtIndexPaths:@[ indexPath ] animated:YES];
}

#pragma mark - Fetched results controller

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Video"];
    [fetchRequest setSortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO] ]];

    return fetchRequest;
}

- (NSFetchedResultsController *)resultsController {
    if (_resultsController != nil) {
        return _resultsController;
    }
    
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];

    _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest]
                                                             managedObjectContext:moc
                                                               sectionNameKeyPath:nil
                                                                        cacheName:nil];
    _resultsController.delegate = self;
    
    NSError *error = nil;
    if (![_resultsController performFetch:&error]) {
        NSLog(@"%@ couldn't fetch videos: %@", self, [error localizedDescription]);
        _resultsController = nil;
    }
    
    return _resultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.gridView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.gridView endUpdates];
    [self.gridView reloadData];
}

/*
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (NSFetchedResultsChangeUpdate == type && newIndexPath && ![newIndexPath isEqual:indexPath]) {
        // Seriously, Apple?
        // http://developer.apple.com/library/ios/#releasenotes/iPhone/NSFetchedResultsChangeMoveReportedAsNSFetchedResultsChangeUpdate/_index.html
        type = NSFetchedResultsChangeMove;
    }
    if (newIndexPath == nil) {
        // It seems in some cases newIndexPath can be nil for updates
        newIndexPath = indexPath;
    }
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.gridView insertItemsAtIndexPaths:@[ KKIndexPathFromNSIndexPath(newIndexPath) ] withAnimation:KKGridViewAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.gridView deleteItemsAtIndexPaths:@[ KKIndexPathFromNSIndexPath(indexPath) ] withAnimation:KKGridViewAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.gridView reloadItemsAtIndexPaths:@[ KKIndexPathFromNSIndexPath(indexPath) ]];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.gridView deleteItemsAtIndexPaths:@[ KKIndexPathFromNSIndexPath(indexPath) ] withAnimation:KKGridViewAnimationFade];
            [self.gridView insertItemsAtIndexPaths:@[ KKIndexPathFromNSIndexPath(newIndexPath) ] withAnimation:KKGridViewAnimationFade];
            break;
    }
}
*/
@end
