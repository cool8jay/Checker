//
//  MainViewController.h
//
//  Created by poukoute on 1/12/16.
//  Copyright © 2016 poukoute. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CHCSVParser.h"
#import "ITProgressBar.h"
#import "PKUtils.h"

@class DragDropView;
@interface MainViewController : NSViewController<NSTableViewDelegate,NSTableViewDataSource>

@property (strong) IBOutlet DragDropView *dragDropView;

-(void)addURL:(NSURL *)url;

@end
