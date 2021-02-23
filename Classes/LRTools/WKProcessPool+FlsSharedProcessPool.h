//
//  WKProcessPool+FlsSharedProcessPool.h
//  importevent
//
//  Created by 张维凡 on 2020/11/5.
//  Copyright © 2020 lanren. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKProcessPool (FlsSharedProcessPool)

+ (WKProcessPool*)sharedProcessPool;

@end

NS_ASSUME_NONNULL_END
