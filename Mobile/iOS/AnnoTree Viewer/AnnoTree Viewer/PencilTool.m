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
#import <QuartzCore/QuartzCore.h>
#import "AnnoTree.h"

@implementation PencilTool

static const int ddLogLevel = LOG_LEVEL_ERROR;

- (id)initWithFrame:(CGRect)frame annotree:(AnnoTree*)annotree drawScreen:(DrawingViewController*)drawScreen{
    self = [super initWithFrame:frame annotree:annotree];
    if (self) {
        DDLogVerbose(@"Creating Penil Icon");
        self.toolbarButtons = [[NSMutableArray alloc] init];
        UIImage *pencilIconImage = [UIImage imageNamed:@"AnnoTree.bundle/PencilIconToolbar.png"];
        UIImage *pencilIconImageSelected = [UIImage imageNamed:@"AnnoTree.bundle/PencilIconToolbarSelected.png"];
        [self setBackgroundImage:pencilIconImage forState:UIControlStateNormal];
        [self setBackgroundImage:pencilIconImageSelected forState:UIControlStateHighlighted];
        [self setBackgroundImage:pencilIconImageSelected forState:(UIControlStateDisabled|UIControlStateSelected)];
        [self addTarget:self action:@selector(setSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.drawScreen.view setAutoresizesSubviews:YES];
        [self.drawScreen.view setAutoresizingMask: UIViewAutoresizingFlexibleWidth |
                UIViewAutoresizingFlexibleHeight];
        
        self.drawScreen = drawScreen;
        [self setColor:[UIColor redColor]];
        [self setWidth:4];
        [self addRectangleForToolbar:self.annoTree.space*.9 y1:self.annoTree.space*.9 x2:self.annoTree.sizeIcon*1.8 y2:self.annoTree.sizeIcon*2.9];
        /*Add Color Buttons*/
        [self addColorButton:[UIColor redColor] buttonLocation:0];
        [self addColorButton:[UIColor blueColor] buttonLocation:1];
        [self addColorButton:[UIColor greenColor] buttonLocation:2];
        [self addLineButton:4 buttonLocation:0];
        [self addLineButton:10 buttonLocation:1];
        [self addLineButton:16 buttonLocation:2];
        [self colorSelector:self.toolbarButtons[1]];
        [self widthSelector:self.toolbarButtons[4]];
        [self addUndoButton];
        [self addRedoButton];
        
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
    [button addTarget:self action:@selector(widthSelector:) forControlEvents:UIControlEventTouchUpInside];
    //[button setBackgroundColor:[UIColor blackColor]];
    button.userInteractionEnabled = YES;
    button.hidden = YES;
    [self.annoTree.toolbarButtons addObject:button];
    [self.toolbarButtons addObject:button];
}

-(UIButton*)addUndoRedoButton:(int)buttonLocation imageLocation:(NSString*)imageLocation{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    int x1 = self.annoTree.space*(1 + buttonLocation/2.0);
    int y1 = self.annoTree.space*(3);
    int x2 = self.annoTree.sizeIcon*.5;
    int y2 = self.annoTree.sizeIcon/2;
    [button setFrame:CGRectMake(x1, y1, x2, y2)];
    [button setBackgroundImage:[UIImage imageNamed:imageLocation] forState:UIControlStateNormal];
    button.userInteractionEnabled = YES;
    button.hidden = YES;
    [self.annoTree.toolbarButtons addObject:button];
    [self.toolbarButtons addObject:button];
    return button;
}
-(void) addUndoButton{
    UIButton* undo = [self addUndoRedoButton:0 imageLocation:@"AnnoTree.bundle/UndoIconToolbar.png"];
    [undo addTarget:self action:@selector(undo:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) addRedoButton{
    UIButton* redo = [self addUndoRedoButton:1 imageLocation:@"AnnoTree.bundle/RedoIconToolbar.png"];
    [redo addTarget:self action:@selector(redo:) forControlEvents:UIControlEventTouchUpInside];
}


-(IBAction)setSelectedButton:(UIButton*)button{
    [super setSelectedButton:button];
    [self.drawScreen setDrawingEnabled:YES];
}

-(IBAction)undo:(UIButton*)button{
    [self.drawScreen undo];
}

-(IBAction)redo:(UIButton*)button{
    [self.drawScreen redo];
}


-(IBAction)widthSelector:(UIButton*)button {
    DDLogVerbose(@"Setting Color");
    for(UIButton*b in self.toolbarButtons){
        if([b tag]){
            b.layer.borderWidth = 0.0f;
        }
    }
    [[button layer] setBorderWidth:2.0f];
    [self setWidth:[button tag]];
}


-(void)setWidth:(int)width{
    [self.drawScreen setLineWidth:width];
}

-(void)setColor:(UIColor *)color{    
    [self.drawScreen setDrawColor:color];
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
