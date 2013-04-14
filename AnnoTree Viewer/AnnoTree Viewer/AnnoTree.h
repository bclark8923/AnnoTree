//
//  AnnoTree.h
//  AnnoTree Viewer
//
//  Created by Brian Clark on 3/25/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnnoTree : UIViewController {
    //UIWindow *AnnoTreeWindow;
}

@property (nonatomic, retain) UIWindow *AnnoTreeWindow;
@property (nonatomic, retain) UIButton *openAnnoTreeButton;
@property (nonatomic, retain) UIView *annoTreeToolbar;
@property (nonatomic, retain) NSMutableArray *annotations;

/* Temp */
@property (nonatomic, retain) UILongPressGestureRecognizer *addTextGesture;

//+ (AnnoTree *)instance;

+ (id)sharedInstance;

- (void)loadFingerDrawing;

-(UIButton*)getAnnoTreeLauncher;

@end
