#import <Cocoa/Cocoa.h>

@interface AddWordModalWindowController : NSWindowController <NSTextFieldDelegate>{
    NSString *_newWord;
    
    IBOutlet NSTextField *_wordTextField;
    
    IBOutlet NSButton *_doneButton;
}

@end
