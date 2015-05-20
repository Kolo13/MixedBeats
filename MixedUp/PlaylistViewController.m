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
@property (nonatomic) BOOL isPlaylistSelected;

@end

@implementation PlaylistViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.isPlaylistSelected = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
	
	UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
	messageLabel.text = @"Pull down to load playlist";
	messageLabel.textColor = [UIColor blackColor];
	messageLabel.numberOfLines = 0;
	messageLabel.textAlignment = NSTextAlignmentCenter;
	messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
	[messageLabel sizeToFit];

	
	
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.playlistArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
	Playlist *list = self.playlistArray[indexPath.row];
	
	cell.textLabel.text = list.name;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.isPlaylistSelected) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

	} else {
		self.isPlaylistSelected = YES;
		Playlist *playlist = [self.playlistArray objectAtIndex:indexPath.row];
		
		self.headerLabel.text = playlist.name;
		
		
		//
		//	self.playlistArray = playlist.tracksArray;
		//	[self.tableView reloadData];
		
		[[NetworkController sharedInstance]getMyPlaylistTracksWithID: playlist.playlistID completionHandler:^(NSError *error, NSMutableArray *trackList) {
			self.playlistArray = trackList;
			
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

			[self.tableView reloadData];
		}];
		

		
	}
}

- (IBAction)myPlaylistButton:(UIButton *)sender {
	
	
		
		if (sender.tag == 0) {
			self.isPlaylistSelected = NO;
			
			if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"userID"] isKindOfClass:[NSString class]])	 {
				
				NSLog(@"userID is present");
				
				NSString *user_ID = [[NSUserDefaults standardUserDefaults] valueForKey:@"userID"];
				NSLog(@"%@", user_ID);

				[[NetworkController sharedInstance] getMyPlaylists:user_ID completionHandler:^(NSError *error, NSMutableArray *playlists) {
			
				NSLog(@"PLaylist");

				self.playlistArray = playlists;
				[self.tableView reloadData];
				self.headerLabel.text = @"My Playlists";
			}];
			} else {
				[[NetworkController sharedInstance]getMyUserID:^(NSError *error, NSString *userID) {
					NSLog(@"My userID is %@", userID);
					
										
					[[NetworkController sharedInstance] getMyPlaylists:(userID)completionHandler:^(NSError *error, NSMutableArray *playlists) {
						
						self.playlistArray = playlists;
						[self.tableView reloadData];
						self.headerLabel.text = @"My Playlists";
					}];
					
					
				}];
				

			}
			
		}else if ((self.isPlaylistSelected) && (sender.tag == 1)) {
			[[NetworkController sharedInstance]saveCurrentPlaylist:self.playlistArray];

			NSLog(@"Saved");
			
			
		}
		
	



}
@end