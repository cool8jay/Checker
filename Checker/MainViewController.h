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

@interface MainViewController : NSViewController<NSTableViewDelegate,NSTableViewDataSource>

-(void)addURL:(NSURL *)url;

@end
