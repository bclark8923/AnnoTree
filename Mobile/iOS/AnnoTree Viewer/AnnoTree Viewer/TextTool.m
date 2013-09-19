//
//  TextTool.m
//  AnnoTree Viewer
//
//  Created by Mike on 8/31/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "TextTool.h"

@implementation TextTool

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //[self setFrame:CGRectMake(0,space*2, sizeIcon, sizeIcon)];
        UIImage *textIconImage = [UIImage imageNamed:@"AnnoTree.bundle/TextIconToolbar.png"];
        UIImage *textIconImageSelected = [UIImage imageNamed:@"AnnoTree.bundle/TextIconToolbarSelected.png"];
        [self setBackgroundImage:textIconImage forState:UIControlStateNormal];
        [self setBackgroundImage:textIconImageSelected forState:UIControlStateHighlighted];
        [self setBackgroundImage:textIconImageSelected forState:(UIControlStateDisabled|UIControlStateSelected)];
    
    }
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
