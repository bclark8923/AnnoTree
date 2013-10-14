//
//  ToolbarButtonWithColorSelector.m
//  AnnoTree Viewer
//
//  Created by Mike on 10/10/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "ToolbarButtonWithColorSelector.h"
#import <QuartzCore/QuartzCore.h>
#import "DDLog.h"

@implementation ToolbarButtonWithColorSelector
static const int ddLogLevel = LOG_LEVEL_ERROR;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

-(void)addRectangleForToolbar:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2{
    ToolbarBg* toolbarBg = [[ToolbarBg alloc] initWithFrame:CGRectMake(x1,y1, x2, y2)];
    toolbarBg.hidden = YES;
    toolbarBg.backgroundColor = UIColorFromRGB(0x3F3F3F);
    //[self.annoTree.annoTreeToolbar addSubview:toolbarBg];
    [self.toolbarButtons addObject:toolbarBg];
    [self.annoTree.toolbarObjects addObject:toolbarBg];
}

-(void)setUnselected{
    DDLogVerbose(@"In TextTool: setUnselected");
    [self.drawScreen setTextEnabled:NO];
    for(UIButton* button in self.toolbarButtons){
        [button removeFromSuperview];
    }
}
-(IBAction)setSelectedButton:(UIButton*)button {
    DDLogVerbose(@"TextTool: setSelectedButton Activated");
    [super.annoTree unselectAll];
    
    for(UIButton* button in self.toolbarButtons){
        button.userInteractionEnabled = YES;
        [self.annoTree.annoTreeToolbar addSubview:button];
    }
    self.selected = YES;
    self.highlighted = NO;
    self.enabled = NO;
    [super.annoTree.view insertSubview:self.drawScreen.view belowSubview:super.annoTree.annoTreeToolbar];
}

-(void)addColorButton:(UIColor *)color buttonLocation:(int)buttonLocation{
    DDLogVerbose(@"Adding color button color:");
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(self.annoTree.space*(1 + buttonLocation/2.0),self.annoTree.space, self.annoTree.sizeIcon/2, self.annoTree.sizeIcon/2)];
    [button setBackgroundColor:color];
    button.userInteractionEnabled = YES;
    [button addTarget:self action:@selector(colorSelector:) forControlEvents:UIControlEventTouchUpInside];
    button.hidden = YES;
    [self.annoTree.toolbarButtons addObject:button];
    [self.toolbarButtons addObject:button];
    //[self.annoTree.annoTreeToolbar addSubview:button];
}

-(IBAction)colorSelector:(UIButton*)button {
    DDLogVerbose(@"Setting Color");
    for(UIButton*b in self.toolbarButtons){
        if([b backgroundColor]){
            b.layer.borderWidth = 0.0f;
        }
    }
    [[button layer] setBorderWidth:2.0f];
    [self setColor:[button backgroundColor]];
}

-(void)setColor:(UIColor*)color{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(void)clearAll{
    [self.drawScreen clearAll];
}



@end
