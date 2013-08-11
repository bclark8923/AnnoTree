//
//  UIScrollViewPageViewController.h
//  AnnoTree Viewer
//
//  Created by Brian Clark on 8/11/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollViewPageViewController : UIViewController <UIScrollViewDelegate> {
	UIScrollView* scrollView;
	UIPageControl* pageControl;
	
	BOOL pageControlBeingUsed;
}

@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;

- (IBAction)changePage;
- (IBAction)buttonPressed:(id)sender;

@end