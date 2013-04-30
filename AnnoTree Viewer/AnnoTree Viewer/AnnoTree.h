//
//  AnnoTree.h
//  AnnoTree Viewer
//
//  Created by Brian Clark on 3/25/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareViewController.h"
#import "UIWindowAnnoTree.h"

@interface AnnoTree : UIViewController {
    //UIWindow *AnnoTreeWindow;
}

@property (nonatomic, retain) UIWindowAnnoTree *annoTreeWindow;
@property (nonatomic, retain) UIButton *openAnnoTreeButton;
@property (nonatomic, retain) UIView *annoTreeToolbar;
@property (nonatomic, retain) NSMutableArray *annotations;
@property (nonatomic, retain) NSMutableArray *toolbarButtons;
@property (nonatomic, retain) NSMutableArray *toolbarObjects;
@property (nonatomic, retain) ShareViewController *shareView;
@property BOOL enabled;

/* Temp */
@property (nonatomic, retain) UILongPressGestureRecognizer *addTextGesture;

//+ (AnnoTree *)instance;

+ (id)sharedInstance;

// - (void)loadFingerDrawing;

- (void) loadTree:(UIInterfaceOrientationMask)orientation;

//- (UIView*)getAnnoTreeLauncher:(UIInterfaceOrientationMask)orientation;

@end
