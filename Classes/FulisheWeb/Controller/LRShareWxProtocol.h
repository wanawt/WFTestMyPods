//
//  LRShareWxProtocol.h
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LRShareWxStatus) {
    LRShareWxStatusCanShare = 1,        // 1: 有分享功能
    LRShareWxStatusCanOpen = 2,         // 2: 无分享功能但是能调起微信
    LRShareWxStatusCantOpen = 0,        // 0: 无分享功能，也不能唤起微信
};

@protocol LRShareWxProtocol <NSObject>

- (LRShareWxStatus)lrShareWxStatus;

// 有微信分享功能，调用
- (void)lrShareToWxWithInfo:(NSDictionary *)shareInfo;

// 无微信分享功能，但能打开微信，打开
- (void)lrOpenWxToShare;

@end

NS_ASSUME_NONNULL_END
