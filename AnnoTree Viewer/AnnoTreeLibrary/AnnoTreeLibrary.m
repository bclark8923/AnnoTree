//
//  AnnoTreeLibrary.m
//  AnnoTreeLibrary
//
//  Created by Brian Clark on 4/27/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "AnnoTreeLibrary.h"

@implementation AnnoTreeLibrary

//@synthesize annoTreeInstance;
/*
- (id) init {
    self = [super init];
    if (self) {
        annoTreeInstance = [[AnnoTree alloc] init];
    }
    return self;
}*/
/*
+ (id)sharedInstance
{
    return [AnnoTree sharedInstance];
}*/

+ (UIView*) getAnnoTreeLauncher:(UIInterfaceOrientation)orientation {
    return [[AnnoTree sharedInstance] getAnnoTreeLauncher:orientation];
}

@end
