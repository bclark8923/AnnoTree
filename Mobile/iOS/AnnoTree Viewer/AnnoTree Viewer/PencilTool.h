//
//  PencilTool.h
//  AnnoTree Viewer
//
//  Created by Mike on 8/28/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "ToolbarButton.h"
#import "DrawingViewController.h"
#import "ToolbarButtonWithColorSelector.h"

@interface PencilTool : ToolbarButtonWithColorSelector


- (id)initWithFrame:(CGRect)frame annotree:(AnnoTree*)annotree drawScreen:(DrawingViewController*)drawScreen;
/*- (IBAction)setSelectedButton:(UIButton*)button;
*/
@end
