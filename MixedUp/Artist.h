//
//  Artist.h
//  MixedUp
//
//  Created by kori kolodziejczak on 2/13/15.
//  Copyright (c) 2015 Kori Kolodziejczak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Artist : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSNumber* artistId;
@property (strong, nonatomic) NSArray* albums;


+ (NSArray *)parseAlbumsOfArtist:(NSString *)artID;

@end

