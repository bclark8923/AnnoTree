//
//  ViewController.h
//  AnnoTree Viewer
//
//  Created by Brian Clark on 3/25/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate> {
    UIWebView *viewWeb;
    UIToolbar* toolbar;
    UIBarButtonItem* back;
    UIBarButtonItem* forward;
    UIBarButtonItem* refresh;
    UIBarButtonItem* stop;
    
    UILabel* pageTitle;
    UITextField* addressField;
}

@property (nonatomic, retain) IBOutlet UIWebView* viewWeb;
@property (nonatomic, retain) IBOutlet UIToolbar* toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* back;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* forward;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* refresh;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* stop;

@property (nonatomic, retain) IBOutlet UILabel* pageTitle;
@property (nonatomic, retain) IBOutlet UITextField* addressField;

- (void)updateButtons;

- (void)updateTitle:(UIWebView*)aWebView;

- (void)loadAddress:(id)sender event:(UIEvent*)event;

- (void)updateAddress:(NSURLRequest*)request;

- (void)informError:(NSError*)error;

@end
