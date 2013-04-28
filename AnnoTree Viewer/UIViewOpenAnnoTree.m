//
//  UIViewOpenAnnoTree.m
//  AnnoTree Viewer
//
//  Created by Brian Clark on 4/28/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "UIViewOpenAnnoTree.h"

@implementation UIViewOpenAnnoTree

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for( id foundView in self.subviews )
    {
        if( [foundView isKindOfClass:[UIButton class]] )
        {
            UIButton *foundButton = foundView;
            
            if( foundButton.isEnabled  &&  !foundButton.hidden &&  [foundButton pointInside:[self convertPoint:point toView:foundButton] withEvent:event] )
                return YES;
        }
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
