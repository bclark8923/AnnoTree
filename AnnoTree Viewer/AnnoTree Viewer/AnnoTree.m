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
#import "ShareViewController.h"
#import "AnnoTreeUserLaunchViewController.h"

@interface AnnoTree ()

@end

@implementation AnnoTree

@synthesize AnnoTreeWindow;
@synthesize openAnnoTreeButton;
@synthesize annoTreeToolbar;
@synthesize annotations;
@synthesize toolbarButtons;
@synthesize shareView;
@synthesize openAnnoTreeView;

/* Temp */
@synthesize addTextGesture;

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
        int max = [[UIScreen mainScreen] bounds].size.height;
        //CGRect obj = [[UIScreen mainScreen] bounds];
        //[self.view setFrame:CGRectMake(0, 0, max, max)];
        AnnoTreeWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, max, max)];
        AnnoTreeWindow.windowLevel = UIWindowLevelStatusBar;
        AnnoTreeWindow.rootViewController = self;
        AnnoTreeWindow.hidden = YES;
        AnnoTreeWindow.backgroundColor = [UIColor clearColor];
        
        /* Space between icons on toolbar */
        int space = 35.0;
        /* Size of toolbar icons */
        int sizeIcon = 30;
        
        
        
        /* initiate array to hold the annotations - drawings and text */
        annotations = [[NSMutableArray alloc] init];
        toolbarButtons = [[NSMutableArray alloc] init];
        
        /* Gestures for anno tree */
        /* Gesture to open anno tree from icon */
        UITapGestureRecognizer *openGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openTree:)];
        openGesture.numberOfTapsRequired = 2;
        
        /* Gesture to close anno tree toolbar from close button */
        UITapGestureRecognizer *closeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTree:)];
        closeGesture.numberOfTapsRequired = 2;
        
        /* Gesture to close anno tree toolbar from logo */
        UITapGestureRecognizer *logoCloseGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTree:)];
        logoCloseGesture.numberOfTapsRequired = 2;
        
        /* Temp gesture to add text */
        addTextGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addText:)];
        addTextGesture.minimumPressDuration = 1;
        [AnnoTreeWindow addGestureRecognizer:addTextGesture];
        
        
        /* Create button to be loaded into openAnnoTree view to launch anno tree */
        UIImage *annoTreeImage = [UIImage imageNamed:@"AnnoTreeLogo.png"];
        openAnnoTreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        openAnnoTreeButton.userInteractionEnabled = YES;
        [openAnnoTreeButton setFrame:CGRectMake(20.0,20.0, sizeIcon, sizeIcon)];
        [openAnnoTreeButton setBackgroundImage:annoTreeImage forState:UIControlStateNormal];
        [openAnnoTreeButton addGestureRecognizer:openGesture];
        [openAnnoTreeButton addTarget:self action:@selector(wasDragged:withEvent:)
          forControlEvents:UIControlEventTouchDragInside];
        
        /* Create view that will hold button and be put into users app */
        openAnnoTreeView = [[UIView alloc] init];
        [openAnnoTreeView addSubview:openAnnoTreeButton];
        
        /* create the toolbar to be loaded */
        annoTreeToolbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, sizeIcon, space*5+sizeIcon)];
        annoTreeToolbar.userInteractionEnabled = YES;
        
        /* rectangle background for toolbar */
        Rectangle *toolbarBg = [[Rectangle alloc] initWithFrame:CGRectMake(0,sizeIcon/2, sizeIcon, space*5)];
        [annoTreeToolbar addSubview:toolbarBg];
        
        /* Pencil Icon for toolbar */
        UIButton *pencilIconToolbarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [pencilIconToolbarButton setFrame:CGRectMake(0,space, sizeIcon, sizeIcon)];
        pencilIconToolbarButton.userInteractionEnabled = YES;
        UIImage *pencilIconImage = [UIImage imageNamed:@"PencilIconToolbar.png"];
        UIImage *pencilIconImageSelected = [UIImage imageNamed:@"PencilIconToolbarSelected.png"];
        [pencilIconToolbarButton setBackgroundImage:pencilIconImage forState:UIControlStateNormal];
        [pencilIconToolbarButton setBackgroundImage:pencilIconImageSelected forState:UIControlStateHighlighted];
        [pencilIconToolbarButton setBackgroundImage:pencilIconImageSelected forState:(UIControlStateDisabled|UIControlStateSelected)];
        [pencilIconToolbarButton setSelected:YES];
        [pencilIconToolbarButton setEnabled:NO];
        [pencilIconToolbarButton addTarget:self action:@selector(setSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
        [annoTreeToolbar addSubview:pencilIconToolbarButton];
        [toolbarButtons addObject:pencilIconToolbarButton];
        
        /* Text Icon for toolbar */
        UIButton *textIconToolbarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [textIconToolbarButton setFrame:CGRectMake(0,space*2, sizeIcon, sizeIcon)];
        textIconToolbarButton.userInteractionEnabled = YES;
        UIImage *textIconImage = [UIImage imageNamed:@"TextIconToolbar.png"];
        UIImage *textIconImageSelected = [UIImage imageNamed:@"TextIconToolbarSelected.png"];
        [textIconToolbarButton setBackgroundImage:textIconImage forState:UIControlStateNormal];
        [textIconToolbarButton setBackgroundImage:textIconImageSelected forState:UIControlStateHighlighted];
        [textIconToolbarButton setBackgroundImage:textIconImageSelected forState:(UIControlStateDisabled|UIControlStateSelected)];
        [textIconToolbarButton addTarget:self action:@selector(setSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
        [annoTreeToolbar addSubview:textIconToolbarButton];
        [toolbarButtons addObject:textIconToolbarButton];
        
        /* Select Icon for toolbar */
        UIButton *selectIconToolbarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectIconToolbarButton setFrame:CGRectMake(0,space*3, sizeIcon, sizeIcon)];
        selectIconToolbarButton.userInteractionEnabled = YES;
        UIImage *selectIconImage = [UIImage imageNamed:@"SelectIconToolbar.png"];
        UIImage *selectIconImageSelected = [UIImage imageNamed:@"SelectIconToolbarSelected.png"];
        [selectIconToolbarButton setBackgroundImage:selectIconImage forState:UIControlStateNormal];
        [selectIconToolbarButton setBackgroundImage:selectIconImageSelected forState:UIControlStateHighlighted];
        [selectIconToolbarButton setBackgroundImage:selectIconImageSelected forState:(UIControlStateDisabled|UIControlStateSelected)];
        [selectIconToolbarButton addTarget:self action:@selector(setSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
        [annoTreeToolbar addSubview:selectIconToolbarButton];
        [toolbarButtons addObject:selectIconToolbarButton];
        
        /* Share Icon for toolbar */
        UIButton *shareIconToolbarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareIconToolbarButton setFrame:CGRectMake(0,space*4, sizeIcon, sizeIcon)];
        shareIconToolbarButton.userInteractionEnabled = YES;
        UIImage *shareIconImage = [UIImage imageNamed:@"ShareIconToolbar.png"];
        UIImage *shareIconImageSelected = [UIImage imageNamed:@"ShareIconToolbarSelected.png"];
        [shareIconToolbarButton setBackgroundImage:shareIconImage forState:UIControlStateNormal];
        [shareIconToolbarButton setBackgroundImage:shareIconImageSelected forState:UIControlStateHighlighted];
        [shareIconToolbarButton addTarget:self action:@selector(openShare:) forControlEvents:UIControlEventTouchUpInside];
        [annoTreeToolbar addSubview:shareIconToolbarButton];
        [toolbarButtons addObject:shareIconToolbarButton];
        
        /* Anno Tree Logo for toolbar*/
        UIButton *annoTreeImageOpenView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, sizeIcon, sizeIcon)];
        annoTreeImageOpenView.userInteractionEnabled = YES;
        [annoTreeImageOpenView setBackgroundImage:annoTreeImage forState:UIControlStateNormal];
        [annoTreeImageOpenView addGestureRecognizer:logoCloseGesture];
        [annoTreeImageOpenView addTarget:self action:@selector(toolbarWasDragged:withEvent:)
                        forControlEvents:UIControlEventTouchDragInside];
        [annoTreeToolbar addSubview:annoTreeImageOpenView];
        
        /* Cancel button for toolbar */
        UIImage *cancelImg = [UIImage imageNamed:@"CloseIconToolbar.png"];
        UIButton *closeAnnoTreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeAnnoTreeButton.userInteractionEnabled = YES;
        [closeAnnoTreeButton setFrame:CGRectMake(0,space*5, sizeIcon, sizeIcon)];
        [closeAnnoTreeButton setBackgroundImage:cancelImg forState:UIControlStateNormal];
        [closeAnnoTreeButton addGestureRecognizer:closeGesture];
        [annoTreeToolbar addSubview:closeAnnoTreeButton];
        
        /* Add toolbar to window */
        [self.view addSubview:annoTreeToolbar];
        
        shareView = [[ShareViewController alloc] init];
        shareView.view.center = CGPointMake(shareView.view.frame.size.width/2, -shareView.view.frame.size.height*2);
        [self.view addSubview:shareView.view];
    }
    return self;
}

-(IBAction)openShare:(UIButton*)button {
    [UIView animateWithDuration:0.25 animations:^{
        shareView.view.center = CGPointMake(shareView.view.frame.size.width/2, shareView.view.frame.size.height/2);
    }];
}

-(IBAction)setSelectedButton:(UIButton*)button {
    //loop all buttons and unselect/enable
    for (UIButton* toolbarButton in toolbarButtons) {
        toolbarButton.selected = NO;
        toolbarButton.enabled = YES;
    }
    
    //Select clicked button and disable it
    button.selected = YES;
    button.highlighted = NO;
    button.enabled = NO;
}

-(UIView*)getAnnoTreeLauncher:(UIInterfaceOrientation)orientation
{
    return openAnnoTreeView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

/* Function to show AnnoTree window and place toolbar at correct location */
#define CGRectSetPos( r, x, y ) CGRectMake( x, y, r.size.width, r.size.height )
- (void) openTree:(UIGestureRecognizer*)gr
{
    AnnoTreeWindow.hidden = NO;
    [openAnnoTreeButton setHidden:YES];
    annoTreeToolbar.frame = CGRectSetPos (annoTreeToolbar.frame, openAnnoTreeButton.frame.origin.x, openAnnoTreeButton.frame.origin.y);
    [self loadFingerDrawing];
}

/* Function to close the anno tree */
-(void)closeTree:(UIGestureRecognizer*)gr
{
    for (UIView *drawings in annotations) {
        [drawings removeFromSuperview];
    }
    [annotations removeAllObjects];
    AnnoTreeWindow.hidden = YES;
    [openAnnoTreeButton setHidden:NO];
}

/* Function for dragging the toolbar */
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

/* Function for dragging the AnnoTree Launch Logo */
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

/* Temp Function to load drawing with finger */
- (void) loadFingerDrawing
{
    int max = [[UIScreen mainScreen] bounds].size.height;
    MyLineDrawingView *drawScreen=[[MyLineDrawingView alloc]initWithFrame:CGRectMake(0, 0, max, max)];
    [annotations addObject:drawScreen];
    [self.view insertSubview:drawScreen belowSubview:annoTreeToolbar];
}

/* Temp Function to drop text on screen */
- (void) addText:(UITapGestureRecognizer*)gr
{
    /*if (gr.state == UIGestureRecognizerStateBegan) {
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
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
