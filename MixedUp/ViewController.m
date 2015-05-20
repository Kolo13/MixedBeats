//
//  ViewController.m
//  MixedUp
//
//  Created by Kori Kolodziejczak on 12/5/14.
//  Copyright (c) 2014 Kori Kolodziejczak. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h> 
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()

@property (strong, nonatomic) NSString *token;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UIAlertController *alert;
@property (strong, nonatomic) PlaylistViewController *playlistVC;
//@property (strong, nonatomic) ViewController *searchVC;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic)  NSArray* beatSectionTitles;
@property (strong, nonatomic) NSDictionary* beats;
@property (strong, nonatomic)  NSString *searchTerm;
@property SearchType ofKind;

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
- (void)moreArtistButtonAction;
- (void)moreAlbumsButtonAction;
- (void)moreTracksButtonAction;

@end



@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.view.backgroundColor= [UIColor blackColor];
	self.tableView.backgroundColor = [UIColor whiteColor];
	
	// Display a message when the table is empty
	UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
	
	messageLabel.text = @"Search for artist, albums, or tracks.  Swipe tracks to the right to add them to currently selected playlist.  Swipe left to create or select a different playlist";
	messageLabel.textColor = [UIColor blackColor];
	messageLabel.numberOfLines = 0;
	messageLabel.textAlignment = NSTextAlignmentCenter;
	messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
	[messageLabel sizeToFit];
	
	self.tableView.backgroundView = messageLabel;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	self.searchBar.delegate = self;
	
	self.textField.delegate = self;
	
	UISwipeGestureRecognizer *leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandler:)];
	UISwipeGestureRecognizer *rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandler:)];

	[leftGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
	[rightGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];


	[self.view addGestureRecognizer:leftGestureRecognizer];
	[self.view addGestureRecognizer:rightGestureRecognizer];

}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear: animated];
	
	self.playlistVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PLAYLIST_VC"];
	self.playlistVC.playlistArray = [[NSMutableArray alloc]init];
	self.playlistVC.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width,self.view.frame.size.height);
	
	
	if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"authToken"] isKindOfClass:[NSString class]]){
		self.token = [[NSUserDefaults standardUserDefaults] valueForKey:@"authToken"];
		NetworkController *sharedNetworkController = [NetworkController sharedInstance];
		sharedNetworkController.token = self.token;

	}else{

		self.alert = [UIAlertController alertControllerWithTitle:nil message:@"MixedBeats will present a web browser to  sign into BeatsMusic" preferredStyle:UIAlertControllerStyleAlert];
	
		UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[[NetworkController sharedInstance]requestOAuthAccess];
		
		}];
	
		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
		}];
		
		[self.alert addAction:okAction];
		[self.alert addAction:cancelAction];
		[self presentViewController:self.alert animated:YES completion:nil];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    self.searchTerm = [self.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	
	[[NetworkController sharedInstance] searchWithKeyword:self.searchTerm ofKind:Federated completionHandler:^(NSError *error, NSDictionary *beats) {
		self.beats = beats;
		self.beatSectionTitles = [beats allKeys];
		[self.tableView reloadData];
	}];

	}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.beatSectionTitles count];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 55, 18)];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	NSString *string = [self.beatSectionTitles objectAtIndex:section];
	
	[button setTag: section];

	if (button.tag == 0) {
		[button addTarget:self action:@selector(moreArtistButtonAction) forControlEvents:UIControlEventTouchUpInside];
	} else if (button.tag == 1) {
		[button addTarget:self action:@selector(moreAlbumsButtonAction) forControlEvents:UIControlEventTouchUpInside];
	} else {
		[button addTarget:self action:@selector(moreTracksButtonAction) forControlEvents:UIControlEventTouchUpInside];
	}

	if (self.beatSectionTitles.count > 1) {
		[button setTitle:@"show all>" forState:UIControlStateNormal];
		[button sizeToFit];
		button.center = CGPointMake(tableView.frame.size.width * .9, tableView.sectionHeaderHeight	/ 2);
		[view addSubview:button];
		
	}
	
	[label setFont:[UIFont boldSystemFontOfSize:16]];
	[label setText:string];
	[view addSubview:label];
	[view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
	
	return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	
	return 30.0;
	
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     NSString *sectionTitle = [self.beatSectionTitles objectAtIndex:section];
      NSArray *sectionObjects = [self.beats objectForKey:sectionTitle];
    return [sectionObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    NSString *sectionTitle = [self.beatSectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionObjects = [self.beats objectForKey:sectionTitle];
    NSDictionary *beat = [sectionObjects objectAtIndex:indexPath.row];
    cell.textLabel.text = beat[@"display"];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
    NSString *sectionTitle = [self.beatSectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionObjects = [self.beats objectForKey:sectionTitle];
    NSDictionary *beat = [sectionObjects objectAtIndex:indexPath.row];
	
	NSLog(@"%@", [beat valueForKey:@"result_type"]);
	
		
//	[self.playlistVC.playlistArray addObject:beat];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)leftSwipeHandler:(UISwipeGestureRecognizer *)recognizer {
  
  [UIView animateWithDuration:0.3 animations:^{
    [self.view addSubview:self.playlistVC.view];
    [self.playlistVC didMoveToParentViewController:(self)];
    [self addChildViewController:self.playlistVC];
    self.playlistVC.view.frame = CGRectMake(self.view.frame.size.width * 0, 0, self.view.frame.size.width, self.view.frame.size.height);
      
  } completion:^(BOOL finished) {

    [self.playlistVC.tableView reloadData];
    
  }];
}

- (void)rightSwipeHandler:(UISwipeGestureRecognizer *)recognizer {

  [UIView animateWithDuration:0.3 animations:^{
    self.playlistVC.view.frame = CGRectMake(self.view.frame.size.width * 1.0, 0, self.view.frame.size.width, self.view.frame.size.height);
  } completion:^(BOOL finished) {
	  
  }];
	
}

- (void)moreArtistButtonAction {
    
    NSLog(@"More Artist");
    [[NetworkController sharedInstance] moreSearchTerm:self.searchTerm type:@"artist" completionHandler:^(NSError *error, NSDictionary *beats) {
        self.beats = beats;
        self.beatSectionTitles = [beats allKeys];
        
        [self.tableView reloadData];
    }];
}

- (void)moreAlbumsButtonAction {
	[[NetworkController sharedInstance] moreSearchTerm:self.searchTerm type:@"album" completionHandler:^(NSError *error, NSDictionary *beats) {
		self.beats = beats;
		self.beatSectionTitles = [beats allKeys];
		
		[self.tableView reloadData];
	}];
}

- (void)moreTracksButtonAction {
	[[NetworkController sharedInstance] moreSearchTerm:self.searchTerm type:@"track" completionHandler:^(NSError *error, NSDictionary *beats) {
		self.beats = beats;
		self.beatSectionTitles = [beats allKeys];
		
		[self.tableView reloadData];
	}];
}

@end
