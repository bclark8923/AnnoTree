//
//  ViewController.m
//  AnnoTree
//
//  Created by Brian Clark on 6/14/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
    
@synthesize viewWeb;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    self.view.backgroundColor = [UIColor blackColor];

    
    self.viewWeb.delegate = self;
    self.viewWeb.scalesPageToFit = YES;
    self.viewWeb.contentMode = UIViewContentModeRedraw;

    [[self.viewWeb scrollView] setBounces: NO];
    
    NSURL* url = [NSURL URLWithString:@"https://ccp.annotree.com"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if( connection )
    {
        int i = 0;
        i++;
        //mutableData = [[NSMutableData alloc] init];
    }
    
    [self.viewWeb loadRequest:request];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
	{
		if ([challenge.protectionSpace.host isEqualToString:@"dev.annotree.com"])
		{
			[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
		}
	}
    
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
/*
- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration: (NSTimeInterval)duration {
    
    CGRect webViewFrame = self.viewWeb.frame;
    int width = webViewFrame.size.width;
    webViewFrame.size.width = webViewFrame.size.height;
    webViewFrame.size.height = width;
    self.viewWeb.frame = webViewFrame;
}
*/
- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
