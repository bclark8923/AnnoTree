//
//  ToolbarButton.m
//  AnnoTree Viewer
//
//  Created by Mike on 8/28/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "ToolbarButton.h"

@implementation ToolbarButton


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        [self setSelected:NO];
        [self setEnabled:NO];
        [self addTarget:self action:@selector(setSelectedButton) forControlEvents:UIControlEventTouchUpInside];
        self.hidden = YES;
    }
    return self;
}

-(IBAction)setSelectedButton{
    [super setSelected:true];
    //Select clicked button and disable it
    self.selected = YES;
    self.highlighted = NO;
    self.enabled = NO;
}
@end
