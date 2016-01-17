//
//  AppDelegate.m
//  Checker
//
//  Created by poukoute on 1/12/16.
//  Copyright © 2016 poukoute. All rights reserved.
//

#import "AppDelegate.h"
#import "DragDropView.h"
#import "PKWhitelistViewController.h"

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
    NSURL *filePath = [NSURL fileURLWithPath:file];
    
    [_mainViewController performSelectorInBackground:@selector(addURL:) withObject:filePath];
    _mainViewController.dragDropView.hidden = YES;
    
    return  YES; // Return YES when file processed succesfull, else return NO.
}

- (IBAction)showPreferences:(id)sender {
    [self initPreferences];
    
    [_preferencesWindowController showWindow:self];
}

- (void)initPreferences{
    //if we have not created the window controller yet, create it now
    if (!_preferencesWindowController){
        PKWhitelistViewController *whitelist = [[PKWhitelistViewController alloc] init];
        
        whitelist.identifier = @"whitelist";
        
        NSArray *controllers = [NSArray arrayWithObjects:
                                whitelist,
                                nil];
        
        _preferencesWindowController = [[RHPreferencesWindowController alloc] initWithViewControllers:controllers andTitle:NSLocalizedString(@"Whitelist", @"")];
    }
}
@end
