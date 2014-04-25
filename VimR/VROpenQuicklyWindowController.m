/**
 * Tae Won Ha — @hataewon
 *
 * http://taewon.de
 * http://qvacua.com
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import <CocoaLumberjack/DDLog.h>
#import "VROpenQuicklyWindowController.h"
#import "VROpenQuicklyWindow.h"
#import "VRUtils.h"
#import "VRFileItemManager.h"


int qOpenQuicklyWindowWidth = 200;

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


@interface VROpenQuicklyWindowController ()

@property (weak) NSWindow *targetWindow;

@end


@implementation VROpenQuicklyWindowController

TB_AUTOWIRE(fileItemManager)
TB_AUTOWIRE(notificationCenter)

#pragma mark Public
- (void)showForWindow:(NSWindow *)targetWindow url:(NSURL *)targetUrl {
  self.targetWindow = targetWindow;

  CGRect contentRect = [targetWindow contentRectForFrameRect:targetWindow.frame];
  CGFloat xPos = NSMinX(contentRect) + NSWidth(contentRect) / 2 - qOpenQuicklyWindowWidth / 2
      - 2 * qOpenQuicklyWindowPadding;
  CGFloat yPos = NSMaxY(contentRect) - NSHeight(self.window.frame);

  self.window.frameOrigin = CGPointMake(xPos, yPos);
  [self.window makeKeyAndOrderFront:self];
}

#pragma mark NSObject
- (id)init {
  VROpenQuicklyWindow *win = [[VROpenQuicklyWindow alloc] initWithContentRect:
      CGRectMake(100, 100, qOpenQuicklyWindowWidth, 250)     windowController:self];

  self = [super initWithWindow:win];
  RETURN_NIL_WHEN_NOT_SELF

  win.delegate = self;
  win.searchField.delegate = self;

  return self;
}

#pragma mark NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  NSUInteger count = self.fileItemManager.fileItemsOfTargetUrl.count;
  return count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  return self.fileItemManager.fileItemsOfTargetUrl[(NSUInteger) row];
}

#pragma mark NSTextFieldDelegate
- (void)controlTextDidChange:(NSNotification *)obj {
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)selector {
  if (selector == @selector(cancelOperation:)) {
    DDLogDebug(@"Open quickly cancelled");

    [self reset];
    return YES;
  }

  if (selector == @selector(insertNewline:)) {
    DDLogDebug(@"Open quickly window: Enter pressed");
    return YES;
  }

  return NO;
}

#pragma mark NSWindowDelegate
- (void)windowDidResignMain:(NSNotification *)notification {
  DDLogDebug(@"Open quickly window resigned main");
  [self reset];
}

- (void)windowDidResignKey:(NSNotification *)notification {
  DDLogDebug(@"Open quickly window resigned key");
  [self reset];
}

#pragma mark Private
- (void)chunkOfFileItemsAdded:(id)obj {
  [[(VROpenQuicklyWindow *) self.window fileItemTableView] reloadData];
}

- (void)reset {
  [self.fileItemManager resetTargetUrl];

  [self.window close];

  [(VROpenQuicklyWindow *) self.window reset];

  [self.targetWindow makeKeyAndOrderFront:self];
  self.targetWindow = nil;
}

#pragma mark TBInitializingBean
- (void)postConstruct {
  [self.notificationCenter addObserver:self selector:@selector(chunkOfFileItemsAdded:)
                                  name:qChunkOfNewFileItemsAddedEvent object:nil];
}

@end
