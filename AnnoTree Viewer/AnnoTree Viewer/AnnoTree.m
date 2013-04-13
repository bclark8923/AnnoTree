//
//  AnnoTree.m
//  AnnoTree Viewer
//
//  Created by Brian Clark on 3/25/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "AnnoTree.h"
#import "MyLineDrawingView.h"
#import "Rectangle.h"
#import "AnnoTreeUserLaunchViewController.h"

@interface AnnoTree ()

@end

@implementation AnnoTree

@synthesize AnnoTreeWindow;
@synthesize MainWindow;
@synthesize closeGesture;
@synthesize closeAnnoTree;
@synthesize openGesture;
@synthesize addTextGesture;
@synthesize annoTreeView;
@synthesize openAnnoTreeButton;
@synthesize closeAnnoTreeButton;
@synthesize annotations;
@synthesize annoTreeToolbar;

/*
+ (AnnoTree *)instance
{
    static AnnoTree *instance = nil;
    
    @synchronized(self)
    {
        if (instance == nil)
        {
            instance = [[AnnoTree alloc] init];
        }
    }
    
    return instance;
}*/

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {        
        /* Initiate the annotation window */
        AnnoTreeWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        AnnoTreeWindow.windowLevel = UIWindowLevelStatusBar;
        AnnoTreeWindow.rootViewController = self;
        AnnoTreeWindow.hidden = YES;
        AnnoTreeWindow.backgroundColor = [UIColor clearColor];
        
        int space = 35.0;
        int sizeIcon = 30;
        
        
        /* Gestures for anno tree */
        closeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTree:)];
        closeGesture.numberOfTapsRequired = 2;
        [closeAnnoTree addGestureRecognizer:closeGesture];
        closeAnnoTree.userInteractionEnabled = YES;
        
        addTextGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addText:)];
        addTextGesture.minimumPressDuration = 1;
        [AnnoTreeWindow addGestureRecognizer:addTextGesture];
        
        openGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openTree:)];
        openGesture.numberOfTapsRequired = 2;
        
        
        /* Create button to be loaded into user apps views to launch anno tree */
        UIImage *annoTreeImage = [UIImage imageNamed:@"AnnoTreeLogo.png"];
        openAnnoTreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        openAnnoTreeButton.userInteractionEnabled = YES;
        [openAnnoTreeButton setFrame:CGRectMake(0.0,0.0, sizeIcon, sizeIcon)];
        [openAnnoTreeButton setBackgroundImage:annoTreeImage forState:UIControlStateNormal];
        [openAnnoTreeButton addGestureRecognizer:openGesture];
        [openAnnoTreeButton addTarget:self action:@selector(wasDragged:withEvent:)
          forControlEvents:UIControlEventTouchDragInside];
        
        
        /* create the toolbar to be loaded */
        annoTreeToolbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, sizeIcon, space*5+sizeIcon)];
        annoTreeToolbar.userInteractionEnabled = YES;
        
        Rectangle *toolbarBg = [[Rectangle alloc] initWithFrame:CGRectMake(0,sizeIcon/2, sizeIcon, space*5)];
        [annoTreeToolbar addSubview:toolbarBg];
        
        UIImageView *pencilIconToolbarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,space, sizeIcon, sizeIcon)];
        UIImage *pencilIconImage = [UIImage imageNamed:@"PencilIconToolbar.png"];
        pencilIconToolbarImageView.image = pencilIconImage;
        [annoTreeToolbar addSubview:pencilIconToolbarImageView];
        
        UIImageView *textIconToolbarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,space*2, sizeIcon, sizeIcon)];
        UIImage *textIconImage = [UIImage imageNamed:@"TextIconToolbar.png"];
        textIconToolbarImageView.image = textIconImage;
        [annoTreeToolbar addSubview:textIconToolbarImageView];
        
        UIImageView *selectIconToolbarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,space*3, sizeIcon, sizeIcon)];
        UIImage *selectIconImage = [UIImage imageNamed:@"SelectIconToolbar.png"];
        selectIconToolbarImageView.image = selectIconImage;
        [annoTreeToolbar addSubview:selectIconToolbarImageView];
        
        UIImageView *shareIconToolbarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,space*4, sizeIcon, sizeIcon)];
        UIImage *shareIconImage = [UIImage imageNamed:@"ShareIconToolbar.png"];
        shareIconToolbarImageView.image = shareIconImage;
        [annoTreeToolbar addSubview:shareIconToolbarImageView];
        
        UIButton *annoTreeImageOpenView = [[UIButton alloc] initWithFrame:openAnnoTreeButton.frame];
        [annoTreeImageOpenView setBackgroundImage:annoTreeImage forState:UIControlStateNormal];
        [annoTreeImageOpenView addTarget:self action:@selector(toolbarWasDragged:withEvent:)
                     forControlEvents:UIControlEventTouchDragInside];
        [annoTreeToolbar addSubview:annoTreeImageOpenView];
        
        UIImage *cancelImg = [UIImage imageNamed:@"CloseIconToolbar.png"];
        closeAnnoTreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeAnnoTreeButton.userInteractionEnabled = YES;
        [closeAnnoTreeButton setFrame:CGRectMake(0,space*5, sizeIcon, sizeIcon)];
        [closeAnnoTreeButton setBackgroundImage:cancelImg forState:UIControlStateNormal];
        [closeAnnoTreeButton addGestureRecognizer:closeGesture];
        [annoTreeToolbar addSubview:closeAnnoTreeButton];
        
        [self.view addSubview:annoTreeToolbar];
        
        
        /* initiate array to hold the annotations - drawings and text */
        annotations = [[NSMutableArray alloc] init];
    }
    return self;
}

-(UIButton*)getAnnoTreeLauncher
{
    return openAnnoTreeButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) addText:(UITapGestureRecognizer*)gr
{
    if (gr.state == UIGestureRecognizerStateBegan) {
        CGPoint coords = [gr locationOfTouch:0 inView:self.view];

        float textboxWidth = 100;
        float textboxHeight = 40;
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(coords.x-(textboxWidth/2), coords.y-(textboxHeight/2), textboxWidth, textboxHeight)];
        
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.font = [UIFont systemFontOfSize:15];
        textField.placeholder = @"enter text";
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.view addSubview:textField];
    }
}

- (void)initializeTree {}

- (void) loadTree:(UIViewController*) appView
{
    [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:annoTreeView.view];
}

#define CGRectSetPos( r, x, y ) CGRectMake( x, y, r.size.width, r.size.height )

- (void) openTree:(UIGestureRecognizer*)gr
{
    AnnoTreeWindow.hidden = NO;
    [AnnoTreeWindow makeKeyAndVisible];
    [openAnnoTreeButton setHidden:YES];
    annoTreeToolbar.frame = CGRectSetPos (annoTreeToolbar.frame, openAnnoTreeButton.frame.origin.x, openAnnoTreeButton.frame.origin.y);
    [self loadFingerDrawing];
}

-(void)closeTree:(UIGestureRecognizer*)gr
{
    [self removeTree];
    [openAnnoTreeButton setHidden:NO];
}

-(void) removeTree
{
    for (UIView *drawings in annotations) {
        [drawings removeFromSuperview];
    }
    [annotations removeAllObjects];
    AnnoTreeWindow.hidden = YES;
    [MainWindow makeKeyAndVisible];
}

- (void) loadFingerDrawing
{
    MyLineDrawingView *drawScreen=[[MyLineDrawingView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    [annotations addObject:drawScreen];
     [self.view insertSubview:drawScreen belowSubview:annoTreeToolbar];
}

- (void)toolbarWasDragged:(UIButton *)button withEvent:(UIEvent *)event
{
	// get the touch
	UITouch *touch = [[event touchesForView:button] anyObject];
    
	// get delta
	CGPoint previousLocation = [touch previousLocationInView:button];
	CGPoint location = [touch locationInView:button];
	CGFloat delta_x = location.x - previousLocation.x;
	CGFloat delta_y = location.y - previousLocation.y;
    
	// move open button and toolbar
	annoTreeToolbar.center = CGPointMake(annoTreeToolbar.center.x + delta_x,
                                         annoTreeToolbar.center.y + delta_y);
    openAnnoTreeButton.center = CGPointMake(openAnnoTreeButton.center.x + delta_x,
                                            openAnnoTreeButton.center.y + delta_y);
}

- (void)wasDragged:(UIButton *)button withEvent:(UIEvent *)event
{
	// get the touch
	UITouch *touch = [[event touchesForView:button] anyObject];
    
	// get delta
	CGPoint previousLocation = [touch previousLocationInView:button];
	CGPoint location = [touch locationInView:button];
	CGFloat delta_x = location.x - previousLocation.x;
	CGFloat delta_y = location.y - previousLocation.y;
    
	// move open button
	button.center = CGPointMake(button.center.x + delta_x,
                                button.center.y + delta_y);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
