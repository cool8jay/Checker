#import "DragDropImageView.h"
#import "MainViewController.h"

@implementation DragDropImageView

- (void)awakeFromNib {
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

- (BOOL)allowsVibrancy {
    return NSAppKitVersionNumber >= NSAppKitVersionNumber10_10;
}

-(BOOL)isOpaque {
    return NSAppKitVersionNumber < NSAppKitVersionNumber10_10;;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    if ([sender draggingSource]!=self) {
        highlight = YES;
        
        [self setNeedsDisplay:YES];
        
        NSArray *files = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
        
        NSString *fileName =[files objectAtIndex:0];
        
        NSURL *url = [NSURL fileURLWithPath:fileName];
        
        NSNumber *isDirectory;
        
        BOOL success = [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        // If we could read the information and it's indeed a directory
        if (success && [isDirectory boolValue]) {
            NSLog(@"Exit! directory!");
            return NSDragOperationNone;
        } else {
            NSString *path = [url path];
            NSString *extension = [path pathExtension];
            NSLog(@"extension=%@",extension);
            
            if ([extension caseInsensitiveCompare:@"csv"] == NSOrderedSame ) {
                return NSDragOperationCopy;
            }else{
                return NSDragOperationNone;
            }
        }
    }
    
    return NSDragOperationNone;
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context{
    return NSDragOperationCopy;
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag {
    return NSDragOperationCopy;//send data as copy operation
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
    highlight = NO;//remove highlight of the drop zone
    [self setNeedsDisplay: YES];
}

-(void)viewWillStartLiveResize {
    smoothSizes = YES;
    [super viewWillStartLiveResize];
}

-(void)drawRect:(NSRect)rect {
    if (NSAppKitVersionNumber < NSAppKitVersionNumber10_10) {
        [[NSColor windowBackgroundColor] setFill];
    } else {
        [[NSColor clearColor] set];
    }
    NSRectFillUsingOperation(rect, NSCompositeSourceOver);
    
    NSColor *gray = [NSColor colorWithDeviceWhite:0 alpha:highlight ? 1.0/4.0 : 1.0/8.0];
    [gray set];
    [gray setFill];
    
    NSRect bounds = [self bounds];
    CGFloat size = MIN(bounds.size.width/4.0, bounds.size.height/1.5);
    CGFloat width = MAX(2.0, size/32.0);
    NSRect frame = NSMakeRect((bounds.size.width-size)/2.0, (bounds.size.height-size)/2.0, size, size);
    
    if (!smoothSizes) {
        width = round(width);
        size = ceil(size);
        frame = NSMakeRect(round(frame.origin.x)+((int)width&1)/2.0, round(frame.origin.y)+((int)width&1)/2.0, round(frame.size.width), round(frame.size.height));
    }
    
    [NSBezierPath setDefaultLineWidth:width];
    
    NSBezierPath *p = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:size/14.0 yRadius:size/14.0];
    const CGFloat dash[2] = {size/10.0, size/16.0};
    [p setLineDash:dash count:2 phase:2];
    [p stroke];
    
    NSBezierPath *r = [NSBezierPath bezierPath];
    CGFloat baseWidth=size/8.0, baseHeight = size/8.0, arrowWidth=baseWidth*2, pointHeight=baseHeight*3.0, offset=-size/8.0;
    [r moveToPoint:NSMakePoint(bounds.size.width/2.0 - baseWidth, bounds.size.height/2.0 + baseHeight - offset)];
    [r lineToPoint:NSMakePoint(bounds.size.width/2.0 + baseWidth, bounds.size.height/2.0 + baseHeight - offset)];
    [r lineToPoint:NSMakePoint(bounds.size.width/2.0 + baseWidth, bounds.size.height/2.0 - baseHeight - offset)];
    [r lineToPoint:NSMakePoint(bounds.size.width/2.0 + arrowWidth, bounds.size.height/2.0 - baseHeight - offset)];
    [r lineToPoint:NSMakePoint(bounds.size.width/2.0, bounds.size.height/2.0 - pointHeight - offset)];
    [r lineToPoint:NSMakePoint(bounds.size.width/2.0 - arrowWidth, bounds.size.height/2.0 - baseHeight - offset)];
    [r lineToPoint:NSMakePoint(bounds.size.width/2.0 - baseWidth, bounds.size.height/2.0 - baseHeight - offset)];
    [r fill];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    highlight = NO;//finished with the drag so remove any highlighting
    [self setNeedsDisplay: YES];
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    if ([sender draggingSource]!=self) {
        NSArray *files = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
        NSURL *filePath = [NSURL fileURLWithPath:[files objectAtIndex:0]];
        [viewController performSelectorInBackground:@selector(addURL:) withObject:filePath];
        
        // NSLog(@"files=%@",files);
    }
    
    self.hidden = YES;
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES;//so source doesn't have to be the active window
}

- (void)mouseDown:(NSEvent *)theEvent{
    highlight = YES;
    [self setNeedsDisplay: YES];
}

- (void)mouseUp:(NSEvent *)theEvent{
    highlight = NO;
    [self setNeedsDisplay: YES];
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.allowsMultipleSelection = NO;
    openPanel.canChooseFiles = YES;
    openPanel.canChooseDirectories = NO;
    openPanel.message = @"Choose the localization csv file.";
    [openPanel setAllowedFileTypes:@[@"csv"]];
    [openPanel beginSheetModalForWindow:self.window
                      completionHandler:^(NSInteger result){
                          if (result == NSFileHandlingPanelOKButton) {
                              NSURL *url = openPanel.URL;
                              self.hidden = YES;
                              [viewController performSelectorInBackground:@selector(addURL:) withObject:url];
                          }
                      }];
}

@end
