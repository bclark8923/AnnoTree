//
//  UIWindowAnnoTree.h
//  AnnoTree Viewer
//
//  Created by Brian Clark on 4/30/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindowAnnoTree : UIWindow {
    UIButton* annoTreeButton;
}

@property BOOL enabled;
//@property UIInterfaceOrientation

- (void)setButton:(UIButton*)button;

@end
