//
//  UIScrollViewPageViewController.h
//  AnnoTree Viewer
//
//  Created by Brian Clark on 8/11/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIWindowAnnoTree.h"

@interface UIScrollViewPageViewController : UIViewController <UIScrollViewDelegate> {
	BOOL pageControlBeingUsed;
}

@property (nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, retain) UIPageControl* pageControl;
@property (nonatomic, retain) UIWindowAnnoTree* controlWindow;

- (IBAction)changePage;
- (IBAction)buttonPressed:(id)sender;

@end