//
//  PlaylistViewController.m
//  MixedUp
//
//  Created by Brian Mendez on 12/16/14.
//  Copyright (c) 2014 Kori Kolodziejczak. All rights reserved.
//

#import "PlaylistViewController.h"


@interface PlaylistViewController ()

- (IBAction)myPlaylistButton:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@end

@implementation PlaylistViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.playlistArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
	Playlist *list = self.playlistArray[indexPath.row];
	
	cell.textLabel.text = list.name;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	Playlist *playlist = [self.playlistArray objectAtIndex:indexPath.row];

	self.headerLabel.text = playlist.name;
	
//
//	self.playlistArray = playlist.tracksArray;
//	[self.tableView reloadData];

	[[NetworkController sharedInstance]getMyPlaylistTracksWithID: playlist.playlistID completionHandler:^(NSError *error, NSMutableArray *playlists) {
		self.playlistArray = playlists;

		[self.tableView reloadData];
	}];
	
}

- (IBAction)myPlaylistButton:(UIButton *)sender {
	
	if (sender.tag == 0) {
		[[NetworkController sharedInstance] getMyPlaylists:([[NetworkController sharedInstance] user_ID])completionHandler:^(NSError *error, NSMutableArray *playlists) {
			self.playlistArray = playlists;
			[self.tableView reloadData];
		}];
	}else if (sender.tag == 1) {
		[[NetworkController sharedInstance]saveCurrentPlaylist];
		
		//
		NSLog(@"Saved");
		
		
		//[[NetworkController sharedInstance] saveMyPlaylist:self.playlistArray];
	}


}
@end