//
//  ToolbarButton.h
//  AnnoTree Viewer
//
//  Created by Mike on 8/28/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnoTree.h"

@interface ToolbarButton : UIButton

@property AnnoTree *annoTree;
@property (nonatomic, retain) DrawingViewController *drawScreen;
@property (nonatomic, retain) NSMutableArray *toolbarButtons;

- (id)initWithFrame:(CGRect)frame annotree:(AnnoTree*)annotree;
- (void)setUnselected;
- (void)clearAll;
@end
