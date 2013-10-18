//
//  Queue.m
//  AnnoTree Viewer
//
//  Created by Mike on 10/16/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "Queue.h"

@implementation Queue


- (void) enqueue: (id)item {
    [self addObject:item];
}

- (id) dequeue {
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
