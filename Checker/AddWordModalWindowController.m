#import "AddWordModalWindowController.h"
#import "PKUtils.h"

@interface AddWordModalWindowController ()

@end

@implementation AddWordModalWindowController

- (void)windowDidLoad{
    [self updateParameterView];
    
    _wordTextField.delegate = self;
}

- (IBAction)ancelBtnClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
}

- (void)controlTextDidChange:(NSNotification *)notification{
    NSTextField *textField = [notification object];
    
    _newWord = [textField stringValue];
    [self updateParameterView];
}

- (IBAction)doneBtnClicked:(id)sender{
    NSString *word = _newWord;
 
    [PKUtils addWord:word];
    
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (BOOL)validateParameter{
    if (_newWord != nil
        && ![[_newWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]
        && [_newWord length]>1){
        return YES;
    }else{
        return NO;
    }
}

- (void)updateParameterView{
    _doneButton.enabled = [self validateParameter];
}

@end
