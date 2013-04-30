//
//  AnnoTree.m
//  AnnoTree Viewer
//
//  Created by Brian Clark on 3/25/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "AnnoTree.h"
#import "MyLineDrawingView.h"
#import "ToolbarBg.h"
#import "ShareViewController.h"
#import "AnnoTreeUserLaunchViewController.h"


@interface AnnoTree ()

@end

@implementation AnnoTree

@synthesize annoTreeWindow;
@synthesize openAnnoTreeButton;
@synthesize annoTreeToolbar;
@synthesize annotations;
@synthesize toolbarButtons;
@synthesize toolbarObjects;
@synthesize shareView;
@synthesize enabled;

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
        NSLog(@"Initilaized AnnoTree");
        enabled = NO;
        
        /* Initiate the annotation window */
        int max = [[UIScreen mainScreen] bounds].size.height;
        annoTreeWindow = [[UIWindowAnnoTree alloc] initWithFrame:CGRectMake(0, 0, max, max)];
        annoTreeWindow.windowLevel = UIWindowLevelStatusBar;
        annoTreeWindow.rootViewController = self;
        annoTreeWindow.hidden = NO;
        annoTreeWindow.backgroundColor = [UIColor clearColor];
        
        /* Space between icons on toolbar */
        int space = 35.0;
        /* Size of toolbar icons */
        int sizeIcon = 30;
        
        
        
        /* initiate array to hold the annotations - drawings and text */
        annotations = [[NSMutableArray alloc] init];
        toolbarButtons = [[NSMutableArray alloc] init];
        toolbarObjects = [[NSMutableArray alloc] init];
        
        /* Gestures for anno tree */
        /* Gesture to open and close anno tree toolbar from logo */
        UITapGestureRecognizer *startStopAnnotationGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openCloseAnnoTree:)];
        startStopAnnotationGesture.numberOfTapsRequired = 2;
        
        /* Temp gesture to add text */
        addTextGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addText:)];
        addTextGesture.minimumPressDuration = 1;
        [annoTreeWindow addGestureRecognizer:addTextGesture];
        
        /* create the toolbar to be loaded */
        annoTreeToolbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, sizeIcon, space*5+sizeIcon)];
        annoTreeToolbar.userInteractionEnabled = YES;
        
        /* rectangle background for toolbar */
        ToolbarBg *toolbarBg = [[ToolbarBg alloc] initWithFrame:CGRectMake(0,sizeIcon/2, sizeIcon, space*5)];
        toolbarBg.hidden = YES;
        toolbarBg.backgroundColor = [UIColor clearColor];
        [annoTreeToolbar addSubview:toolbarBg];
        [toolbarObjects addObject:toolbarBg];
        
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
        pencilIconToolbarButton.hidden = YES;
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
        textIconToolbarButton.hidden = YES;
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
        selectIconToolbarButton.hidden = YES;
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
        shareIconToolbarButton.hidden = YES;
        [annoTreeToolbar addSubview:shareIconToolbarButton];
        [toolbarButtons addObject:shareIconToolbarButton];
        
        /* Anno Tree Logo with open close functionality for toolbar*/
        UIButton *annoTreeImageOpenView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, sizeIcon, sizeIcon)];
        annoTreeImageOpenView.userInteractionEnabled = YES;
        UIImage *annoTreeImage = [UIImage imageNamed:@"AnnoTreeLogo.png"];
        [annoTreeImageOpenView setBackgroundImage:annoTreeImage forState:UIControlStateNormal];
        [annoTreeImageOpenView addGestureRecognizer:startStopAnnotationGesture];
        [annoTreeImageOpenView addTarget:self action:@selector(toolbarWasDragged:withEvent:)
                        forControlEvents:UIControlEventTouchDragInside];
        [annoTreeToolbar addSubview:annoTreeImageOpenView];
        [annoTreeWindow setButton:annoTreeImageOpenView];
        
        /* Position toolbar and add to screen */
        annoTreeToolbar.center = CGPointMake(annoTreeToolbar.center.x + 20,
                                             annoTreeToolbar.center.y + 20);
        [self.view addSubview:annoTreeToolbar];
        [toolbarObjects addObjectsFromArray:toolbarButtons];
        
        /* Position share to CCP view and add to view */
        shareView = [[ShareViewController alloc] init];
        shareView.view.center = CGPointMake(shareView.view.frame.size.width/2, -shareView.view.frame.size.height*2);
        shareView.view.hidden = YES;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) loadTree:(UIInterfaceOrientationMask)orientation
{
    
}

/* Function to show AnnoTree window and place toolbar at correct location */
#define CGRectSetPos( r, x, y ) CGRectMake( x, y, r.size.width, r.size.height )
- (void) openCloseAnnoTree:(UIGestureRecognizer*)gr
{
    if(enabled) {
        enabled = NO;
        for( UIView* drawings in annotations) {
            [drawings removeFromSuperview];
        }
    } else {
        enabled = YES;
        [self loadFingerDrawing];
    }
    
    for(UIView* view in toolbarObjects) {
        view.hidden = !enabled;
    }
    [annoTreeWindow setEnabled:enabled];
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
}

/* Temp Function to load drawing with finger */
- (void) loadFingerDrawing
{
    if(enabled) {
        int max = [[UIScreen mainScreen] bounds].size.height;
        MyLineDrawingView *drawScreen=[[MyLineDrawingView alloc]initWithFrame:CGRectMake(0, 0, max, max)];
        [annotations addObject:drawScreen];
        [self.view insertSubview:drawScreen belowSubview:annoTreeToolbar];
    }
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
