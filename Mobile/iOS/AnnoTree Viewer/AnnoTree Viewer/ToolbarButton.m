//
//  ToolbarButton.m
//  AnnoTree Viewer
//
//  Created by Mike on 8/28/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "ToolbarButton.h"

@implementation ToolbarButton

@synthesize annoTree;


- (id)initWithFrame:(CGRect)frame annotree:(AnnoTree*)annotree
{
    self = [super initWithFrame:frame];
    if (self) {
        self.annoTree = annotree;
        self.userInteractionEnabled = YES;
        [self setSelected:NO];
        //[self setEnabled:NO];
        //[self addTarget:self action:@selector(setSelectedButton) forControlEvents:UIControlEventTouchUpInside];
        self.hidden = YES;
    }
    return self;
}

-(void)setUnselected{
    [self setSelected:NO];
    [self setEnabled:NO];
}
-(void)clearAll{

}


@end
