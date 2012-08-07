//
//  VideoGridViewController.m
//  wptv
//
//  Created by Jorge Bernal on 6/19/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "VideoGridViewController.h"
#import "VideoViewController.h"
#import "Video.h"

#import "UIImageView+AFNetworking.h"

@interface VideoGridViewController ()
- (void)reload:(id)sender;
- (NSDictionary *)videoQuery;
@end

@implementation VideoGridViewController {
    NSArray *_videos;
}

- (void)loadView {
    [super loadView];
    self.gridView.cellSize = CGSizeMake(250.0f, 140.0f);
    self.gridView.cellPadding = CGSizeMake(4.0f, 4.0f);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
    [Video videosWithQuery:[self videoQuery] block:^(NSArray *videos) {
        if (videos) {
            _videos = videos;
            NSLog(@"loaded %d videos", [videos count]);
            [self.gridView reloadData];
        }
    }];
}

- (NSDictionary *)videoQuery {
    return nil;
}

#pragma mark - KKGRidViewDataSource

- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section {
    return [_videos count];
}

- (KKGridViewCell *)gridView:(KKGridView *)gridView cellForItemAtIndexPath:(KKIndexPath *)indexPath {
    Video *video = [_videos objectAtIndex:indexPath.index];
    KKGridViewCell *cell = [KKGridViewCell cellForGridView:gridView];
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
    titleLabel.text = [NSString stringWithFormat:@"%@\n%@", video.speaker, video.title];
    [cell.contentView addSubview:titleLabel];

    return cell;
}

#pragma mark - KKGridViewDelegate

- (void)gridView:(KKGridView *)gridView didSelectItemAtIndexPath:(KKIndexPath *)indexPath {
    Video *video = [_videos objectAtIndex:indexPath.index];
    [self performSegueWithIdentifier:@"showVideo" sender:video];
    [gridView deselectItemsAtIndexPaths:@[ indexPath ] animated:YES];
}

@end
