//
//  TextTool.m
//  AnnoTree Viewer
//
//  Created by Mike on 8/31/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "TextTool.h"
#import "DDLog.h"
#import "ToolbarBg.h"

@implementation TextTool
@synthesize drawScreen;
static const int ddLogLevel = LOG_LEVEL_ERROR;
@synthesize toolbarButtons;

- (id)initWithFrame:(CGRect)frame annotree:(AnnoTree*)annotree
{
    self = [super initWithFrame:frame annotree:annotree];
    if (self) {
        toolbarButtons = [[NSMutableArray alloc] init];
        UIImage *textIconImage = [UIImage imageNamed:@"AnnoTree.bundle/TextIconToolbar.png"];
        UIImage *textIconImageSelected = [UIImage imageNamed:@"AnnoTree.bundle/TextIconToolbarSelected.png"];
        [self setBackgroundImage:textIconImage forState:UIControlStateNormal];
        [self setBackgroundImage:textIconImageSelected forState:UIControlStateHighlighted];
        [self setBackgroundImage:textIconImageSelected forState:(UIControlStateDisabled|UIControlStateSelected)];
        [self addTarget:self action:@selector(setSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.drawScreen.view setAutoresizesSubviews:YES];
        [self.drawScreen.view setAutoresizingMask: UIViewAutoresizingFlexibleWidth |
         UIViewAutoresizingFlexibleHeight];
        
        //add color buttons
        [self addRectangleForToolbar:self.annoTree.space*.9 y1:self.annoTree.space*.9 x2:self.annoTree.sizeIcon*1.8 y2:self.annoTree.sizeIcon*1.4];
        
        [self addColorButton:[UIColor redColor] buttonLocation:0];
        [self addColorButton:[UIColor blueColor] buttonLocation:1];
        [self addColorButton:[UIColor greenColor] buttonLocation:2];
    
        [self addTextButton:14 buttonLocation:0];
        [self addTextButton:18 buttonLocation:1];
        [self addTextButton:22 buttonLocation:2];
        
        [self setTextSize:14];
        [self setTextColor:[UIColor redColor]];
        
        drawScreen = [[DrawingViewController alloc] init];
    }
    return self;
}

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

-(void)addRectangleForToolbar:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2{
    ToolbarBg* toolbarBg = [[ToolbarBg alloc] initWithFrame:CGRectMake(x1,y1, x2, y2)];
    toolbarBg.hidden = YES;
    toolbarBg.backgroundColor = UIColorFromRGB(0x3F3F3F);
    //[self.annoTree.annoTreeToolbar addSubview:toolbarBg];
    [self.toolbarButtons addObject:toolbarBg];
    [self.annoTree.toolbarObjects addObject:toolbarBg];
}

-(void)addTextButton:(int)size buttonLocation:(int)buttonLocation{
    DDLogVerbose(@"Adding text button text:%d", size);
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(self.annoTree.space*(1 + buttonLocation/2.0),self.annoTree.space*1.5, self.annoTree.sizeIcon/2, self.annoTree.sizeIcon/2)];
    
    [button setTag:size];
    [button setBackgroundImage:[UIImage imageNamed:[NSMutableString stringWithFormat:@"AnnoTree.bundle/text_%dpx.png", size]] forState:UIControlStateNormal];
    
    //[button setBackgroundColor:color];
    button.userInteractionEnabled = YES;
    [button addTarget:self action:@selector(sizeSelector:) forControlEvents:UIControlEventTouchUpInside];
    button.hidden = YES;
    [self.annoTree.toolbarButtons addObject:button];
    [self.toolbarButtons addObject:button];
    //[self.annoTree.annoTreeToolbar addSubview:button];
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

-(void)setTextSize:(int)size{
    [drawScreen setTextSize:size];
}

-(IBAction)sizeSelector:(UIButton*)button{
    [drawScreen setTextSize:button.tag];
}

-(void)setTextColor:(UIColor *)color{
    [drawScreen setTextColor:color];
}
-(IBAction)colorSelector:(UIButton*)button {
    DDLogVerbose(@"Setting Color");
    [self setTextColor:[button backgroundColor]];
}
-(void)setUnselected{
    DDLogVerbose(@"In TextTool: setUnselected");
    [drawScreen setTextEnabled:NO];
    for(UIButton* button in self.toolbarButtons){
        [button removeFromSuperview];
    }
}
-(IBAction)setSelectedButton:(UIButton*)button {
    NSLog(@"Log Fail");
    DDLogVerbose(@"TextTool: setSelectedButton Activated");
    
    [super.annoTree unselectAll];
    
    for(UIButton* button in self.toolbarButtons){
        button.userInteractionEnabled = YES;
        [self.annoTree.annoTreeToolbar addSubview:button];
    }
    self.selected = YES;
    self.highlighted = NO;
    self.enabled = NO;
    [drawScreen setTextEnabled:YES];
    [super.annoTree.view insertSubview:drawScreen.view belowSubview:super.annoTree.annoTreeToolbar];
}

-(void)clearAll{
    [drawScreen clearAll];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
