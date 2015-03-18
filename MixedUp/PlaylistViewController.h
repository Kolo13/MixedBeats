//
//  PlaylistViewController.h
//  MixedUp
//
//  Created by Brian Mendez on 12/16/14.
//  Copyright (c) 2014 Kori Kolodziejczak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "NetworkController.h"
#import "Beat.h"

@interface PlaylistViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *playlistArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
