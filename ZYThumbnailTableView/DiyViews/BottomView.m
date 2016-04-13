//
//  BottomView.m
//  ZYThumbnailTableView
//
//  Created by zengxiangpeng on 16/4/5.
//  Copyright (c) 2016年 zxp. All rights reserved.
//

#import "BottomView.h"
#import "ZYThumbnailTableViewController.h"

@interface BottomView()

@end

@implementation BottomView
@synthesize inputTextField;

- (instancetype)creat
{
    BottomView *view = [[[NSBundle mainBundle] loadNibNamed:@"BottomView" owner:nil options:nil] firstObject];
    return view;
}

- (IBAction)clickDismissButton:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_NAME_DISMISS_PREVIEW object:nil];
}

@end
