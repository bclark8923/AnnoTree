//
//  TextTool.h
//  AnnoTree Viewer
//
//  Created by Mike on 8/31/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "ToolbarButton.h"
#import "ToolbarButtonWithColorSelector.h"

@interface TextTool : ToolbarButtonWithColorSelector

- (id)initWithFrame:(CGRect)frame annotree:(AnnoTree*)annotree drawScreen:(DrawingViewController*)drawScreen;
- (IBAction)setSelectedButton:(UIButton*)button;

@end
