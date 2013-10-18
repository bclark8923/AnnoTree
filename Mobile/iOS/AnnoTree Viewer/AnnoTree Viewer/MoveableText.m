//
//  MoveableText.m
//  AnnoTree Viewer
//
//  Created by Michael Max on 8/8/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "MoveableText.h"
#import "DDLog.h"

@implementation MoveableText

CGPoint startLocation;
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    // Retrieve the touch point
    CGPoint pt = [[touches anyObject] locationInView:self];
    startLocation = pt;
    
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGPoint pt = [[touches anyObject] locationInView:self];
    CGFloat dx = pt.x - startLocation.x;
    CGFloat dy = pt.y - startLocation.y;
    CGPoint newCenter = CGPointMake(self.center.x + dx, self.center.y + dy);
    self.center = newCenter;
}

@end
