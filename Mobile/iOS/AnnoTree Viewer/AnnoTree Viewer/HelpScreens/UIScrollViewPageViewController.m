//
//  UIScrollViewPageViewController.m
//  AnnoTree Viewer
//
//  Created by Brian Clark on 8/11/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "UIScrollViewPageViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface UIScrollViewPageViewController ()

@end

@implementation UIScrollViewPageViewController

@synthesize scrollView;
@synthesize pageControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.scrollView.bounces = NO;
	
	pageControlBeingUsed = NO;
    
    NSArray *images = [NSArray arrayWithObjects:
                       [UIImage imageNamed:@"Screen1.png"],
                       [UIImage imageNamed:@"Screen2.png"],
                       [UIImage imageNamed:@"Screen3.png"],
                       [UIImage imageNamed:@"Screen4.png"],
                       [UIImage imageNamed:@"Screen5.png"],
                       nil];
	for (int i = 0; i < images.count; i++) {
		CGRect frame;
		frame.origin.x = self.scrollView.frame.size.width * i;
		frame.origin.y = 0;
		frame.size = self.scrollView.frame.size;
        
		UIView *subview = [[UIView alloc] initWithFrame:frame];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[images objectAtIndex:i]];
        imageView.frame = scrollView.frame;
        [subview addSubview:imageView];
		
        if(i == 4) {
            CGRect buttonFrame;
            UIColor *buttonColor = [UIColor colorWithRed:146.0/255.0 green:223.0/255.0 blue:116.0/255.0 alpha:1];
            
            buttonFrame.origin.x = (frame.size.width / 2) - 100;
            buttonFrame.origin.y = (frame.size.height / 2) - 25;
            buttonFrame.size.width = 200;
            buttonFrame.size.height = 50;
            
            UIButton *subviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
            subviewButton.frame = buttonFrame;
            subviewButton.layer.cornerRadius = 10; // this value vary as per your desire
            subviewButton.clipsToBounds = YES;
            [subviewButton setTitle:@"Start Drawing Now" forState:UIControlStateNormal];
            [subviewButton setTag:i+1];
            [subviewButton setBackgroundColor:buttonColor];
            [subviewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [subviewButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [subview addSubview:subviewButton];
        }
		
		[self.scrollView addSubview:subview];
	}
	
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * images.count, self.scrollView.frame.size.height);
	
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect framePageControl;
    framePageControl.size = self.pageControl.frame.size;
    framePageControl.origin = self.pageControl.frame.origin;
    framePageControl.origin.y = screenHeight - 70;
    
	self.pageControl.currentPage = 0;
	self.pageControl.numberOfPages = images.count;
    self.pageControl.frame = framePageControl;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if (!pageControlBeingUsed) {
		// Switch the indicator when more than 50% of the previous/next page is visible
		CGFloat pageWidth = self.scrollView.frame.size.width;
		int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
		self.pageControl.currentPage = page;
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}

- (IBAction)changePage {
	// Update the scroll view to the appropriate page
	CGRect frame;
	frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
	frame.origin.y = 0;
	frame.size = self.scrollView.frame.size;
	[self.scrollView scrollRectToVisible:frame animated:YES];
	
	// Keep track of when scrolls happen in response to the page control
	// value changing. If we don't do this, a noticeable "flashing" occurs
	// as the the scroll delegate will temporarily switch back the page
	// number.
	pageControlBeingUsed = YES;
}

- (IBAction)buttonPressed:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Button pressed"
													message:[NSString stringWithFormat:@"You pressed the button on page %d.", [sender tag]]
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.scrollView = nil;
	self.pageControl = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
