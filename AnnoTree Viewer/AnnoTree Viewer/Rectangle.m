//
//  Rectangle.m
//  AnnoTree Viewer
//
//  Created by Brian Clark on 4/13/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "Rectangle.h"

@implementation Rectangle

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

    //double color = 63/255;
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
    
    CGContextSetRGBFillColor(ctx, red, green, blue, 1);// 3
    CGContextFillRect (ctx, rect);
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
