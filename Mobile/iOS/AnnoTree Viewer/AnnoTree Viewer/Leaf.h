//
//  Leaf.h
//  AnnoTree Viewer
//
//  Created by Mike on 9/2/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "DrawingViewController.h"
#import "AnnoTree.h"


@interface Leaf : NSObject

@property
NSString* leafName;

@property UIAlertView *leafUploading;

- (id)init:(NSString*)leafName annotree:(NSObject*)annoTree;
- (void)sendLeaf;

@end
