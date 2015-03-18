//
//  Track.h
//  MixedUp
//
//  Created by kori kolodziejczak on 3/16/15.
//  Copyright (c) 2015 Kori Kolodziejczak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Track : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *artist;
@property (strong, nonatomic) NSString *trackID;

- (instancetype)initWithName:(NSString *)name trackID:(NSString *)trackID;

+ (NSMutableArray *)parseJSONToTracklist:(NSData *)data;


@end
