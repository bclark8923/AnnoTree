//
//  AnnoTreeLibrary.h
//  AnnoTreeLibrary
//
//  Created by Brian Clark on 4/27/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnnoTree.h"

@interface AnnoTreeLibrary : NSObject

//@property (nonatomic, retain) AnnoTree *annoTreeInstance;

//+ (id)sharedInstance;

+ (UIView*) getAnnoTreeLauncher:(UIInterfaceOrientation)orientation;

@end
