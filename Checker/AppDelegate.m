//
//  AppDelegate.m
//  Checker
//
//  Created by poukoute on 1/12/16.
//  Copyright © 2016 poukoute. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag{
    [self.window makeKeyAndOrderFront:nil];
    
    return TRUE;
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    return [self processFile:filename];
}

- (BOOL)processFile:(NSString *)file
{
    NSLog(@"The following file has been dropped or selected: %@",file);
    // Process file here
    return  YES; // Return YES when file processed succesfull, else return NO.
}

@end
