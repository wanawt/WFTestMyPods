//
//  YYLRModel.h
//  YYLRModel <https://github.com/ibireme/YYLRModel>
//
//  Created by ibireme on 15/5/10.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

#if __has_include(<YYLRModel/YYLRModel.h>)
FOUNDATION_EXPORT double YYLRModelVersionNumber;
FOUNDATION_EXPORT const unsigned char YYLRModelVersionString[];
#import <YYLRModel/NSObject+YYLRModel.h>
#import <YYLRModel/YYLRClassInfo.h>
#else
#import "NSObject+YYLRModel.h"
#import "YYLRClassInfo.h"
#endif
