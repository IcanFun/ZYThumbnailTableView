//
//  ZYThumbnailTableViewController.h
//  ZYThumbnailTableView
//
//  Created by zengxiangpeng on 16/4/6.
//  Copyright (c) 2016年 zxp. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NOTIFY_NAME_DISMISS_PREVIEW @"NOTIFY_NAME_DISMISS_PREVIEW"

typedef UITableViewCell* (^ConfigureTableViewCellBlock)();
typedef void (^UpdateTableViewCellBlock)(UITableViewCell*,NSIndexPath*);
typedef UIView* (^CreateTopExpansionViewBlock)(NSIndexPath*);
typedef UIView* (^CreateBottomExpansionViewBlock)(NSIndexPath*);

@protocol ZYThumbnailTableViewControllerDelegate <NSObject>

@optional
- (void)zyTableViewDidSelectRow:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath;

@end

@interface ZYThumbnailTableViewController : UIViewController

@property(nonatomic, strong)NSString *tableViewCellReuseId;
/**
 tableView cell height
 */
@property(nonatomic) CGFloat    tableViewCellHeight;
/**
 tableView dataList
 */
@property(nonatomic, strong)NSMutableArray *tableViewDataList;

/**
 give me your inputView, I will not allow the keyboard cover him. (ZYKeyboardUtil)
 */
@property(nonatomic, strong)UIView *keyboardAdaptiveView;

//MARK: BLOCKS
@property(nonatomic, strong)ConfigureTableViewCellBlock configureTableViewCellBlock;
@property(nonatomic, strong)UpdateTableViewCellBlock    updateTableViewCellBlock;
@property(nonatomic, strong)CreateTopExpansionViewBlock createTopExpansionViewBlock;
@property(nonatomic, strong)CreateBottomExpansionViewBlock  createBottomExpansionViewBlock;


- (void)reloadMainTableView;
@end

@interface UIView(updata)
- (void)updateOriginX:(CGFloat)originX;
- (void)updateOriginY:(CGFloat)originY;
- (void)updateCenterX:(CGFloat)centerX;
- (void)updateCenterY:(CGFloat)centerY;
- (void)updateWidth:(CGFloat)width;
- (void)updateHeight:(CGFloat)height;
- (UIImage*)screenShot;
@end