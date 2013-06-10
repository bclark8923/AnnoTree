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
#import "AnnotationViewController.h"

@interface AnnoTree : UIViewController {
    //UIWindow *AnnoTreeWindow;
}

@property (nonatomic, retain) UIWindowAnnoTree *annoTreeWindow;
@property (nonatomic, retain) UIWindow *keyWindow;
@property (nonatomic, retain) UIButton *openAnnoTreeButton;
@property (nonatomic, retain) UIView *annoTreeToolbar;
@property (nonatomic, retain) NSMutableArray *annotations;
@property (nonatomic, retain) NSMutableArray *toolbarButtons;
@property (nonatomic, retain) NSMutableArray *toolbarObjects;
@property (nonatomic, retain) ShareViewController *shareView;
@property (nonatomic, retain) AnnotationViewController *drawScreen;
@property (nonatomic, retain) UIButton *annoTreeImageOpenView;
@property (nonatomic, retain) NSString *activeTree;
@property NSUInteger supportedOrientation;
@property BOOL enabled;
@property BOOL drawEnabled;
@property BOOL textEnabled;
@property BOOL selectEnabled;
@property int textViewHeightHold;
@property int keyboardHeight;
@property GLuint colorRenderbuffer;


/* Temp */
@property (nonatomic, retain) UILongPressGestureRecognizer *addTextGesture;

+ (id)sharedInstance;

- (void) loadAnnoTree:(NSUInteger)orientation withTree:(NSString*)tree;

@end
