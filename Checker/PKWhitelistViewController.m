#import "PKWhitelistViewController.h"
#import "PKUtils.h"

@interface PKWhitelistViewController ()

#define kTableColumnIdWord           @"word"

@end

@implementation PKWhitelistViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:@"PKWhitelistViewController" bundle:nibBundleOrNil];
    if (self){
    }
    return self;
}

- (void)viewDidLoad{
    _wordArray = [PKUtils getWhitelist];
    
    {
        NSTableColumn *tableColumnWord = [_tableView tableColumnWithIdentifier:kTableColumnIdWord];
        
        NSSortDescriptor *wordSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self"
                                                                             ascending:YES
                                                                              selector:@selector(compare:)];
        
        [tableColumnWord setSortDescriptorPrototype:wordSortDescriptor];
    }
    
    _deleteButton.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(whitelistUpdated:)
                                                 name:K_NOTIFICATION_CONFIG_WHITELIST_UPDATE
                                               object:nil];
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    [_wordArray sortUsingDescriptors:[tableView sortDescriptors]];
    [_tableView reloadData];
}

- (void)whitelistUpdated:(NSNotification*)notification{
    _wordArray = [PKUtils getWhitelist];
    
    [_tableView reloadData];
    [self updateView];
}

- (void)updateView{
    if([_wordArray count]>0){
        _deleteButton.enabled = YES;
    }{
        _deleteButton.enabled = NO;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [_wordArray count];
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    
    NSString *word = [_wordArray objectAtIndex:row];
    
    if ([identifier isEqualToString:kTableColumnIdWord]) {
        NSTextField *textField = [tableView makeViewWithIdentifier:identifier owner:self];
        textField.objectValue = word;
        
        return textField;
    }
    return nil;
}

- (IBAction)rowChangeSelected:(id)sender
{
    NSInteger selectedRow = [_tableView selectedRow];
    
    if (selectedRow != -1) {
        _deleteButton.enabled = YES;
    }
    else {
        _deleteButton.enabled = NO;
    }
}

- (IBAction)addWordButtonClicked:(id)sender{
    self.addWordModalWindowController = [[AddWordModalWindowController alloc] initWithWindowNibName:@"AddWordModalWindowController"];
    
    [self.view.window beginSheet:self.addWordModalWindowController.window  completionHandler:^(NSModalResponse returnCode) {
        switch (returnCode) {
            case NSModalResponseOK:
                break;
            case NSModalResponseCancel:
                break;
            default:
                break;
        }
        
        self.addWordModalWindowController = nil;
    }];
}

- (NSIndexSet *)indexesToProcessForContextMenu {
    NSIndexSet *selectedIndexes = [_tableView selectedRowIndexes];
    // If the clicked row was in the selectedIndexes, then we process all selectedIndexes. Otherwise, we process just the clickedRow
    if ([_tableView clickedRow] != -1 && ![selectedIndexes containsIndex:[_tableView clickedRow]]) {
        selectedIndexes = [NSIndexSet indexSetWithIndex:[_tableView clickedRow]];
    }
    return selectedIndexes;
}

- (IBAction)removeWord:(id)sender{
    NSIndexSet *selectedIndexes = [self indexesToProcessForContextMenu];
    if( [selectedIndexes count]>0){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [_wordArray removeObjectsAtIndexes:selectedIndexes];
        
        NSData *encodeData = [NSKeyedArchiver archivedDataWithRootObject:_wordArray];
        
        [defaults setObject:encodeData forKey:K_USER_DEFAULTS_KEY_WHITELIST];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:K_NOTIFICATION_CONFIG_WHITELIST_UPDATE object:nil userInfo:nil];
    }
    
    [_tableView reloadData];
    
    [self updateView];
}

#pragma mark - RHPreferencesViewControllerProtocol

- (NSString*)identifier{
    return NSStringFromClass(self.class);
}

- (NSImage*)toolbarItemImage{
    return [NSImage imageNamed:@"preferences_icon_general.tiff"];
}

- (NSString*)toolbarItemLabel{
    return NSLocalizedString(@"Whitelist", @"");
}

@end
