//
//  Post.m
//  ZYThumbnailTableView
//
//  Created by zengxiangpeng on 16/4/5.
//  Copyright (c) 2016年 zxp. All rights reserved.
//

#import "Post.h"

@implementation Post
@synthesize name,avatar,desc,time,content,favorite,read;
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.name = @"";
        self.avatar = @"";
        self.desc = @"";
        self.time = @"";
        self.content = @"";
        self.favorite = NO;
        self.read = NO;
    }
    return self;
}
@end
