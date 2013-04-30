//
//  UIWindowAnnoTree.m
//  AnnoTree Viewer
//
//  Created by Brian Clark on 4/30/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "UIWindowAnnoTree.h"

@implementation UIWindowAnnoTree

@synthesize enabled;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        enabled = NO;    }
    return self;
}

-(void)setButton:(UIButton *)button {
    annoTreeButton = button;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if([annoTreeButton pointInside:[self convertPoint:point toView:annoTreeButton] withEvent:event] ) {
        return YES;
    }
    
    if(enabled) {
        return YES;
    }
    return NO;
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
