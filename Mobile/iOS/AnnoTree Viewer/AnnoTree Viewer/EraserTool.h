//
//  EraserTool.h
//  AnnoTree Viewer
//
//  Created by Mike on 10/9/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <AnnoTree/AnnoTree.h>
#import "ToolbarButton.h"

@interface EraserTool : ToolbarButton

- (id)initWithFrame:(CGRect)frame annotree:(AnnoTree*)annotree drawScreen:(DrawingViewController*)drawScreen;
@end
