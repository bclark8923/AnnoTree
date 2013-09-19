//
//  PencilTool.m
//  AnnoTree Viewer
//
//  Created by Mike on 8/28/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "PencilTool.h"

@implementation PencilTool
@synthesize drawScreen;
@synthesize annoTree;

- (id)initWithFrame:(CGRect)frame annotree:(AnnoTree*)annotree
{
    self = [super initWithFrame:frame];
    if (self) {
        self.annoTree = annotree;

        UIImage *pencilIconImage = [UIImage imageNamed:@"AnnoTree.bundle/PencilIconToolbar.png"];
        UIImage *pencilIconImageSelected = [UIImage imageNamed:@"AnnoTree.bundle/PencilIconToolbarSelected.png"];
        [self setBackgroundImage:pencilIconImage forState:UIControlStateNormal];
        [self setBackgroundImage:pencilIconImageSelected forState:UIControlStateHighlighted];
        [self setBackgroundImage:pencilIconImageSelected forState:(UIControlStateDisabled|UIControlStateSelected)];
        [self.drawScreen.view setAutoresizesSubviews:YES];
        [self.drawScreen.view setAutoresizingMask: UIViewAutoresizingFlexibleWidth |
                UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

-(IBAction)setSelectedButton {
    [super setSelectedButton];
    [drawScreen setDrawingEnabled:self.selected];
    [self.annoTree.view insertSubview:drawScreen.view belowSubview:annoTree.annoTreeToolbar];
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
