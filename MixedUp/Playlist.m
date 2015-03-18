//
//  Playlist.m
//  MixedUp
//
//  Created by kori kolodziejczak on 2/13/15.
//  Copyright (c) 2015 Kori Kolodziejczak. All rights reserved.
//

#import "Playlist.h"

@implementation Playlist




+ (NSMutableArray *)parseJsonToPlaylist:(NSData *)data {
	NSMutableArray *playListArray = [[NSMutableArray alloc]init];
	
	NSError *error = nil;
	NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	

	if (error) {
		NSLog(@"parse playlist failed");
	}else{
		
		for (NSDictionary *item in JSONDictionary[@"data"]) {
			Playlist *list = [Playlist new];
			list.name = item[@"name"];
			list.ident = item[@"id"];
			[playListArray addObject:list];
		}
		
	}
	
	return playListArray;
}

+ (NSArray *)parseJSONToTracklist:(NSData *)data {
	NSMutableArray *playlistTracks = [[NSMutableArray alloc]init];
	
	NSError *error = nil;
	NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	
	
	if (error) {
		NSLog(@"parse playlist failed");
	}else{
		
		for (NSDictionary *item in JSONDictionary[@"data"]) {
			Playlist *list = [Playlist new];
			list.name = item[@"title"];
			list.ident = item[@"id"];
			[playlistTracks addObject:list];
		}
		
	}
	
	return playlistTracks;
	
}

@end
