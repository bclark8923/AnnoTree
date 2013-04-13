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
@property (nonatomic, retain) UIWindow *MainWindow;
@property (nonatomic, retain) UITapGestureRecognizer *openGesture;
@property (nonatomic, retain) IBOutlet UIImageView *closeAnnoTree;
@property (nonatomic, retain) UITapGestureRecognizer *closeGesture;
@property (nonatomic, retain) UILongPressGestureRecognizer *addTextGesture;
@property (nonatomic, retain) UIViewController *annoTreeView;

//+ (AnnoTree *)instance;

+ (id)sharedInstance;

- (void)loadFingerDrawing;

- (void)openTree:(UIGestureRecognizer*)gr;

- (void)loadTree:(UIViewController*) appView;

- (void)initializeTree;

-(UIView*)getAnnoTree;

@end
