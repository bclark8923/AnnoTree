//
//  ViewController.h
//  AnnoTree
//
//  Created by Brian Clark on 6/14/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIWebViewDelegate> {
    UIWebView *viewWeb;

}
    
@property (nonatomic, retain) IBOutlet UIWebView* viewWeb;


@end
