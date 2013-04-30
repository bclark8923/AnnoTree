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

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (void) loadTree:(UIInterfaceOrientationMask)orientation {
    [[AnnoTree sharedInstance] loadTree:UIInterfaceOrientationMaskAll];
}

@end
