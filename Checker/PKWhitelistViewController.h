#import <Cocoa/Cocoa.h>
#import <RHPreferences/RHPreferences.h>
#import "AddWordModalWindowController.h"

@interface PKWhitelistViewController : NSViewController <RHPreferencesViewControllerProtocol, NSTableViewDataSource, NSTableViewDelegate> {
    NSMutableArray *_wordArray;
    
    IBOutlet NSButton *_deleteButton;
    IBOutlet NSTableView *_tableView;
    
    AddWordModalWindowController *_addWordModalWindowController;
}

@property (strong) AddWordModalWindowController *addWordModalWindowController;

@end
