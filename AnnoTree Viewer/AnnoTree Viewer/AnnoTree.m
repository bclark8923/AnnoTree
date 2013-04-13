//
//  AnnoTree.m
//  AnnoTree Viewer
//
//  Created by Brian Clark on 3/25/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "AnnoTree.h"
#import "MyLineDrawingView.h"
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
        //currentAppView = nil;
        //MainWindow = [[UIApplication sharedApplication] keyWindow];
        
        //[[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
        annoTreeView = [[AnnoTreeUserLaunchViewController alloc] init];
        
        AnnoTreeWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        AnnoTreeWindow.windowLevel = UIWindowLevelStatusBar;
        AnnoTreeWindow.rootViewController = self;
        AnnoTreeWindow.hidden = YES;
        AnnoTreeWindow.backgroundColor = [UIColor clearColor];
        
        closeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTree:)];
        closeGesture.numberOfTapsRequired = 2;
        [closeAnnoTree addGestureRecognizer:closeGesture];
        closeAnnoTree.userInteractionEnabled = YES;
        
        UIImage *cancelImg = [UIImage imageNamed:@"CloseIconToolbar.png"];
        UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCancel.userInteractionEnabled = YES;
        [btnCancel setFrame:CGRectMake(100.0,0.0, 35.0, 35.0)];
        [btnCancel setBackgroundImage:cancelImg forState:UIControlStateNormal];
        [btnCancel addGestureRecognizer:closeGesture];
        [self.view addSubview:btnCancel];
        
        //openGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openTree:)];
        //openGesture.numberOfTapsRequired = 2;
        //openGesture.numberOfTouchesRequired = 1;
        
        addTextGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addText:)];
        addTextGesture.minimumPressDuration = 1;
        [AnnoTreeWindow addGestureRecognizer:addTextGesture];
    }
    return self;
}

-(UIView*)getAnnoTree
{
    return annoTreeView.view;
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
    //load view with button for firing up annotations
    //[self loadFingerDrawing];
    /*if(currentAppView) {
        [appView.view addSubview:[[AnnoTreeUserLaunchViewController alloc] init].view];
        currentAppView = appView;
    }*/
}

- (void) openTree:(UIGestureRecognizer*)gr
{
    AnnoTreeWindow.hidden = NO;
    [AnnoTreeWindow makeKeyAndVisible];
    
    //UIView *screenBlock = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //[AnnoTreeWindow addSubview:screenBlock];
    [self loadFingerDrawing];
}

-(void)closeTree:(UIGestureRecognizer*)gr
{
    [self removeTree];
}

-(void) removeTree
{
    AnnoTreeWindow.hidden = YES;
    [MainWindow makeKeyAndVisible];
}

- (void) loadFingerDrawing
{
    MyLineDrawingView *drawScreen=[[MyLineDrawingView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
     [self.view addSubview:drawScreen];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
