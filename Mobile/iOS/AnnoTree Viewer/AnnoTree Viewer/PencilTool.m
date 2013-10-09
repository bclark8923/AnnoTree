//
//  PencilTool.m
//  AnnoTree Viewer
//
//  Created by Mike on 8/28/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "PencilTool.h"
#import "DDLog.h"
#import "ToolbarBg.h"

@implementation PencilTool

static const int ddLogLevel = LOG_LEVEL_ERROR;
@synthesize drawScreen;
@synthesize toolbarButtons;

- (id)initWithFrame:(CGRect)frame annotree:(AnnoTree*)annotree
{
    self = [super initWithFrame:frame annotree:annotree];
    if (self) {
        DDLogVerbose(@"Creating Penil Icon");
        toolbarButtons = [[NSMutableArray alloc] init];
        UIImage *pencilIconImage = [UIImage imageNamed:@"AnnoTree.bundle/PencilIconToolbar.png"];
        UIImage *pencilIconImageSelected = [UIImage imageNamed:@"AnnoTree.bundle/PencilIconToolbarSelected.png"];
        [self setBackgroundImage:pencilIconImage forState:UIControlStateNormal];
        [self setBackgroundImage:pencilIconImageSelected forState:UIControlStateHighlighted];
        [self setBackgroundImage:pencilIconImageSelected forState:(UIControlStateDisabled|UIControlStateSelected)];
        [self addTarget:self action:@selector(setSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.drawScreen.view setAutoresizesSubviews:YES];
        [self.drawScreen.view setAutoresizingMask: UIViewAutoresizingFlexibleWidth |
                UIViewAutoresizingFlexibleHeight];
        
        drawScreen = [[DrawingViewController alloc] init];
        [self setDrawColor:[UIColor redColor]];
        [self setWidth:4];
        [self addRectangleForToolbar:self.annoTree.space*.9 y1:self.annoTree.space*.9 x2:self.annoTree.sizeIcon*1.8 y2:self.annoTree.sizeIcon*2.4];
        /*Add Color Buttons*/
        [self addColorButton:[UIColor redColor] buttonLocation:0];
        [self addColorButton:[UIColor blueColor] buttonLocation:1];
        [self addColorButton:[UIColor greenColor] buttonLocation:2];
        [self addLineButton:4 buttonLocation:0];
        [self addLineButton:10 buttonLocation:1];
        [self addLineButton:16 buttonLocation:2];
        [self setDrawColor:[UIColor redColor]];
        
    }
    return self;
}

-(void)addLineButton:(int)width buttonLocation:(int)buttonLocation{    
    DDLogVerbose(@"Adding line button:%d", width);
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    int x1 = self.annoTree.space*(1);
    int y1 = self.annoTree.space*(1.5 + buttonLocation/2.0);
    int x2 = self.annoTree.sizeIcon*1.5;
    int y2 = self.annoTree.sizeIcon/2;
    [button setFrame:CGRectMake(x1, y1, x2, y2)];
    //[self addRectangleForToolbar:x1 y1:y1 x2:x2 y2:y2];
    [button setTag:width];
    [button setBackgroundImage:[UIImage imageNamed:[NSMutableString stringWithFormat:@"AnnoTree.bundle/line_%dpx.png", width]] forState:UIControlStateNormal];
    //[button setBackgroundColor:[UIColor blackColor]];
    button.userInteractionEnabled = YES;
    [button addTarget:self action:@selector(widthSelector:) forControlEvents:UIControlEventTouchUpInside];
    button.hidden = YES;
    [self.annoTree.toolbarButtons addObject:button];
    [self.toolbarButtons addObject:button];
    //[self.annoTree.annoTreeToolbar addSubview:button];
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


-(IBAction)widthSelector:(UIButton*)button {
    DDLogVerbose(@"Setting Color");
    [self setWidth:[button tag]];
}


-(void)setWidth:(int)width{
    [drawScreen setLineWidth:width];
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
    [self setDrawColor:[button backgroundColor]];
}

-(void)setDrawColor:(UIColor *)color{
    [drawScreen setDrawColor:color];
}

-(void)setUnselected{
    for(UIButton* button in self.toolbarButtons){
        [button removeFromSuperview];
    }
}

-(IBAction)setSelectedButton:(UIButton*)button {
    DDLogVerbose(@"PencilTool: setSelectedButton Activated");
    [super.annoTree unselectAll];
    
    self.selected = YES;
    self.highlighted = NO;
    self.enabled = NO;
    
    for(UIButton* button in self.toolbarButtons){
        //button.hidden = YES;
        button.userInteractionEnabled = YES;
        [self.annoTree.annoTreeToolbar addSubview:button];
    }
    [drawScreen setDrawingEnabled:YES];
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
