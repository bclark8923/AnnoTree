//
//  AnnoTree.m
//  AnnoTree Viewer
//
//  Created by Brian Clark on 3/25/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "AnnoTree.h"
#import "ToolbarBg.h"
#import "ShareViewController.h"
#import "DrawingViewController.h"
#import "UIScrollViewPageViewController.h"
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"


#import "PencilTool.h"
#import "TextTool.h"
#import "ScreenShotUtil.h"


@interface AnnoTree ()

@end

@implementation AnnoTree

static const int ddLogLevel = LOG_LEVEL_ERROR;

@synthesize annoTreeWindow;
@synthesize keyWindow;
@synthesize openAnnoTreeButton;
@synthesize annoTreeToolbar;
@synthesize annotations;
@synthesize toolbarButtons;
@synthesize toolbarObjects;
@synthesize shareView;
//@synthesize drawScreen;
@synthesize annoTreeImageOpenView;
@synthesize activeTree;
@synthesize helpView;
@synthesize enabled;
//@synthesize drawEnabled;
//@synthesize textEnabled;
//@synthesize selectEnabled;
@synthesize textViewHeightHold;
@synthesize keyboardHeight;
@synthesize space;
@synthesize sizeIcon;


@synthesize leaf;

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
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];


        enabled = NO;
        textViewHeightHold = 0;
        keyboardHeight = 0;
        activeTree = @"-";
        
        /* Initiate the annotation window */
        annoTreeWindow = [[UIWindowAnnoTree alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        annoTreeWindow.windowLevel = UIWindowLevelStatusBar;
        annoTreeWindow.rootViewController = self;
        annoTreeWindow.hidden = NO;
        annoTreeWindow.backgroundColor = [UIColor clearColor];
        
        /* Space between icons on toolbar */
        space = 45.0;
        /* Size of toolbar icons */
        sizeIcon = 40;
        
        
        
        /* initiate array to hold the annotations - drawings and text */
        annotations = [[NSMutableArray alloc] init];
        toolbarButtons = [[NSMutableArray alloc] init];
        toolbarObjects = [[NSMutableArray alloc] init];
        
        /* Gestures for anno tree */
        /* Gesture to open and close anno tree toolbar from logo */
        UITapGestureRecognizer *startStopAnnotationGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openCloseAnnoTree:)];
        startStopAnnotationGesture.numberOfTapsRequired = 1;
        
        /* Temp gesture to add text */
        addTextGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addText:)];
        addTextGesture.minimumPressDuration = 1;
        [annoTreeWindow addGestureRecognizer:addTextGesture];
        
        /* create the toolbar to be loaded */
        annoTreeToolbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, sizeIcon*3, space*3+sizeIcon)];
        annoTreeToolbar.userInteractionEnabled = YES;
        
        /* rectangle background for toolbar */
        ToolbarBg *toolbarBg = [[ToolbarBg alloc] initWithFrame:CGRectMake(0,sizeIcon/2, sizeIcon, space*4)];
        toolbarBg.hidden = YES;
        toolbarBg.backgroundColor = [UIColor clearColor];
        [annoTreeToolbar addSubview:toolbarBg];
        [toolbarObjects addObject:toolbarBg];
        
        /* Pencil Icon for toolbar */
        UIButton *pencilIconToolbarButton = [[PencilTool alloc] initWithFrame:CGRectMake(0,space*1, sizeIcon, sizeIcon) annotree:self];
        [annoTreeToolbar addSubview:pencilIconToolbarButton];
        [toolbarButtons addObject:pencilIconToolbarButton];
        
        /* Text Icon for toolbar */
        UIButton *textIconToolbarButton = [[TextTool alloc] initWithFrame:CGRectMake(0,space*2, sizeIcon, sizeIcon) annotree:self];
        [annoTreeToolbar addSubview:textIconToolbarButton];
        [toolbarButtons addObject:textIconToolbarButton];
        
        /* Share Icon for toolbar */
        UIButton *shareIconToolbarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareIconToolbarButton setFrame:CGRectMake(0,space*3, sizeIcon, sizeIcon)];
        shareIconToolbarButton.userInteractionEnabled = YES;
        UIImage *shareIconImage = [UIImage imageNamed:@"AnnoTree.bundle/ShareIconToolbar.png"];
        UIImage *shareIconImageSelected = [UIImage imageNamed:@"AnnoTree.bundle/ShareIconToolbarSelected.png"];
        [shareIconToolbarButton setBackgroundImage:shareIconImage forState:UIControlStateNormal];
        [shareIconToolbarButton setBackgroundImage:shareIconImageSelected forState:UIControlStateHighlighted];
        [shareIconToolbarButton addTarget:self action:@selector(openShare:) forControlEvents:UIControlEventTouchUpInside];
        shareIconToolbarButton.hidden = YES;
        [annoTreeToolbar addSubview:shareIconToolbarButton];
        [toolbarButtons addObject:shareIconToolbarButton];
        
        /* Anno Tree Logo with open close functionality for toolbar*/
        annoTreeImageOpenView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, sizeIcon, sizeIcon)];
        annoTreeImageOpenView.alpha = 0.7;
        annoTreeImageOpenView.userInteractionEnabled = YES;
        UIImage *annoTreeImage = [UIImage imageNamed:@"AnnoTree.bundle/AnnoTreeLogo.png"];
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];


        DDLogVerbose(@"Initialized AnnoTree");
        
        /* Stuff for AnnoTree Browser */
        BOOL help = NO;
        if(help) {
            helpView = [[UIScrollViewPageViewController alloc] init];
            helpView.controlWindow = annoTreeWindow;
            [self.view addSubview:helpView.view];
            [annoTreeWindow setEnabled:YES];
        }
    }
    return self;
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if (UIInterfaceOrientationIsLandscape([self interfaceOrientation])){
        keyboardHeight = kbSize.width;
    } else {
        keyboardHeight = kbSize.height;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    CGRect rect = textView.frame;
    DDLogVerbose(@"editing %f %f", [self.view bounds].size.height, rect.origin.y);
    DDLogVerbose(@"keyboard height %i", keyboardHeight);
    if(rect.origin.y > [self.view bounds].size.height - keyboardHeight - 30) {
        textViewHeightHold = rect.origin.y;
        rect.origin.y = [self.view bounds].size.height - keyboardHeight - 30;
        textView.frame = rect;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    CGRect rect = textView.frame;
    if(textViewHeightHold > 0) {
        rect.origin.y = textViewHeightHold;
        textView.frame = rect;
    }
    textViewHeightHold = 0;
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGRect frame = textView.frame;
    frame.size.height = textView.contentSize.height;
    textView.frame = frame;
}

-(IBAction)openShare:(UIButton*)button {
    DDLogVerbose(@"openShare");
    
    UIAlertView *leafNameAlert = [[UIAlertView alloc] initWithTitle:@"Leaf Name"
                                                        message:@""
                                                        delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                                        otherButtonTitles:NSLocalizedString(@"Send",nil), nil
                                  ];
    
    
    leafNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;

    [[leafNameAlert textFieldAtIndex:0] sendActionsForControlEvents:UIControlEventAllEvents];
    [leafNameAlert show];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if( alertView.alertViewStyle == UIAlertViewStylePlainTextInput) {
        NSString *inputText = [[alertView textFieldAtIndex:0] text];
        NSString *leafNameTrimmed = [inputText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if( [leafNameTrimmed length] >= 1 )
        {
            return YES;
        }
        else
        {
            return NO;
        }
    } else {
        return YES;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //if (buttonIndex != NULL)
    DDLogVerbose(@"%i",buttonIndex);
    if(buttonIndex == 1) {
        UITextField *leafName = [alertView textFieldAtIndex:0];
        DDLogVerbose(@"Annotree Viewer Leaf name:%@", leafName.text);
        NSString *leafNameTrimmed = [leafName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([leafNameTrimmed length] >= 1) {
            [self.view endEditing:YES];
        } else {
            UIAlertView *leafNameError = [[UIAlertView alloc] initWithTitle:@"Error: Please input a name"
                                                                    message:@""
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Ok",nil)
                                                          otherButtonTitles: nil
                                          ];
            
            
            [leafNameError show];
        }
    }
}

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    //TODO:this
    if(buttonIndex == 1) {
        UITextField *leafName = [alertView textFieldAtIndex:0];
        if([leafName.text length] >= 1) {
            DDLogVerbose(@"Attempting to send leaf named:%@", leafName.text);

            self.leaf = [[Leaf alloc] init:leafName.text annotree:self];
            DDLogVerbose(@"After leaf create %@", leaf);
            [self.shareView.view endEditing:YES];
            [self.view endEditing:YES];
            [self.leaf sendLeaf];
            //[leafUploading show];
        } else {
            //TODO:some sort of error
            return;
        }
    }
}


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
	{
		if ([challenge.protectionSpace.host isEqualToString:@"ccp.annotree.com"])
		{
			[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
		}
	}
    
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{

}




-(void)unselectAll{
    DDLogVerbose(@"Inside Annotree:unselectAll");
    for (UIButton* toolbarButton in toolbarButtons) {

        if([toolbarButton isKindOfClass:[ToolbarButton class]]){
            [(ToolbarButton*)toolbarButton setUnselected];
        }
        toolbarButton.selected = NO;
        toolbarButton.enabled = YES;
    }
}



-(IBAction)setSelectedButton:(UIButton*)button {
    //loop all buttons and unselect/enable
    DDLogVerbose(@"Inside Annotree:setSelectedButton");
    
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
    

     
    
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:
     UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleHeight];
    
    [self.view.superview setAutoresizesSubviews:YES];
    [self.view.superview setAutoresizingMask:
     UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleHeight];
}

- (void) loadAnnoTree:(NSString*)tree
{
    //supportedOrientation = orientation;
    
    activeTree = tree;

    DDLogVerbose(@"Loaded AnnoTree with key %@", tree);
}

-(void) clearAll{
    for(UIButton* toolbarItem in toolbarButtons){
        if([toolbarItem isKindOfClass:[ToolbarButton class]]){
            ToolbarButton* toolBarButton = (ToolbarButton*)toolbarItem;
            [toolBarButton clearAll];
        }
    }
}

/* Function to show AnnoTree window and place toolbar at correct location */
#define CGRectSetPos( r, x, y ) CGRectMake( x, y, r.size.width, r.size.height )
- (void) openCloseAnnoTree:(UIGestureRecognizer*)gr
{
    if(enabled) {
        //TODO:this
        //[drawScreen clearAll];
        [self clearAll];
        [annoTreeWindow resignKeyWindow];
        [keyWindow makeKeyAndVisible];
        annoTreeImageOpenView.alpha = 0.7;
    } else {
        keyWindow = [[UIApplication sharedApplication] keyWindow];
        [annoTreeWindow makeKeyAndVisible];
        annoTreeImageOpenView.alpha = 1.0;
    }
    enabled = !enabled;
    
    for(UIView* view in toolbarObjects) {
        view.hidden = !enabled;
    }
    [annoTreeWindow setEnabled:enabled];
}

-(BOOL)textView:(UITextView *)_textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self adjustFrames:_textView];
    return YES;
}

-(void) adjustFrames:(UITextView*)textView
{
    CGRect textFrame = textView.frame;
    textFrame.size.width = textView.contentSize.width;
    textView.frame = textFrame;
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



/*
- (NSUInteger)supportedInterfaceOrientations
{
    return supportedOrientation;
}*/

- (BOOL)shouldAutorotate
{
    return !enabled;
}

-(void)didRotateInterfaceOrientation
{
    DDLogVerbose(@"rotated");
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    /*for (UIButton *toolbarButton in toolbarButtons) {
        if([toolbarButton pointInside:[self convertPoint:point toView:toolbarButton] withEvent:event] ) {
            return YES;
        }
    }*/
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
