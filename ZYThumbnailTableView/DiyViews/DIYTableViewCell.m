//
//  DIYTableViewCell.m
//  ZYThumbnailTableView
//
//  Created by zengxiangpeng on 16/4/5.
//  Copyright (c) 2016年 zxp. All rights reserved.
//

#import "DIYTableViewCell.h"
#import "Post.h"

@implementation DIYTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)creatCell
{
    DIYTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"DIYTableViewCell" owner:nil options:nil] firstObject];
    return cell;
}

- (void)updateCell:(Post*)post
{
    nameLabel.text = post.name;
    descLabel.text = post.desc;
    timeLabel.text = post.time;
    contentLabel.text = post.content;
    avatarImageView.image = [UIImage imageNamed:post.avatar]?[UIImage imageNamed:post.avatar]:[UIImage imageNamed:@"avatar0"];
    
    favoriteMarkImageView.hidden = !post.favorite;
    unreadMarkImageView.hidden = post.read;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
