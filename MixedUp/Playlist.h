//
//  Playlist.h
//  MixedUp
//
//  Created by kori kolodziejczak on 2/13/15.
//  Copyright (c) 2015 Kori Kolodziejczak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"
#import "NetworkController.h"

@interface Playlist : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *playlistID;
@property (strong, nonatomic) NSMutableArray *tracksArray;

+ (NSMutableArray *)parseJsonToPlaylist:(NSData *)data;
+ (NSArray *)parseJSONToTracklist:(NSData *)data;

@end
