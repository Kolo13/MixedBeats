//
//  Track.m
//  MixedUp
//
//  Created by kori kolodziejczak on 3/16/15.
//  Copyright (c) 2015 Kori Kolodziejczak. All rights reserved.
//

#import "Track.h"

@implementation Track


- (instancetype)initWithName:(NSString *)name trackID:(NSString *)trackID {
	self = [super init];
	
	if (self) {
		self.name = name;
		self.trackID = trackID;
	}
	return self;
};




+ (NSMutableArray *)parseJSONToTracklist:(NSData *)data {
	NSMutableArray *playlistTracks = [[NSMutableArray alloc]init];
	
	NSError *error = nil;
	NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	
	
	if (error) {
		NSLog(@"parse playlist failed");
	}else{
		
		for (NSDictionary *item in JSONDictionary[@"data"]) {
			Track *list = [Track new];
			list.name = item[@"title"];
			list.trackID = item[@"id"];
			
			[playlistTracks addObject:list];
		}
		
	}
	
	return playlistTracks;
	
}

@end
