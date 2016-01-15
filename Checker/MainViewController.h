//
//  MainViewController.h
//  Checker
//
//  Created by poukoute on 1/12/16.
//  Copyright © 2016 poukoute. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CHCSVParser.h"
#import "ITProgressBar.h"

@class DragDropImageView;
@interface MainViewController : NSViewController<NSTableViewDelegate,NSTableViewDataSource>

@property IBOutlet DragDropImageView *dragDropImageView;

-(void)addURL:(NSURL *)url;

@end
