//
//  HHFlsCateView.h
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^lrNewsCateSelectBlock)(NSInteger index);
typedef void(^lrNewsMoreCateBlock)(void);

@interface HHFlsCateView : UIView

@property (nonatomic, copy) lrNewsCateSelectBlock lrNewsCateSelectBlock;
@property (nonatomic, copy) lrNewsMoreCateBlock lrNewsMoreCateBlock;
@property (nonatomic, assign) NSInteger selectedIndex;

- (void)setupCates:(NSArray *)array selectedIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
