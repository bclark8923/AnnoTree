//
//  ToolbarButton.m
//  AnnoTree Viewer
//
//  Created by Mike on 8/28/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "ToolbarButton.h"

@implementation ToolbarButton

/* Space between icons on toolbar */
int space = 35.0;
/* Size of toolbar icons */
int sizeIcon = 30;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:CGRectMake(0,space*2, sizeIcon, sizeIcon)];
        self.userInteractionEnabled = YES;
        [self setSelected:YES];
        [self setEnabled:NO];
        [self addTarget:self action:@selector(setSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(enableDisableDrawing:) forControlEvents:UIControlEventTouchUpInside];
        self.hidden = YES;
    }
    return self;
}

@end
