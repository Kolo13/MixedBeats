//
//  Beat.m
//  MixedUp
//
//  Created by Kori Kolodziejczak on 12/10/14.
//  Copyright (c) 2014 Kori Kolodziejczak. All rights reserved.
//

#import "Beat.h" 


@implementation Beat

- (instancetype) initWithName:(NSString *)name {
  
  self = [super init];
  
  if (self) {
    self.name = name;
  }
  return self;
}

+ (NSDictionary *)parseJSONIntoBeats:(NSData *)rawJSONData {
    
    NSDictionary *beats = [[NSDictionary alloc] init];
    NSError *error = nil;
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:rawJSONData options:0 error:&error];


  if (error != nil) {
	  NSLog(@"json parsing unsuccessful. %@", error.localizedDescription);
  } else {
      
      id JSONData = [JSONDictionary valueForKeyPath:@"data"];
      if ([JSONData isKindOfClass:[NSDictionary class]]) {
          
          NSArray *artistsArray = JSONData[@"artists"];
          NSArray *albumsArray = JSONData[@"albums"];
          NSArray *tracksArray = JSONData[@"tracks"];
          beats = @{@"artists" : artistsArray,
                    @"albums" : albumsArray,
                    @"tracks" : tracksArray
                    };

	  } else {
		  
		  if ([JSONData[0][@"result_type"] isEqualToString:@"artist"]){
			  
			  NSArray *artistsArray = [JSONDictionary valueForKeyPath:@"data"];
			  
			  beats = @{
						@"artists" : artistsArray
						};
			  NSLog(@"ARTIST");
			  
		  } else if ([JSONData[0][@"result_type"] isEqualToString:@"album"]){
			  NSArray *albumsArray = [JSONDictionary valueForKeyPath:@"data"];
			  beats = @{
						@"albums" : albumsArray
						};
			  NSLog(@"ALBUM");
		  } else if ([JSONData[0][@"result_type"] isEqualToString:@"track"]){
			  NSArray *tracksArray = [JSONDictionary valueForKeyPath:@"data"];
			  beats = @{
						@"tracks" : tracksArray
						};
			  NSLog(@"TRACKS");
		  }
	  }
  }
  return beats;
}


+ (NSMutableArray *)parseJSONIntoPlaylists:(NSData *)rawJSONData {
	NSMutableArray *beats = [[NSMutableArray alloc] init];

    NSError *error = nil;
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:rawJSONData options:0 error:&error];
	
	if (error != nil) {
		NSLog(@"json parsing unsuccessful. %@", error.localizedDescription);
	
	} else {
		
        NSMutableArray *playlistData = [JSONDictionary valueForKeyPath:@"data"];
		beats = playlistData;

		
    }
	 return beats;
}
@end