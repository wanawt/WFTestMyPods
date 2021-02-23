//
//  WKProcessPool+FlsSharedProcessPool.m
//  importevent
//
//  Created by 张维凡 on 2020/11/5.
//  Copyright © 2020 lanren. All rights reserved.
//

#import "WKProcessPool+FlsSharedProcessPool.h"

@implementation WKProcessPool (FlsSharedProcessPool)

+ (WKProcessPool*)sharedProcessPool {
    static WKProcessPool* SharedProcessPool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedProcessPool = [[WKProcessPool alloc] init];
    });
    return SharedProcessPool;
}

@end
