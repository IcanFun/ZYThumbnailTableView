//
//  DIYTableViewCell.h
//  ZYThumbnailTableView
//
//  Created by zengxiangpeng on 16/4/5.
//  Copyright (c) 2016年 zxp. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Post;
@interface DIYTableViewCell : UITableViewCell
{
    IBOutlet UILabel *contentLabel;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *descLabel;
    IBOutlet UILabel *timeLabel;
    IBOutlet UIImageView *avatarImageView;
    IBOutlet UIImageView *favoriteMarkImageView;
    IBOutlet UIImageView *unreadMarkImageView;
}

- (instancetype)creatCell;
- (void)updateCell:(Post*)post;
@end
