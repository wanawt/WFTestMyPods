//
//  LRNewsCateModel.m
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/20.
//

#import "LRNewsCateModel.h"

@implementation LRNewsCateModel

- (NSMutableArray *)newsArray {
    if (!_newsArray) {
        _newsArray = [NSMutableArray array];
    }
    return _newsArray;
}

- (NSMutableArray *)adDataArray {
    if (!_adDataArray) {
        _adDataArray = [NSMutableArray array];
    }
    return _adDataArray;
}

@end
