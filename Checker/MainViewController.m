//
//  MainViewController.m
//
//  Created by poukoute on 1/12/16.
//  Copyright © 2016 poukoute. All rights reserved.
//

#import "MainViewController.h"
#import "DragDropView.h"

@interface MainViewController ()

#define kTableColumnIdIndex             @"index"
#define kTableColumnIdKey               @"key"
#define kTableColumnIdEn                @"en"
#define kTableColumnIdCn                @"cn"
#define kTableColumnIdJa                @"ja"
#define kTableColumnIdKo                @"ko"
#define kTableColumnIdZhhant            @"zh-hant"
#define kTableColumnIdRu                @"ru"

@end

@implementation MainViewController{
    // data
    NSArray *_sourceData;
    NSMutableArray * _filteredDataArray;
    NSMutableDictionary * _errorInfoDict;
    
    NSArray * _whiteListArray;
    
    NSString *_englishFilter;
    NSMutableString *_nonEnglishFilter;
    
    NSMutableDictionary *regexpLangDict;
    
    // Control
    IBOutlet NSImageView *_resultIcon;
    
    IBOutlet ITProgressBar *_progressBar;
    IBOutlet NSTextField *_tipLabel;
    
    IBOutlet NSView *_bottomView;
    
    IBOutlet NSScrollView *_scrollView;
    IBOutlet NSTableView *_tableView;
    
    IBOutlet NSButton *_detailsButton;
    IBOutlet NSButton *_refreshButton;
    //    __weak IBOutlet NSButton *_refreshButton;
    IBOutlet NSButton *_resetButton;
    IBOutlet NSTextField *_amountLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    CALayer *viewLayer = [CALayer layer];
    [viewLayer setBackgroundColor:CGColorCreateGenericRGB(0.7, 0.7, 0.7, 0.4)]; //RGB plus Alpha Channel
    [_bottomView setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
    [_bottomView setLayer:viewLayer];
    
    [self.view.window setStyleMask:[self.view.window styleMask] & ~NSResizableWindowMask];
    
    _progressBar.floatValue = 0;
    
    _bottomView.hidden = YES;
    _scrollView.hidden = YES;
    _progressBar.hidden = YES;
    _resultIcon.hidden = YES;
    
    _filteredDataArray = [[NSMutableArray alloc] init];
    _errorInfoDict = [[NSMutableDictionary alloc] init];
    
    [_errorInfoDict setValue:[NSNumber numberWithInt:0] forKey:@"en"];
    [_errorInfoDict setValue:[NSNumber numberWithInt:0] forKey:@"cn"];
    [_errorInfoDict setValue:[NSNumber numberWithInt:0] forKey:@"ja"];
    [_errorInfoDict setValue:[NSNumber numberWithInt:0] forKey:@"ko"];
    [_errorInfoDict setValue:[NSNumber numberWithInt:0] forKey:@"ru"];
    [_errorInfoDict setValue:[NSNumber numberWithInt:0] forKey:@"zh-hant"];
    
    _whiteListArray =  [PKUtils getWhitelist];
    
    _englishFilter = @"^[a-zA-Z0-9,.:;≥<=>/#&@+_%?!'()\\$\\-\\s\\[\\]{}\"]+$";// 英文支持：26字母大小写，数字，一些标点符号，等等
    
    _nonEnglishFilter = [[NSMutableString alloc] initWithString:@"^([^a-zA-Z_]|%\\d?\\$?s|\\{\\d+\\}|x \\d+|x\\d+"];// 非英文支持：非英文字母大小写，数字，占位符，等等
    
    for(NSString *b in _whiteListArray){
        [_nonEnglishFilter appendFormat:@"|%@",b];
    }
    [_nonEnglishFilter appendFormat:@")*"];
    
    regexpLangDict = [NSMutableDictionary dictionaryWithDictionary: @{@"en":_englishFilter,
                                                                      @"cn":_nonEnglishFilter,
                                                                      @"ja":_nonEnglishFilter,
                                                                      @"ko":_nonEnglishFilter,
                                                                      @"ru":_nonEnglishFilter,
                                                                      @"zh-hant":_nonEnglishFilter,
                                                                      }];
    
    {
        NSTableColumn *tableColumnIndex = [_tableView tableColumnWithIdentifier:kTableColumnIdIndex];
        NSTableColumn *tableColumnKey = [_tableView tableColumnWithIdentifier:kTableColumnIdKey];
        NSTableColumn *tableColumnEn = [_tableView tableColumnWithIdentifier:kTableColumnIdEn];
        NSTableColumn *tableColumnCn = [_tableView tableColumnWithIdentifier:kTableColumnIdCn];
        NSTableColumn *tableColumnJa = [_tableView tableColumnWithIdentifier:kTableColumnIdJa];
        NSTableColumn *tableColumnKo = [_tableView tableColumnWithIdentifier:kTableColumnIdKo];
        NSTableColumn *tableColumnZhhant = [_tableView tableColumnWithIdentifier:kTableColumnIdZhhant];
        NSTableColumn *tableColumnRu = [_tableView tableColumnWithIdentifier:kTableColumnIdRu];
        
        NSComparator comparisonBlock = ^(id first,id second) {
            int a1 = [(NSString*)first intValue];
            int a2 = [(NSString*)second intValue];
            
            if (a1 < a2)
            {
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
        };
        NSSortDescriptor *indexSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index"
                                                                              ascending:YES
                                                                             comparator:comparisonBlock];
        
        NSSortDescriptor *keySortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"key"
                                                                            ascending:YES
                                                                             selector:@selector(compare:)];
        
        NSSortDescriptor *enSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"en"
                                                                           ascending:YES
                                                                            selector:@selector(compare:)];
        
        NSSortDescriptor *cnSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"cn"
                                                                           ascending:YES
                                                                            selector:@selector(compare:)];
        
        NSSortDescriptor *jaSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ja"
                                                                           ascending:YES
                                                                            selector:@selector(compare:)];
        
        NSSortDescriptor *koSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ko"
                                                                           ascending:YES
                                                                            selector:@selector(compare:)];
        
        NSSortDescriptor *zhhantSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"zh-hant"
                                                                               ascending:YES
                                                                                selector:@selector(compare:)];
        
        NSSortDescriptor *ruSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ru"
                                                                           ascending:YES
                                                                            selector:@selector(compare:)];
        
        [tableColumnIndex setSortDescriptorPrototype:indexSortDescriptor];
        [tableColumnKey setSortDescriptorPrototype:keySortDescriptor];
        [tableColumnEn setSortDescriptorPrototype:enSortDescriptor];
        [tableColumnCn setSortDescriptorPrototype:cnSortDescriptor];
        [tableColumnJa setSortDescriptorPrototype:jaSortDescriptor];
        [tableColumnKo setSortDescriptorPrototype:koSortDescriptor];
        [tableColumnZhhant setSortDescriptorPrototype:zhhantSortDescriptor];
        [tableColumnRu setSortDescriptorPrototype:ruSortDescriptor];
        

    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:K_NOTIFICATION_PARSE_WITH_RESULT
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      _tipLabel.hidden = YES;
                                                      _progressBar.hidden = YES;
                                                      
                                                      [self.view.window setStyleMask:[self.view.window styleMask] | NSResizableWindowMask];
                                                      
                                                      _scrollView.hidden = NO;
                                                      
                                                      [self.view.window setFrame:NSMakeRect(self.view.window.frame.origin.x, self.view.window.frame.origin.y, 800.f, 500.f) display:YES animate:YES];
                                                      
                                                      [_tableView reloadData];
                                                      
                                                      _detailsButton.hidden = NO;
                                                      _bottomView.hidden = NO;
                                                      
                                                      [_amountLabel setStringValue:[NSString stringWithFormat:@"%lu", [_filteredDataArray count]]];
                                                      [_amountLabel sizeToFit];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:K_NOTIFICATION_PARSE_PROGRESS
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      NSDictionary *userInfo = notification.userInfo;
                                                      
                                                      NSString *a = [userInfo valueForKey:@"progress"];
                                                      
                                                      _progressBar.floatValue = [a floatValue];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:K_NOTIFICATION_PARSE_ERROR_EMPTY
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [_resultIcon setImage:[NSImage imageNamed:@"error"]];
                                                      _resultIcon.hidden = NO;
                                                      [_tipLabel setStringValue:@"Empty csv file!"];
                                                      
                                                      _progressBar.hidden = YES;
                                                      _detailsButton.hidden = YES;
                                                      _bottomView.hidden = NO;
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:K_NOTIFICATION_PARSE_ERROR_WRONG_FIELD
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      [_resultIcon setImage:[NSImage imageNamed:@"error"]];
                                                      _resultIcon.hidden = NO;
                                                      [_tipLabel setStringValue:@"Wrong fields!"];
                                                      
                                                      _progressBar.hidden = YES;
                                                      _detailsButton.hidden = YES;
                                                      _bottomView.hidden = NO;
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:K_NOTIFICATION_PARSE_OK
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      _progressBar.hidden = YES;
                                                      [_resultIcon setImage:[NSImage imageNamed:@"ok"]];
                                                      _resultIcon.hidden = NO;
                                                      [_tipLabel setStringValue:@"All correct!"];
                                                      
                                                      _detailsButton.hidden = YES;
                                                      _bottomView.hidden = NO;
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:K_NOTIFICATION_CONFIG_WHITELIST_UPDATE
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      _whiteListArray = [PKUtils getWhitelist];
                                                      
                                                      _nonEnglishFilter = [[NSMutableString alloc] initWithString:@"^([^a-zA-Z_]|%\\d?\\$?s|\\{\\d+\\}|x \\d+|x\\d+"];// 非英文支持：非英文字母大小写，数字，占位符，等等
                                                      
                                                      for(NSString *b in _whiteListArray){
                                                          [_nonEnglishFilter appendFormat:@"|%@",b];
                                                      }
                                                      [_nonEnglishFilter appendFormat:@")*"];
                                                      
                                                      regexpLangDict = [NSMutableDictionary dictionaryWithDictionary: @{@"en":_englishFilter,
                                                                                                                        @"cn":_nonEnglishFilter,
                                                                                                                        @"ja":_nonEnglishFilter,
                                                                                                                        @"ko":_nonEnglishFilter,
                                                                                                                        @"ru":_nonEnglishFilter,
                                                                                                                        @"zh-hant":_nonEnglishFilter,
                                                                                                                        }];
                                                      
                                                      _refreshButton.hidden = NO;
                                                  }];
}

- (float)getWindowTitleBarHeight
{
    NSRect frame = NSMakeRect (0, 0, 100, 100);
    
    NSRect contentRect;
    contentRect = [NSWindow contentRectForFrameRect: frame
                                          styleMask: NSTitledWindowMask];
    
    return (frame.size.height - contentRect.size.height);
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    [_filteredDataArray sortUsingDescriptors:[tableView sortDescriptors]];
    [_tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [_filteredDataArray count];
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    
    NSDictionary *dictionary = [_filteredDataArray objectAtIndex:row];
    
    if ([identifier isEqualToString:kTableColumnIdIndex]) {
        NSTextField *textField = [tableView makeViewWithIdentifier:identifier owner:self];
        textField.objectValue = [dictionary objectForKey:@"index"];
        
        return textField;
    }else if ([identifier isEqualToString:kTableColumnIdKey]) {
        NSTextField *textField = [tableView makeViewWithIdentifier:identifier owner:self];
        textField.objectValue = [dictionary objectForKey:@"key"];
        
        return textField;
    }else if ([identifier isEqualToString:kTableColumnIdEn]) {
        NSTextField *textField = [tableView makeViewWithIdentifier:identifier owner:self];
        textField.objectValue = [dictionary objectForKey:@"en"];
        
        return textField;
    }else if ([identifier isEqualToString:kTableColumnIdCn]) {
        NSTextField *textField = [tableView makeViewWithIdentifier:identifier owner:self];
        textField.objectValue = [dictionary objectForKey:@"cn"];
        
        return textField;
    }else if ([identifier isEqualToString:kTableColumnIdJa]) {
        NSTextField *textField = [tableView makeViewWithIdentifier:identifier owner:self];
        textField.objectValue = [dictionary objectForKey:@"ja"];
        
        return textField;
    }else if ([identifier isEqualToString:kTableColumnIdKo]) {
        NSTextField *textField = [tableView makeViewWithIdentifier:identifier owner:self];
        textField.objectValue = [dictionary objectForKey:@"ko"];
        
        return textField;
    }else if ([identifier isEqualToString:kTableColumnIdZhhant]) {
        NSTextField *textField = [tableView makeViewWithIdentifier:identifier owner:self];
        textField.objectValue = [dictionary objectForKey:@"zh-hant"];
        
        return textField;
    }else if ([identifier isEqualToString:kTableColumnIdRu]) {
        NSTextField *textField = [tableView makeViewWithIdentifier:identifier owner:self];
        textField.objectValue = [dictionary objectForKey:@"ru"];
        
        return textField;
    }
    return nil;
}

- (BOOL)checkString:(NSString*)srcText forLang:(NSString*)lang{
    NSString *regexp = [regexpLangDict valueForKey:lang];
    
    NSPredicate *myTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", regexp];
    
    if ([myTest evaluateWithObject: srcText]){
        return YES;
    }else{
        return NO;
    }
}

- (void)increaseErrorInfoForKey:(NSString*)key{
    int oldValue = [[_errorInfoDict valueForKey:key] intValue];
    
    oldValue = oldValue + 1;
    [_errorInfoDict setValue:[NSNumber numberWithInt:oldValue] forKey:key];
}

- (void)checkData:(NSArray*)data{
    long dataCount = [data count] - 1;   // 第一个数据是key
    
    if([data count]>1){
        for(int i=1; i<[data count]; i++){
            NSArray *keys = [[data objectAtIndex:i] allKeys];
            __block BOOL isFieldOK = YES;
            [keys enumerateObjectsWithOptions:NSEnumerationConcurrent
                                   usingBlock:^(id s,NSUInteger idx,BOOL *stop){
                                       if (![(NSString*)s isEqual:@"key"]
                                           && ![(NSString*)s isEqual:@"en"]
                                           && ![(NSString*)s isEqual:@"cn"]
                                           && ![(NSString*)s isEqual:@"ja"]
                                           && ![(NSString*)s isEqual:@"ko"]
                                           && ![(NSString*)s isEqual:@"ru"]
                                           && ![(NSString*)s isEqual:@"zh-hant"]
                                           ) {
                                           isFieldOK = NO;
                                           *stop=TRUE;
                                       }
                                   }];
            
            if(!isFieldOK){
                [[NSNotificationCenter defaultCenter] postNotificationName:K_NOTIFICATION_PARSE_ERROR_WRONG_FIELD object:nil];
                return;
            }
            
            NSDictionary *dict = [data objectAtIndex:i];
            
            NSString *keyString = [dict valueForKey:@"key"];
            NSString *enString = [dict valueForKey:@"en"];
            NSString *cnString = [dict valueForKey:@"cn"];
            NSString *zhhantString = [dict valueForKey:@"zh-hant"];
            NSString *jaString = [dict valueForKey:@"ja"];
            NSString *koString = [dict valueForKey:@"ko"];
            NSString *ruString = [dict valueForKey:@"ru"];
            
            BOOL enOK = [self checkString:enString forLang:@"en"];
            BOOL cnOK = [self checkString:cnString forLang:@"cn"];
            BOOL zhhantOK = [self checkString:zhhantString forLang:@"zh-hant"];
            BOOL jaOK = [self checkString:jaString forLang:@"ja"];
            BOOL koOK = [self checkString:koString forLang:@"ko"];
            BOOL ruOK = [self checkString:ruString forLang:@"ru"];
            
            NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
            
            [newDict setValue:[NSString stringWithFormat:@"%d", i] forKey:@"index"];
            [newDict setValue:keyString forKey:@"key"];
            
            if (!enOK){
                [newDict setValue:enString forKey:@"en"];
                [self increaseErrorInfoForKey:@"en"];
            }
            
            if (!cnOK){
                [newDict setValue:cnString forKey:@"cn"];
                [self increaseErrorInfoForKey:@"cn"];
            }
            
            if (!zhhantOK){
                [newDict setValue:zhhantString forKey:@"zh-hant"];
                [self increaseErrorInfoForKey:@"zh-hant"];
            }
            
            if (!jaOK){
                [newDict setValue:jaString forKey:@"ja"];
                [self increaseErrorInfoForKey:@"ja"];
            }
            
            if (!koOK){
                [newDict setValue:koString forKey:@"ko"];
                [self increaseErrorInfoForKey:@"ko"];
            }
            
            if (!ruOK){
                [newDict setValue:ruString forKey:@"ru"];
                [self increaseErrorInfoForKey:@"ru"];
            }
            
            if (!enOK || !cnOK || !zhhantOK || !jaOK || !koOK || !ruOK){
                [_filteredDataArray addObject:newDict];
            }
            
            float progress = (float)i/dataCount;
            
            NSDictionary *userInfo = @{@"progress":[NSString stringWithFormat:@"%f", progress]};
            [[NSNotificationCenter defaultCenter] postNotificationName:K_NOTIFICATION_PARSE_PROGRESS
                                                                object:nil
                                                              userInfo:userInfo];
        }
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:K_NOTIFICATION_PARSE_ERROR_EMPTY object:nil];
        return;
    }
    
    if ([_filteredDataArray count]>0){
        [[NSNotificationCenter defaultCenter] postNotificationName:K_NOTIFICATION_PARSE_WITH_RESULT object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:K_NOTIFICATION_PARSE_OK object:nil];
    }
}

-(void)addURL:(NSURL*)url {
    [_tipLabel setStringValue:@"Checking..."];
    _progressBar.hidden = NO;
    
    _sourceData= [NSArray arrayWithContentsOfDelimitedURL:url
                                                  options:CHCSVParserOptionsUsesFirstLineAsKeys|CHCSVParserOptionsSanitizesFields
                                                delimiter:','
                                                    error:nil];
    
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        [self checkData:_sourceData];
    });
}
- (IBAction)showError:(id)sender {
    int en = [[_errorInfoDict valueForKey:@"en"] intValue];
    int cn = [[_errorInfoDict valueForKey:@"cn"] intValue];
    int ja = [[_errorInfoDict valueForKey:@"ja"] intValue];
    int ko = [[_errorInfoDict valueForKey:@"ko"] intValue];
    int ru = [[_errorInfoDict valueForKey:@"ru"] intValue];
    int zh_hant = [[_errorInfoDict valueForKey:@"zh-hant"] intValue];
    
    NSString *info = [NSString stringWithFormat:@"en: %d,\n"
                      "cn: %d,\n"
                      "ja: %d,\n"
                      "ko: %d,\n"
                      "ru: %d,\n"
                      "zh-hant: %d.", en,cn,ja,ko,ru,zh_hant];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Error amount for each language:"];
    [alert setInformativeText:info];
    [alert addButtonWithTitle:@"OK"];
    [alert setAlertStyle:NSInformationalAlertStyle];
    
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {}];
}

- (IBAction)refresh:(id)sender {
    [self reset:nil];
    _refreshButton.hidden = YES;
    
    [_tipLabel setStringValue:@"Checking..."];
    
    _dragDropView.hidden = YES;
    
    _progressBar.hidden = NO;
    
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        [self checkData:_sourceData];
    });
}

- (IBAction)reset:(id)sender{
    _scrollView.hidden = YES;
    _bottomView.hidden = YES;
    _resultIcon.hidden = YES;
    _progressBar.hidden = YES;
    _progressBar.floatValue = 0;
    
    [_errorInfoDict setValue:[NSNumber numberWithInt:0] forKey:@"en"];
    [_errorInfoDict setValue:[NSNumber numberWithInt:0] forKey:@"cn"];
    [_errorInfoDict setValue:[NSNumber numberWithInt:0] forKey:@"ja"];
    [_errorInfoDict setValue:[NSNumber numberWithInt:0] forKey:@"ko"];
    [_errorInfoDict setValue:[NSNumber numberWithInt:0] forKey:@"ru"];
    [_errorInfoDict setValue:[NSNumber numberWithInt:0] forKey:@"zh-hant"];
    
    [_amountLabel setStringValue:@"0"];
    [_amountLabel sizeToFit];
    
    [_tipLabel setStringValue:@"Drag localization csv file here..."];
    _tipLabel.hidden = NO;
    _dragDropView.hidden = NO;
    
    [_dragDropView setNeedsDisplay:YES];
    
    [_filteredDataArray removeAllObjects];
    
    float titleHeight = [self getWindowTitleBarHeight];
    [self.view.window setFrame:NSMakeRect(self.view.window.frame.origin.x, self.view.window.frame.origin.y, 480.f, 360.f+titleHeight) display:YES animate:YES];
    
    [self.view.window setStyleMask:[self.view.window styleMask] & ~NSResizableWindowMask];
}

@end
