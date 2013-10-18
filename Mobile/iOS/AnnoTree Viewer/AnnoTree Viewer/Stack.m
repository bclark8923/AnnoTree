//
//  Stack.m
//  AnnoTree Viewer
//
//  Created by Mike on 10/16/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "Stack.h"

@implementation NSMutableArray(Stack)

-(id)init {
    return [super init];
}

- (void) push: (id)item {
    [self insertObject:item atIndex:0];
}

- (id) pop {
    id item = nil;
    if ([self count] != 0) {
        item = [self objectAtIndex:0];
        [self removeObjectAtIndex:0];
    }
    return item;
}

- (id) peek {
    id item = nil;
    if ([self count] != 0) {
        item = [self objectAtIndex:0];
    }
    return item;
}

@end
