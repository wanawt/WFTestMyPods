//
//  HHFlsVideoAdController.m
//  AdFulishe
//
//  Created by 张维凡 on 2020/12/10.
//

#import "HHFlsVideoAdController.h"
#import "GDTRewardVideoAd.h"

@interface HHFlsVideoAdController () <GDTRewardedVideoAdDelegate>

@property (nonatomic, strong) GDTRewardVideoAd *rewardVideoAd;
@property (nonatomic, assign) BOOL isVideoLoaded;

@end

@implementation HHFlsVideoAdController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    

}


@end
