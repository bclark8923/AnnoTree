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
#import <QuartzCore/QuartzCore.h>

@implementation TextTool

static const int ddLogLevel = LOG_LEVEL_ERROR;


- (id)initWithFrame:(CGRect)frame annotree:(AnnoTree*)annotree
{
    self = [super initWithFrame:frame annotree:annotree];
    if (self) {
        self.toolbarButtons = [[NSMutableArray alloc] init];
        UIImage *textIconImage = [UIImage imageNamed:@"AnnoTree.bundle/TextIconToolbar.png"];
        UIImage *textIconImageSelected = [UIImage imageNamed:@"AnnoTree.bundle/TextIconToolbarSelected.png"];
        [self setBackgroundImage:textIconImage forState:UIControlStateNormal];
        [self setBackgroundImage:textIconImageSelected forState:UIControlStateHighlighted];
        [self setBackgroundImage:textIconImageSelected forState:(UIControlStateDisabled|UIControlStateSelected)];
        [self addTarget:self action:@selector(setSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
        
        self.drawScreen = [[DrawingViewController alloc] init];
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
        
        [self colorSelector:self.toolbarButtons[1]];
        [self sizeSelector:self.toolbarButtons[4]];
        
        
    }
    return self;
}

-(IBAction)setSelectedButton:(UIButton*)button{
    [super setSelectedButton:button];
    [self.drawScreen setTextEnabled:YES];
}


-(void)setColor:(UIColor *)color{
    [self setTextColor:color];
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


-(void)setTextSize:(int)size{
    [self.drawScreen setTextSize:size];
}

-(IBAction)sizeSelector:(UIButton*)button{
    DDLogVerbose(@"Setting Color");
    for(UIButton*b in self.toolbarButtons){
        if([b tag]){
            b.layer.borderWidth = 0.0f;
        }
    }
    [[button layer] setBorderWidth:2.0f];
    [self.drawScreen setTextSize:button.tag];
}

-(void)setTextColor:(UIColor *)color{
    [self.drawScreen setTextColor:color];
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
