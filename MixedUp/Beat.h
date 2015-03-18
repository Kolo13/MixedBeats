//
//  Beat.h
//  MixedUp
//
//  Created by Kori Kolodziejczak on 12/10/14.
//  Copyright (c) 2014 Kori Kolodziejczak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Beat : NSObject

@property (strong, nonatomic) NSString *name;

- (instancetype)initWithName:(NSString *)name;
+ (NSDictionary *)parseJSONIntoBeats:(NSData *)rawJSONData;
+ (NSMutableArray *)parseJSONIntoPlaylists:(NSData *)rawJSONData;

@end