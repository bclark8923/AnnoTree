//
//  PencilTool.m
//  AnnoTree Viewer
//
//  Created by Mike on 8/28/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "PencilTool.h"
#import "DDLog.h"

@implementation PencilTool

static const int ddLogLevel = LOG_LEVEL_VERBOSE;
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
        /*Add Color Buttons
        [self addColorButton:[UIColor redColor] buttonLocation:1];
        [self addColorButto	n:[UIColor blueColor] buttonLocation:2];
        [self addColorButton:[UIColor greenColor] buttonLocation:3];
         */
    }
    return self;
}

-(void)addColorButton:(UIColor *)color buttonLocation:(int)buttonLocation{
    DDLogVerbose(@"Adding color button color:");
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    //[button :button];
    [button setFrame:CGRectMake(self.annoTree.space*1,self.annoTree.space*buttonLocation/2, self.annoTree.sizeIcon/2, self.annoTree.sizeIcon/2)];
    [button setBackgroundColor:color];
    button.userInteractionEnabled = YES;
    //[button setSelected:NO];
    [button addTarget:self action:@selector(colorSelector:) forControlEvents:UIControlEventTouchUpInside];
    button.hidden = YES;
    [self.annoTree.toolbarButtons addObject:button];
    [self.annoTree.annoTreeToolbar addSubview:button];
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
        //[button removeFromSuperview];
    }
}

-(IBAction)setSelectedButton:(UIButton*)button {
    NSLog(@"Log Fail");
    DDLogVerbose(@"PencilTool: setSelectedButton Activated");
    [super.annoTree unselectAll];
    
    self.selected = YES;
    self.highlighted = NO;
    self.enabled = NO;
    
    for(UIButton* button in self.toolbarButtons){
        //button.hidden = YES;
        button.userInteractionEnabled = YES;
        //[self.annoTree.annoTreeToolbar addSubview:button];
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
