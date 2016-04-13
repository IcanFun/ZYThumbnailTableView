//
//  TopView.m
//  ZYThumbnailTableView
//
//  Created by zengxiangpeng on 16/4/5.
//  Copyright (c) 2016年 zxp. All rights reserved.
//

#import "TopView.h"
#import "Post.h"

#define TAG_BUTTON_GENERAL  10
#define TAG_BUTTON_SELECTED 20
#define COLOR_SELECTED      [UIColor colorWithRed:167/255.0 green:218/255.0 blue:85/255.0 alpha:1.0]
#define COLOR_NORMAL        [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1.0]

@interface TopView()
{
    
}
@end

@implementation TopView
@synthesize delegate, indexPath;

- (instancetype)creatView:(NSIndexPath*)indexpath Post:(Post*)post
{
    TopView *view = [[[NSBundle mainBundle] loadNibNamed:@"TopView" owner:nil options:nil] firstObject];
    view->indexPath = indexpath;

    [view configureComponents:post];
    return view;
}

- (void)configureComponents:(Post*)post {
    //-----收藏
    if (post.favorite) {
        [favoriteButton setImage:[UIImage imageNamed:@"star_solid"] forState:UIControlStateNormal];
        [favoriteButton setTitleColor:COLOR_SELECTED forState:UIControlStateNormal];
        favoriteButton.tag = TAG_BUTTON_SELECTED;
    } else {
        [favoriteButton setImage:[UIImage imageNamed:@"star_hollow"] forState:UIControlStateNormal];
        [favoriteButton setTitleColor:COLOR_NORMAL forState:UIControlStateNormal];
        favoriteButton.tag = TAG_BUTTON_GENERAL;
    }
    
    //-----已读
    if (post.read) {
        //setimage
        [readMarkingButton setImage:[UIImage imageNamed:@"tick_solid"] forState:UIControlStateNormal];
        [readMarkingButton setTitleColor:COLOR_SELECTED forState:UIControlStateNormal];
        [readMarkingButton setTitle:@" Mark as Unread" forState:UIControlStateNormal];
        readMarkingButton.tag = TAG_BUTTON_SELECTED;
    } else {
        //setimage
        [readMarkingButton setImage:[UIImage imageNamed:@"tick_hollow"] forState:UIControlStateNormal];
        [readMarkingButton setTitleColor:COLOR_NORMAL forState:UIControlStateNormal];
        [readMarkingButton setTitle:@" Mark as Read" forState:UIControlStateNormal];
        readMarkingButton.tag = TAG_BUTTON_GENERAL;
    }
}

- (IBAction)clickFavoriteButton:(UIButton*)sender
{
    if (sender.tag == TAG_BUTTON_GENERAL) {
        [sender setTitleColor:COLOR_SELECTED forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"star_solid"] forState:UIControlStateNormal];
        sender.tag = TAG_BUTTON_SELECTED;
    } else if (sender.tag == TAG_BUTTON_SELECTED) {
        [sender setTitleColor:COLOR_NORMAL forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"star_hollow"] forState:UIControlStateNormal];
        sender.tag = TAG_BUTTON_GENERAL;
    }
    
    //notification
    [[NSNotificationCenter defaultCenter] performSelector:@selector(postNotification:) withObject:[NSNotification notificationWithName:@"NOTIFY_NAME_DISMISS_PREVIEW" object:nil] afterDelay:0.25];
    
    //delegate
    if (delegate) {
        [delegate topViewDidClickFavoriteBtn:self];
    }
}

- (IBAction)clickMarkAsReadButton:(UIButton*)sender
{
    if (sender.tag == TAG_BUTTON_GENERAL) {
        [sender setTitleColor:COLOR_SELECTED forState:UIControlStateNormal];
        [sender setTitle:@" Mark as Unread" forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"tick_solid"] forState:UIControlStateNormal];
        sender.tag = TAG_BUTTON_SELECTED;
    } else if (sender.tag == TAG_BUTTON_SELECTED) {
        [sender setTitleColor:COLOR_NORMAL forState:UIControlStateNormal];
        [sender setTitle:@" Mark as Read" forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"tick_hollow"] forState:UIControlStateNormal];
        sender.tag = TAG_BUTTON_GENERAL;
    }
    
    //notification
    [[NSNotificationCenter defaultCenter] performSelector:@selector(postNotification:) withObject:[NSNotification notificationWithName:@"NOTIFY_NAME_DISMISS_PREVIEW" object:nil] afterDelay:0.25];

    
    //delegate
    if (delegate) {
        [delegate topViewDidClickMarkAsReadButton:self];
    }
}

@end
