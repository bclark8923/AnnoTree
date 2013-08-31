//
//  PencilTool.m
//  AnnoTree Viewer
//
//  Created by Mike on 8/28/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "PencilTool.h"

@implementation PencilTool

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *pencilIconImage = [UIImage imageNamed:@"AnnoTree.bundle/PencilIconToolbar.png"];
        UIImage *pencilIconImageSelected = [UIImage imageNamed:@"AnnoTree.bundle/PencilIconToolbarSelected.png"];
        [self setBackgroundImage:pencilIconImage forState:UIControlStateNormal];
        [self setBackgroundImage:pencilIconImageSelected forState:UIControlStateHighlighted];
        [self setBackgroundImage:pencilIconImageSelected forState:(UIControlStateDisabled|UIControlStateSelected)];    }
    return self;
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
