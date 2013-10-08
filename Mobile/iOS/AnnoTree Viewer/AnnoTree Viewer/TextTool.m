//
//  TextTool.m
//  AnnoTree Viewer
//
//  Created by Mike on 8/31/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "TextTool.h"
#import "DDLog.h"

@implementation TextTool
@synthesize drawScreen;
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
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
        /*[self addColorButton:[UIColor redColor] buttonLocation:1];
        [self addColorButton:[UIColor blueColor] buttonLocation:2];
        [self addColorButton:[UIColor greenColor] buttonLocation:3];
        */
        drawScreen = [[DrawingViewController alloc] init];
    }
    return self;
}


-(void)addColorButton:(UIColor *)color buttonLocation:(int)buttonLocation{
    DDLogVerbose(@"Adding color button color:");
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(self.annoTree.space*1.5,self.annoTree.space*buttonLocation/2, self.annoTree.sizeIcon/2, self.annoTree.sizeIcon/2)];
    [button setBackgroundColor:color];
    button.userInteractionEnabled = YES;
    [button addTarget:self action:@selector(colorSelector:) forControlEvents:UIControlEventTouchUpInside];
    button.hidden = YES;
    [self.annoTree.toolbarButtons addObject:button];
    [self.annoTree.annoTreeToolbar addSubview:button];
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
        //TODO:REMOVE THESE
    }
}
-(IBAction)setSelectedButton:(UIButton*)button {
    NSLog(@"Log Fail");
    DDLogVerbose(@"TextTool: setSelectedButton Activated");
    
    [super.annoTree unselectAll];
    
    for(UIButton* button in self.toolbarButtons){
        button.userInteractionEnabled = YES;
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
