//
//  Playlist.m
//  MixedUp
//
//  Created by kori kolodziejczak on 2/13/15.
//  Copyright (c) 2015 Kori Kolodziejczak. All rights reserved.
//

#import "Playlist.h"

@implementation Playlist

- (instancetype)initWithName:(NSString *)name playlistID:(NSString *)playlistID {
	self = [super init];
	
	if (self) {
		self.name = name;
		self.playlistID	= playlistID;
	}
	return self;
};



+ (NSMutableArray *)parseJsonToPlaylist:(NSData *)data {
	NSMutableArray *playListArray = [[NSMutableArray alloc]init];
	
	NSError *error = nil;
	NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	

	if (error) {
		NSLog(@"parse playlist failed");
	}else{
		
		for (NSDictionary *item in JSONDictionary[@"data"]) {
			
			//NSMutableArray *playlistTracksArray = [[NSMutableArray alloc]init];

//			for (NSDictionary *tracks in item[@"refs"][@"tracks"]) {
//				Track *track = [[Track alloc]initWithName:tracks[@"display"] trackID:tracks[@"id"]];
//				[playlistTracksArray addObject:track];
//			};

			Playlist *list = [[Playlist alloc]initWithName:item[@"name"] playlistID:item[@"id"]];
			[playListArray addObject:list];
		}
		
	}
	
	return playListArray;
}



@end
