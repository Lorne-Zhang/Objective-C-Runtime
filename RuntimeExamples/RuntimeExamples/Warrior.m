//
//  Warrior.m
//  RuntimeExamples
//
//  Created by 张飞龙 on 2018/3/13.
//  Copyright © 2018年 张飞龙. All rights reserved.
//

#import "Warrior.h"
#import "Diplomat.h"
@interface Warrior()
{
    Diplomat *diplomat;
}
@end

@implementation Warrior

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [Diplomat instanceMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL aSelector = [anInvocation selector];
    Diplomat *diplomat = [[Diplomat alloc] init];
    if ([diplomat respondsToSelector:aSelector]) {
        [anInvocation invokeWithTarget:diplomat];
    }else {
        [super forwardInvocation:anInvocation];
    }
}
@end
