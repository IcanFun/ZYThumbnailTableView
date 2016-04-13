//
//  TopView.h
//  ZYThumbnailTableView
//
//  Created by zengxiangpeng on 16/4/5.
//  Copyright (c) 2016年 zxp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TopView;
@class Post;
@protocol DiyTopViewDelegate <NSObject>

@optional
- (void)topViewDidClickFavoriteBtn:(TopView*)topView;
- (void)topViewDidClickMarkAsReadButton:(TopView*)topView;
- (void)topViewDidClickShareBtn:(TopView*)topView;

@end

@interface TopView : UIView
{
    IBOutlet UIButton *readMarkingButton;
    IBOutlet UIButton *favoriteButton;
}
@property(nonatomic, strong)id<DiyTopViewDelegate>delegate;
@property(nonatomic, strong)NSIndexPath *indexPath;

- (instancetype)creatView:(NSIndexPath*)indexpath Post:(Post*)post;
@end
