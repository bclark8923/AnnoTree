//
//  EraserTool.m
//  AnnoTree Viewer
//
//  Created by Mike on 10/9/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "EraserTool.h"

@implementation EraserTool

- (id)initWithFrame:(CGRect)frame annotree:(AnnoTree*)annotree drawScreen:(DrawingViewController*)drawScreen
{
    self = [super initWithFrame:frame annotree:annotree];
    if (self) {
        self.toolbarButtons = [[NSMutableArray alloc] init];
        UIImage *textIconImage = [UIImage imageNamed:@"AnnoTree.bundle/EraserIconToolbar.png"];
        UIImage *textIconImageSelected = [UIImage imageNamed:@"AnnoTree.bundle/EraserIconToolbarSelected.png"];
        [self setBackgroundImage:textIconImage forState:UIControlStateNormal];
        [self setBackgroundImage:textIconImageSelected forState:UIControlStateHighlighted];
        [self setBackgroundImage:textIconImageSelected forState:(UIControlStateDisabled|UIControlStateSelected)];
        [self addTarget:self action:@selector(setSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
        self.drawScreen = drawScreen;
        [self.drawScreen.view setAutoresizesSubviews:YES];
        [self.drawScreen.view setAutoresizingMask: UIViewAutoresizingFlexibleWidth |
         UIViewAutoresizingFlexibleHeight];
        
    }
    return self;
}


-(IBAction)setSelectedButton:(UIButton*)button{
    [super.annoTree unselectAll];
    [self.drawScreen setDeleteEnabled:YES];
    self.selected = YES;
    self.highlighted = NO;
    self.enabled = NO;
    [super.annoTree.view insertSubview:self.drawScreen.view belowSubview:super.annoTree.annoTreeToolbar];}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
