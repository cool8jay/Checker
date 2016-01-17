//
//  AppDelegate.h
//  Checker
//
//  Created by poukoute on 1/12/16.
//  Copyright © 2016 poukoute. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RHPreferences/RHPreferences.h>
#import "MainViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    IBOutlet MainViewController * _mainViewController;
    RHPreferencesWindowController *_preferencesWindowController;
}

@end

