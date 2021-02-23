//
//  LRNewsCateModel.h
//  AdFulishe
//
//  Created by 张维凡 on 2021/1/20.
//

#import <UIKit/UIKit.h>

@interface LRNewsCateModel : NSObject

@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger cateIndex;

@property (nonatomic, strong) NSMutableArray *newsArray;    // 新闻列表
@property (nonatomic, strong) NSMutableArray *adDataArray;  // 广告列表
@property (nonatomic, strong) UITableView *tableView;

@end
