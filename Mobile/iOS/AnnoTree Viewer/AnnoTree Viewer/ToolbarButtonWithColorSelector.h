//
//  ToolbarButtonWithColorSelector.h
//  AnnoTree Viewer
//
//  Created by Mike on 10/10/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <AnnoTree/AnnoTree.h>
#import "ToolbarButton.h"
#import "ToolbarBg.h"

@interface ToolbarButtonWithColorSelector : ToolbarButton
-(void)setUnselected;
-(void)addRectangleForToolbar:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2;
-(IBAction)setSelectedButton:(UIButton*)button;
-(void)addColorButton:(UIColor *)color buttonLocation:(int)buttonLocation;
-(IBAction)colorSelector:(UIButton*)button ;
-(void)setColor:(UIColor*)color;
-(void)clearAll;

@end
