//
//  NetworkController.m
//  MixedUp
//
//  Created by Kori Kolodziejczak on 12/5/14.
//  Copyright (c) 2014 Kori Kolodziejczak. All rights reserved.
//

 
#import "NetworkController.h"
#import "PlaylistViewController.h"
#import <AVFoundation/AVFoundation.h>

@implementation NetworkController


NSString *client_ID = @"3nbxp96juh7spx6j9srkknhs";
NSString *client_Secret = @"uSbQFBHZtJEvBxjg2dc2fhRs";
NSString *oAuthURL = @"https://partner.api.beatsmusic.com/v1/oauth2/authorize";
NSString *response_type = @"code";
NSString *redirectURL = @"somefancyname://test";
NSString *code = @" ";





- (void)searchWithKeyword:(NSString *)keyword ofKind:(SearchType)ofKind completionHandler:(void(^)(NSError *error, NSDictionary *beats))completionHandler {
	NSString *urlString = [[NSString alloc]init];
	
	switch (ofKind) {
		case Federated:
			NSLog(@"FED");
			urlString = [NSString stringWithFormat:@"https://partner.api.beatsmusic.com/v1/api/search/federated?q=%@&limit=20&offset=0&client_id=%@", keyword, client_ID];
			break;
		case Artist:
			
			urlString = [NSString stringWithFormat:@"https://partner.api.beatsmusic.com/v1/api/search?q=%@&type=artist&client_id=%@&limit=20&offset=0", keyword, client_ID];
			break;

		case Album:
			urlString = [NSString stringWithFormat:@"https://partner.api.beatsmusic.com/v1/api/search?q=%@&type=album&client_id=%@&limit=20&offset=0", keyword, client_ID];
			break;

		case Tracks:
			urlString = [NSString stringWithFormat:@"https://partner.api.beatsmusic.com/v1/api/search?q=%@&type=track&client_id=%@&limit=20&offset=0", keyword, client_ID];
			break;

	}
	
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		
		if (error) {
			NSLog(@"%@", error.localizedDescription);
		} else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
			NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
			
			if (httpURLResponse.statusCode >= 200 && httpURLResponse.statusCode <= 299) {
				NSLog(@"success! code: %lu", httpURLResponse.statusCode);
				
				//NSDictionary *searchResults = [[NSDictionary alloc] init];
				
				
				switch (ofKind) {
					case Federated:{
						[[NSOperationQueue mainQueue] addOperationWithBlock:^{
							NSDictionary *searchResults = [Beat parseJSONIntoBeats:data];
							completionHandler(nil, searchResults);
						}];
						break;

					}
					case Artist:
					case Album:
					case Tracks:
						[[NSOperationQueue mainQueue] addOperationWithBlock:^{
							NSDictionary *searchResults = [Beat parseJSONIntoBeats:data];
							completionHandler(nil, searchResults);
						}];
						break;
				}

			}
				
		}
	}];
	[dataTask resume];
}





- (void)requestOAuthAccess {
	NSString *loginURL = [NSString stringWithFormat: @"%@?response_type=%@&redirect_uri=%@&client_id=%@", oAuthURL, response_type, redirectURL, client_ID];
	NSURL *url = [NSURL URLWithString:loginURL];
	[[UIApplication sharedApplication]openURL:url];
}


- (void)handleOAuthURL:(NSURL *)callbackURL {
	NSString *query = callbackURL.query;
	NSString *components = query;
	NSArray *comp1Array = [components componentsSeparatedByString:@"&code="];
	NSString *comp1 = comp1Array[1];
	NSArray *comp2Array = [comp1 componentsSeparatedByString:@"&"];
	code = [comp2Array firstObject];

	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
	
	NSString *post = [NSString stringWithFormat:@"client_secret=%@&client_id=%@&redirect_uri=%@&code=%@&grant_type=authorization_code",
					  client_Secret, client_ID, redirectURL, code];
	
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	
	[request setURL:[NSURL URLWithString:@"https://partner.api.beatsmusic.com/v1/oauth2/token"]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		
		NSLog(@"2ndPhaseResponse:%@ %@\n", response, error);
		
		if(error == nil) {
			NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			NSLog(@"Data = %@",text);
		}
		
		NSError *err = nil;
		
		NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err];
		self.token = responseDictionary[@"access_token"];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setValue:([NetworkController sharedInstance].token) forKey:@"authToken"];
		[defaults synchronize];
		
		NSLog(@"%@", self.token);
	}];
	
	[dataTask resume];
}


- (void)getMyUserID:(void(^)(NSError *error, NSString *userID))completionHandler {
    NSString *urlWithSearchTerm = [[NSString alloc] init];
    urlWithSearchTerm = [NSString stringWithFormat:@"https://partner.api.beatsmusic.com/v1/api/me?access_token=%@", self.token];
  
	NSURL *url = [[NSURL alloc] initWithString:urlWithSearchTerm];
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
	
    if (error) {
      NSLog(@"%@", error.localizedDescription);
    } else {
      
      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
        if (httpURLResponse.statusCode >= 200 && httpURLResponse.statusCode <= 299) {
          NSLog(@"success! code: %lu", httpURLResponse.statusCode);
            NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *components = json;
            NSArray* comp1Array = [components componentsSeparatedByString:@"user_context\":\""];
            NSString* comp1 = [comp1Array lastObject];
            NSArray* comp2Array = [comp1 componentsSeparatedByString:@"\",\"extended"];
			self.user_ID = [comp2Array firstObject];

			
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setValue:(self.user_ID) forKey:@"userID"];
			[defaults synchronize];

			
          [[NSOperationQueue mainQueue] addOperationWithBlock:^{completionHandler(nil, self.user_ID);
          }];

        }
      }
    }
  }];
  
  [dataTask resume];
}

- (void)getMyPlaylists:(NSString *)userID completionHandler:(void(^)(NSError *error, NSMutableArray *playlists))completionHandler {
	NSString *urlWithSearchTerm = [[NSString alloc] init];
	urlWithSearchTerm = [NSString stringWithFormat:@"https://partner.api.beatsmusic.com/v1/api/users/%@/playlists?access_token=%@&limit=20&offset=0", userID, self.token];

	NSURL *url = [[NSURL alloc]initWithString:urlWithSearchTerm];
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

    if (error) {
		NSLog(@"%@", error.localizedDescription);
    } else {
		if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
        if (httpURLResponse.statusCode >= 200 && httpURLResponse.statusCode <= 299) {
          NSLog(@"success! code: %lu", (long)httpURLResponse.statusCode);
			
			
          NSMutableArray *playlists = [Playlist parseJsonToPlaylist:data];
          [[NSOperationQueue mainQueue] addOperationWithBlock:^{completionHandler(nil, playlists);
          }];
        }
      }
    }
  }];
  [dataTask resume];
}


- (void) getMyPlaylistTracksWithID:(NSString *)playlistID completionHandler:(void(^)(NSError *error, NSMutableArray *playlists))completionHandler {
	
	NSString *urlWithSearchTerm = [[NSString alloc]init];
	urlWithSearchTerm = [NSString stringWithFormat:@"https://partner.api.beatsmusic.com/v1/api/playlists/%@/tracks?limit=20&offset=0&access_token=%@", playlistID, self.token];
	
	NSURL *url = [[NSURL alloc] initWithString:urlWithSearchTerm];
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		
		if (error) {
			NSLog(@"%@", error.localizedDescription);
		} else {
			
			if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
				NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
				
				if (httpURLResponse.statusCode >= 200 && httpURLResponse.statusCode <= 299) {
					NSLog(@"success! code: %lu", httpURLResponse.statusCode);
					
					
					NSMutableArray *trackList = [Track parseJSONToTracklist:data];
					[[NSOperationQueue mainQueue] addOperationWithBlock:^{completionHandler(nil, trackList);
					}];
				}
			}
		}
	}];
	[dataTask resume];
}


- (void)saveCurrentPlaylist:(NSMutableArray *)currentPlaylist {
	
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];

	//Code to create a list of tracks in the tableview for the current playlist
	NSString *tracks = @"tracks?";
	
	for (Track *track in currentPlaylist) {
		
		tracks = [tracks stringByAppendingFormat:@"&track_ids=%@", track.trackID];
	}
	
	
	
	NSString *put = [NSString stringWithFormat:@"&access_token=%@", self.token];
	NSData *putData = [put dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *putLength = [NSString stringWithFormat:@"%lu", (unsigned long)[putData length]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	
	NSString *urlWithTracklist = [[NSString alloc]init];
	urlWithTracklist = [NSString stringWithFormat:@"https://partner.api.beatsmusic.com/v1/api/playlists/pl287673114018447360/%@", tracks];
	NSLog(@" PUT URL: %@", urlWithTracklist);
	[request setURL:[NSURL URLWithString:urlWithTracklist]];
	[request setHTTPMethod:@"PUT"];
	[request setValue:putLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:putData];
	
	NSURLSessionDataTask * dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		
		NSLog(@"SaveThePlaylist:%@ %@\n", response, error);
		NSError *err = nil;
		
		if(err == nil) {
			NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
			NSLog(@"Data = %@",text);
		}
	}];
	[dataTask resume];
};

+ (NetworkController *)sharedInstance {
	static NetworkController *_sharedInstance = nil;
	static dispatch_once_t oncePredicate;
	dispatch_once(&oncePredicate, ^{
		_sharedInstance = [[NetworkController alloc] init];
	});
	
	return _sharedInstance;
}


@end
