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
#import "AnnotationViewController.h"
#import "UIScrollViewPageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


@interface AnnoTree ()

@end

@implementation AnnoTree

@synthesize annoTreeWindow;
@synthesize keyWindow;
@synthesize openAnnoTreeButton;
@synthesize annoTreeToolbar;
@synthesize annotations;
@synthesize toolbarButtons;
@synthesize toolbarObjects;
@synthesize shareView;
@synthesize drawScreen;
@synthesize annoTreeImageOpenView;
@synthesize activeTree;
@synthesize helpView;
//@synthesize supportedOrientation;
@synthesize enabled;
@synthesize drawEnabled;
@synthesize textEnabled;
@synthesize selectEnabled;
@synthesize textViewHeightHold;
@synthesize keyboardHeight;
@synthesize colorRenderbuffer;
@synthesize leafUploading;

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
        enabled = NO;
        drawEnabled = YES;
        textViewHeightHold = 0;
        keyboardHeight = 0;
        activeTree = @"-";
        
        /* Initiate the annotation window */
        annoTreeWindow = [[UIWindowAnnoTree alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        annoTreeWindow.windowLevel = UIWindowLevelStatusBar;
        annoTreeWindow.rootViewController = self;
        annoTreeWindow.hidden = NO;
        annoTreeWindow.backgroundColor = [UIColor clearColor];
        
        //supportedOrientation = UIInterfaceOrientationMaskAll;
        
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
        startStopAnnotationGesture.numberOfTapsRequired = 1;
        
        /* Temp gesture to add text */
        addTextGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addText:)];
        addTextGesture.minimumPressDuration = 1;
        [annoTreeWindow addGestureRecognizer:addTextGesture];
        
        /* create the toolbar to be loaded */
        annoTreeToolbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, sizeIcon, space*5+sizeIcon)];
        annoTreeToolbar.userInteractionEnabled = YES;
        
        /* rectangle background for toolbar */
        ToolbarBg *toolbarBg = [[ToolbarBg alloc] initWithFrame:CGRectMake(0,sizeIcon/2, sizeIcon, space*4)];
        toolbarBg.hidden = YES;
        toolbarBg.backgroundColor = [UIColor clearColor];
        [annoTreeToolbar addSubview:toolbarBg];
        [toolbarObjects addObject:toolbarBg];
        
        /* Pencil Icon for toolbar */
        UIButton *pencilIconToolbarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [pencilIconToolbarButton setFrame:CGRectMake(0,space, sizeIcon, sizeIcon)];
        pencilIconToolbarButton.userInteractionEnabled = YES;
        UIImage *pencilIconImage = [UIImage imageNamed:@"AnnoTree.bundle/PencilIconToolbar.png"];
        UIImage *pencilIconImageSelected = [UIImage imageNamed:@"AnnoTree.bundle/PencilIconToolbarSelected.png"];
        [pencilIconToolbarButton setBackgroundImage:pencilIconImage forState:UIControlStateNormal];
        [pencilIconToolbarButton setBackgroundImage:pencilIconImageSelected forState:UIControlStateHighlighted];
        [pencilIconToolbarButton setBackgroundImage:pencilIconImageSelected forState:(UIControlStateDisabled|UIControlStateSelected)];
        [pencilIconToolbarButton setSelected:YES];
        [pencilIconToolbarButton setEnabled:NO];
        [pencilIconToolbarButton addTarget:self action:@selector(setSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
        [pencilIconToolbarButton addTarget:self action:@selector(enableDisableDrawing:) forControlEvents:UIControlEventTouchUpInside];
        pencilIconToolbarButton.hidden = YES;
        [annoTreeToolbar addSubview:pencilIconToolbarButton];
        [toolbarButtons addObject:pencilIconToolbarButton];
        
        /* Text Icon for toolbar */
        UIButton *textIconToolbarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [textIconToolbarButton setFrame:CGRectMake(0,space*2, sizeIcon, sizeIcon)];
        textIconToolbarButton.userInteractionEnabled = YES;
        UIImage *textIconImage = [UIImage imageNamed:@"AnnoTree.bundle/TextIconToolbar.png"];
        UIImage *textIconImageSelected = [UIImage imageNamed:@"AnnoTree.bundle/TextIconToolbarSelected.png"];
        [textIconToolbarButton setBackgroundImage:textIconImage forState:UIControlStateNormal];
        [textIconToolbarButton setBackgroundImage:textIconImageSelected forState:UIControlStateHighlighted];
        [textIconToolbarButton setBackgroundImage:textIconImageSelected forState:(UIControlStateDisabled|UIControlStateSelected)];
        [textIconToolbarButton addTarget:self action:@selector(setSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
        [textIconToolbarButton addTarget:self action:@selector(enableDisableText:) forControlEvents:UIControlEventTouchUpInside];
        textIconToolbarButton.hidden = YES;
        [annoTreeToolbar addSubview:textIconToolbarButton];
        [toolbarButtons addObject:textIconToolbarButton];
        
        /* Select Icon for toolbar */
        /*UIButton *selectIconToolbarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectIconToolbarButton setFrame:CGRectMake(0,space*3, sizeIcon, sizeIcon)];
        selectIconToolbarButton.userInteractionEnabled = YES;
        UIImage *selectIconImage = [UIImage imageNamed:@"SelectIconToolbar.png"];
        UIImage *selectIconImageSelected = [UIImage imageNamed:@"SelectIconToolbarSelected.png"];
        [selectIconToolbarButton setBackgroundImage:selectIconImage forState:UIControlStateNormal];
        [selectIconToolbarButton setBackgroundImage:selectIconImageSelected forState:UIControlStateHighlighted];
        [selectIconToolbarButton setBackgroundImage:selectIconImageSelected forState:(UIControlStateDisabled|UIControlStateSelected)];
        [selectIconToolbarButton addTarget:self action:@selector(setSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
        [selectIconToolbarButton addTarget:self action:@selector(enableDisableSelect:) forControlEvents:UIControlEventTouchUpInside];
        selectIconToolbarButton.hidden = YES;
        [annoTreeToolbar addSubview:selectIconToolbarButton];
        [toolbarButtons addObject:selectIconToolbarButton];*/
        
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
        
        drawScreen = [[AnnotationViewController alloc] init];
        //[annotations addObject:drawScreen.view];
        drawEnabled = YES;
        [drawScreen setDrawingEnabled:drawEnabled];
        [self.view insertSubview:drawScreen.view belowSubview:annoTreeToolbar];
        //[self addChildViewController:drawScreen];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        
        leafUploading = [[UIAlertView alloc] initWithTitle:@"Uploading"
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle: nil //NSLocalizedString(@"Cancel",nil)
                                                      otherButtonTitles: nil
                                      ];
        
        NSLog(@"Initialized AnnoTree");
        
        /* Stuff for AnnoTree Browser */
        BOOL help = YES;
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
    //NSLog(@"editing %f %f", [self.view bounds].size.height, rect.origin.y);
    //NSLog(@"keyboard height %i", keyboardHeight);
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
    //NSLog(@"%i",buttonIndex);
    if(buttonIndex == 1) {
        UITextField *leafName = [alertView textFieldAtIndex:0];
        //NSLog(@"%@", leafName.text);
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
    if(buttonIndex == 1) {
        UITextField *leafName = [alertView textFieldAtIndex:0];
        //NSLog(@"%@", leafName.text);
        NSString *leafNameTrimmed = [leafName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([leafNameTrimmed length] >= 1) {
            [self sendLeaf:leafNameTrimmed];
            [leafUploading show];
        } else {
            return;
        }
    }
}

-(void)sendLeaf:(NSString*)leafName {
    /*[UIView animateWithDuration:0.25 animations:^{
        shareView.view.center = CGPointMake(shareView.view.frame.size.width/2, shareView.view.frame.size.height/2);
    }];*/
    
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    
    // set Content-Type in HTTP header
    NSString* boundary = @"-";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    //for (NSString *param in _params) {
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"token"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", activeTree] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"leafName"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", leafName] dataUsingEncoding:NSUTF8StringEncoding]];
    //}
    
    // add image data
    
    [self.view endEditing:YES];
    [shareView.view endEditing:YES];
    //NSLog(@"PreScreenshot");
    UIImage *image = [self screenshot];
    
    //NSLog(@"PostScreenshot");
    UIImage *finalImage;
    UIImage *rotateImage;
    UIInterfaceOrientation curOrient = shareView.interfaceOrientation;
    if(curOrient == UIInterfaceOrientationLandscapeLeft) {
        finalImage = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationRight];
        //finalImage = [self rotate:image orientation:UIImageOrientationRight];
    } else if(curOrient == UIInterfaceOrientationLandscapeRight) {
        finalImage = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationLeft];
        //finalImage = [self rotate:image orientation:UIImageOrientationLeft];
    } else if(curOrient == UIInterfaceOrientationPortraitUpsideDown) {
        finalImage = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationDown];
        //finalImage = [self rotate:image orientation:UIImageOrientationDown];
    } else {
        finalImage = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationUp];
        //finalImage = [self rotate:image orientation:UIImageOrientationUp];
    }
    UIGraphicsEndImageContext();
    rotateImage = [self scaleAndRotateImage:finalImage];
    UIGraphicsEndImageContext();
        
    //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

    
    //NSLog(@"ImageData");
    NSData * imageData = UIImagePNGRepresentation(rotateImage);
    //[data writeToFile:@"foo.png" atomically:YES];
    
    NSString* FileParamConstant = @"annotation";
    //NSData *imageData = UIImageJPEGRepresentation(imageToPost, 1.0);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"screenshot.png\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    NSURL *requestURL = [NSURL URLWithString:@"https://ccp.annotree.com/services/ios/leaf"];
    [request setURL:requestURL];
    
    //NSLog(@"Connection");
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if( connection )
    {
        int i = 0;
        i++;
        //mutableData = [[NSMutableData alloc] init];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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


//this code is copy and pasted from
//http://blog.logichigh.com/2008/06/05/uiimage-fix/
//Creator states public domain in comments

- (UIImage*)scaleAndRotateImage:(UIImage *)image
{
	int kMaxResolution = 3000; // Or whatever
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
            break;
    }
             
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
    else
        UIGraphicsBeginImageContext(bounds.size);
     
     CGContextRef context = UIGraphicsGetCurrentContext();
     
     if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
         CGContextScaleCTM(context, -scaleRatio, scaleRatio);
         CGContextTranslateCTM(context, -height, 0);
     }
     else {
         CGContextScaleCTM(context, scaleRatio, -scaleRatio);
         CGContextTranslateCTM(context, 0, -height);
     }
     
     CGContextConcatCTM(context, transform);
     
     CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
     return UIGraphicsGetImageFromCurrentImageContext();
     
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Fail..
    //NSLog(@"error");
    [leafUploading dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *leafNameError = [[UIAlertView alloc] initWithTitle:@"Leaf Failed To Upload"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Ok",nil)
                                                  otherButtonTitles: nil
                                  ];
    
        
    [leafNameError show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Request performed.
    //NSLog(@"success");
    [leafUploading dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *leafNameSuccess = [[UIAlertView alloc] initWithTitle:@"Leaf Uploaded"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Ok",nil)
                                                  otherButtonTitles: nil
                                  ];
    
    
    [leafNameSuccess show];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Request performed.
    //NSLog(@"response");
    //NSLog([response textEncodingName]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Request performed.
    //NSLog(@"data recieved");
    //NSLog(data);
    //NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(responseBody);
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

-(IBAction)enableDisableDrawing:(UIButton*) button {
    drawEnabled = YES;
    textEnabled = NO;
    selectEnabled = NO;
    [drawScreen setDrawingEnabled:drawEnabled];
    [drawScreen setTextEnabled:textEnabled];
    //NSLog(@"Drawing enable disable");
}

-(IBAction)enableDisableText:(UIButton*) button {
    drawEnabled = NO;
    textEnabled = YES;
    selectEnabled = NO;
    [drawScreen setDrawingEnabled:drawEnabled];
    [drawScreen setTextEnabled:textEnabled];
    
    //NSLog(@"Text enable disable");
}

-(IBAction)enableDisableSelect:(UIButton*) button {
    drawEnabled = NO;
    textEnabled = NO;
    selectEnabled = YES;
    [drawScreen setDrawingEnabled:drawEnabled];
    [drawScreen setTextEnabled:textEnabled];
    
    //NSLog(@"Select enable disable");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.drawScreen.view setAutoresizesSubviews:YES];
    [self.drawScreen.view setAutoresizingMask:
     UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleHeight];
    
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
    
    NSLog(@"Loaded AnnoTree with key %@", tree);
}

/* Function to show AnnoTree window and place toolbar at correct location */
#define CGRectSetPos( r, x, y ) CGRectMake( x, y, r.size.width, r.size.height )
- (void) openCloseAnnoTree:(UIGestureRecognizer*)gr
{
    if(enabled) {
        [drawScreen clearAll];
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

- (UIImage*)screenshot
{
    annoTreeToolbar.hidden = YES;
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //CGContextRotateCTM (context, radians(-90));
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        /*if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {*/
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            //CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            //CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            /*CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            */
            // Render the layer hierarchy to the current context
            /*for (EAGLView *glview in window)
            {
                CAEAGLLayer *eaglLayer = (CAEAGLLayer *) window.layer;
                if(eaglLayer resp.drawableProperties) {
                    eaglLayer.drawableProperties = @{
                                                 kEAGLDrawablePropertyRetainedBacking: [NSNumber numberWithBool:YES],
                                                 kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
                                                 };
                }
             }*/
            for (UIView *subview in window.subviews)
            {
                CAEAGLLayer *eaglLayer = (CAEAGLLayer *) subview.layer;
                if([eaglLayer respondsToSelector:@selector(drawableProperties)]) {
                    //NSLog(@"responds");
                    /*eaglLayer.drawableProperties = @{
                                                     kEAGLDrawablePropertyRetainedBacking: [NSNumber numberWithBool:YES],
                                                     kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
                                                     };*/
                    /*UIImageView *glImageView = [[UIImageView alloc] initWithImage:[self snapshotx:subview]];
                    glImageView.transform = CGAffineTransformMakeScale(1, -1);
                    [glImageView.layer renderInContext:context];*/
                    
                    //CGImageRef iref = [self snapshot:subview withContext:context];
                    //CGContextDrawImage(context, CGRectMake(0.0, 0.0, 640, 960), iref);

                }
            }
        
        [[window layer] renderInContext:context];
        
        // Restore the context
        CGContextRestoreGState(context);
        //}
    }
    
    // Retrieve the screenshot image
    //UIImage *GLimage = [self glToUIImage];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    annoTreeToolbar.hidden = NO;
    return image;
}

- (CGImageRef)snapshot:(UIView*)eaglview withContext:(CGContextRef)cgcontext
{
    GLint backingWidth, backingHeight;
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];

    
    // Bind the color renderbuffer used to render the OpenGL ES view
    // If your application only creates a single color renderbuffer which is already bound at this point,
    // this call is redundant, but it is needed if you're dealing with multiple renderbuffers.
    // Note, replace "_colorRenderbuffer" with the actual name of the renderbuffer object defined in your class.
    //glBindRenderbufferOES(GL_RENDERBUFFER_OES, _colorRenderbuffer);
    //glGenRenderbuffersOES(1, &viewRenderbuffer);
    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)eaglview.layer];
    
    // Get the size of the backing CAEAGLLayer
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    //NSLog(@"%i %i", backingWidth, backingHeight);
    
    NSInteger x = 0, y = 0, width = backingWidth, height = backingHeight;
    NSInteger dataLength = width * height * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    // Read pixel data from the framebuffer
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    // Create a CGImage with the pixel data
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    // otherwise, use kCGImageAlphaPremultipliedLast
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
    return iref;
    /*
    // OpenGL ES measures data in PIXELS
    // Create a graphics context with the target size measured in POINTS
    NSInteger widthInPoints, heightInPoints;
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        CGFloat scale = eaglview.contentScaleFactor;
        widthInPoints = width / scale;
        heightInPoints = height / scale;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
    }
    else {
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        widthInPoints = width;
        heightInPoints = height;
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
    }
    
    //CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    // Flip the CGImage by rendering it to the flipped bitmap context
    // The size of the destination area is measured in POINTS
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
    // Retrieve the UIImage from the current context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // Clean up
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    
    return image;*/
}

- (UIImage*)snapshotx:(UIView*)eaglview
{
	GLint backingWidth, backingHeight;

    //glBindRenderbufferOES(GL_RENDERBUFFER_OES, _colorRenderbuffer);
    //don't know how to access the renderbuffer if i can't directly access the below code
    
	// Get the size of the backing CAEAGLLayer
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
	NSInteger x = 0, y = 0, width = backingWidth, height = backingHeight;
	NSInteger dataLength = width * height * 4;
	GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
	// Read pixel data from the framebuffer
	glPixelStorei(GL_PACK_ALIGNMENT, 4);
	glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
	// Create a CGImage with the pixel data
	// If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
	// otherwise, use kCGImageAlphaPremultipliedLast
	CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGImageRef iref = CGImageCreate (
                                     width,
                                     height,
                                     8,
                                     32,
                                     width * 4,
                                     colorspace,
                                     // Fix from Apple implementation
                                     // (was: kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast).
                                     kCGBitmapByteOrderDefault,
                                     ref,
                                     NULL,
                                     true,
                                     kCGRenderingIntentDefault
                                     );
    
	// OpenGL ES measures data in PIXELS
	// Create a graphics context with the target size measured in POINTS
	NSInteger widthInPoints, heightInPoints;
	if (NULL != UIGraphicsBeginImageContextWithOptions)
	{
		// On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
		// Set the scale parameter to your OpenGL ES view's contentScaleFactor
		// so that you get a high-resolution snapshot when its value is greater than 1.0
		CGFloat scale = eaglview.contentScaleFactor;
		widthInPoints = width / scale;
		heightInPoints = height / scale;
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
	}
	else {
		// On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
		widthInPoints = width;
		heightInPoints = height;
		UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
	}
    
	CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
	// UIKit coordinate system is upside down to GL/Quartz coordinate system
	// Flip the CGImage by rendering it to the flipped bitmap context
	// The size of the destination area is measured in POINTS
	CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
	CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
	// Retrieve the UIImage from the current context
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    
	// Clean up
	free(data);
	CFRelease(ref);
	CFRelease(colorspace);
	CGImageRelease(iref);
    
	return image;
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
    //NSLog(@"rotated");
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
