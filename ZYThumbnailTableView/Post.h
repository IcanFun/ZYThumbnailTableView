//
//  Post.h
//  ZYThumbnailTableView
//
//  Created by zengxiangpeng on 16/4/5.
//  Copyright (c) 2016年 zxp. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK: Model class
@interface Post : NSObject
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *avatar;
@property(nonatomic,strong)NSString *desc;
@property(nonatomic,strong)NSString *time;
@property(nonatomic,strong)NSString *content;
@property(nonatomic)BOOL favorite;
@property(nonatomic)BOOL read;
@end
