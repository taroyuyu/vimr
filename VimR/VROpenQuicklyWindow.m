/**
 * Tae Won Ha — @hataewon
 *
 * http://taewon.de
 * http://qvacua.com
 *
 * See LICENSE
 */

#import "VROpenQuicklyWindow.h"
#import "VRUtils.h"
#import "VROpenQuicklyWindowController.h"


int qOpenQuicklyWindowPadding = 4;
int qOpenQuicklySearchFieldMinWidth = 100;

#define constraint_layout(vs, fmt, ...) [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: fmt, ##__VA_ARGS__] options:0 metrics:nil views: vs]];


@implementation VROpenQuicklyWindow {
  NSScrollView *_scrollView;
}

#pragma mark Public
- (instancetype)initWithContentRect:(CGRect)contentRect
                   windowController:(VROpenQuicklyWindowController *)windowController {

  self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask | NSTexturedBackgroundWindowMask
                            backing:NSBackingStoreBuffered defer:YES];
  RETURN_NIL_WHEN_NOT_SELF

  self.hasShadow = YES;
  self.opaque = NO;
  self.movableByWindowBackground = NO;
  self.excludedFromWindowsMenu = YES;

  [self addViewsWithWindowController:windowController];

  return self;
}

- (void)reset {
  [self.searchField setStringValue:@""];
}

#pragma mark NSWindow
- (BOOL)canBecomeKeyWindow {
  // when an NSWindow has the style mask NSBorderlessWindowMask, then, by default, it cannot become key
  return YES;
}

#pragma mark Private
- (void)addViewsWithWindowController:(VROpenQuicklyWindowController *)windowController {
  NSTextField *label = [[NSTextField alloc] initWithFrame:CGRectZero];
  label.translatesAutoresizingMaskIntoConstraints = NO;
  label.backgroundColor = [NSColor clearColor];
  label.stringValue = @"Enter file name";
  label.editable = NO;
  label.bordered = NO;
  [self.contentView addSubview:label];

  NSProgressIndicator *progressIndicator = [[NSProgressIndicator alloc] initWithFrame:CGRectZero];
  progressIndicator.style = NSProgressIndicatorSpinningStyle;
  progressIndicator.translatesAutoresizingMaskIntoConstraints = NO;
  progressIndicator.controlSize = NSSmallControlSize;
  [self.contentView addSubview:progressIndicator];

  _searchField = [[NSSearchField alloc] initWithFrame:CGRectZero];
  _searchField.translatesAutoresizingMaskIntoConstraints = NO;
  [self.contentView addSubview:_searchField];

  NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:@"name"];
  tableColumn.dataCell = [[NSTextFieldCell alloc] initTextCell:@""];
  [tableColumn.dataCell setLineBreakMode:NSLineBreakByTruncatingMiddle];

  _fileItemTableView = [[NSTableView alloc] initWithFrame:CGRectZero];
  [_fileItemTableView addTableColumn:tableColumn];
  _fileItemTableView.delegate = windowController;
  _fileItemTableView.dataSource = windowController;
  _fileItemTableView.usesAlternatingRowBackgroundColors = YES;
  _fileItemTableView.headerView = nil;
  _fileItemTableView.focusRingType = NSFocusRingTypeNone;

  _scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
  _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
  _scrollView.hasVerticalScroller = YES;
  _scrollView.hasHorizontalScroller = NO;
  _scrollView.autohidesScrollers = YES;
  _scrollView.documentView = _fileItemTableView;
  [self.contentView addSubview:_scrollView];

  NSDictionary *views = @{
      @"searchField" : _searchField,
      @"label" : label,
      @"progress" : progressIndicator,
      @"table" : _scrollView,
  };

  constraint_layout(views, @"H:|-(%d)-[label(>=50)]", qOpenQuicklyWindowPadding);
  constraint_layout(views, @"H:[progress(16)]-(%d)-|", qOpenQuicklyWindowPadding);
  constraint_layout(views, @"H:|-(%d)-[searchField(>=100)]-(%d)-|", qOpenQuicklyWindowPadding, qOpenQuicklyWindowPadding);
  constraint_layout(views, @"H:|[table(>=100)]|");
  constraint_layout(views, @"V:|-(%d)-[label(17)]-(%d)-[searchField(22)]-(%d)-[table(>=100)]-(%d)-|", qOpenQuicklyWindowPadding, qOpenQuicklyWindowPadding, qOpenQuicklyWindowPadding, qOpenQuicklyWindowPadding);
  constraint_layout(views, @"V:|-(%d)-[progress(16)]-(%d)-[searchField(22)]-(%d)-[table(>=100)]-(%d)-|", qOpenQuicklyWindowPadding, qOpenQuicklyWindowPadding+1, qOpenQuicklyWindowPadding, qOpenQuicklyWindowPadding);
}

@end
