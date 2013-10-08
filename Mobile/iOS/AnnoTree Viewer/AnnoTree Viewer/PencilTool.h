//
//  PencilTool.h
//  AnnoTree Viewer
//
//  Created by Mike on 8/28/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "ToolbarButton.h"
#import "DrawingViewController.h"

@interface PencilTool : ToolbarButton

@property (nonatomic, retain) DrawingViewController *drawScreen;
@property (nonatomic, retain) NSMutableArray *toolbarButtons;
- (id)initWithFrame:(CGRect)frame annotree:(AnnoTree*)annotree;
/*- (IBAction)setSelectedButton:(UIButton*)button;
*/
@end
