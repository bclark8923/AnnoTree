//
//  AnnoTree.m
//  AnnoTree Viewer
//
//  Created by Brian Clark on 3/25/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "AnnoTree.h"
#import "MyLineDrawingView.h"

@interface AnnoTree ()

@end

@implementation AnnoTree

@synthesize AnnoTreeWindow;
@synthesize MainWindow;
@synthesize closeGesture;
@synthesize openGesture;
@synthesize addTextGesture;

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
        //MainWindow = [[UIApplication sharedApplication] keyWindow];
        
        //[[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
        
        AnnoTreeWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        AnnoTreeWindow.windowLevel = UIWindowLevelStatusBar;
        AnnoTreeWindow.rootViewController = self;
        AnnoTreeWindow.hidden = YES;
        AnnoTreeWindow.backgroundColor = [UIColor clearColor];
        
        closeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTree:)];
        closeGesture.numberOfTapsRequired = 3;
        [AnnoTreeWindow addGestureRecognizer:closeGesture];
        
        openGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openTree:)];
        openGesture.numberOfTapsRequired = 3;
        //openGesture.numberOfTouchesRequired = 1;
        
        addTextGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addText:)];
        addTextGesture.minimumPressDuration = 1;
        [AnnoTreeWindow addGestureRecognizer:addTextGesture];
    }
    return self;
}

-(UITapGestureRecognizer*)getOpen
{
    return openGesture;
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

- (void) loadTree
{
    //load view with button for firing up annotations
    //[self loadFingerDrawing];
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
