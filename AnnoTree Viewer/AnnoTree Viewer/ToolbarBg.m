//
//  Rectangle.m
//  AnnoTree Viewer
//
//  Created by Brian Clark on 4/13/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "ToolbarBg.h"

@implementation ToolbarBg

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    //Convert from Hex ;
    UIColor *bgColor = UIColorFromRGB(0x3F3F3F);
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    
    if ([bgColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [bgColor getRed:&red green:&green blue:&blue alpha:&alpha];
    } else {
        const CGFloat *components = CGColorGetComponents(bgColor.CGColor);
        red = components[0];
        green = components[1];
        blue = components[2];
        alpha = components[3];
    }
    
    CGContextSetRGBFillColor(ctx, red, green, blue, 1);
    
    /* Draw the rectangle toolbar background */
    CGContextFillRect (ctx, CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-(rect.size.width/2)));
    
    /* Draw the circle at the bottom of the toolbar */
    CGContextAddEllipseInRect(ctx, CGRectMake(rect.origin.x, rect.size.height-(rect.size.width), rect.size.width, rect.size.width));
    CGContextFillPath(ctx);
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
