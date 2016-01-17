#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

@class MainViewController;
@interface DragDropView : NSView
{
    BOOL highlight; //highlight the drop zone
    BOOL smoothSizes; // use blurry fractional sizes for smooth animation during live resize

    IBOutlet MainViewController *viewController;
}

@end
