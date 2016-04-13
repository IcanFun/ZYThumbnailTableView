//
//  ViewController.m
//  ZYThumbnailTableView
//
//  Created by zengxiangpeng on 16/4/5.
//  Copyright (c) 2016年 zxp. All rights reserved.
//

#import "ViewController.h"
#import "ZYThumbnailTableViewController.h"
#import "TopView.h"
#import "DIYTableViewCell.h"
#import "Post.h"
#import "BottomView.h"

@interface ViewController ()<ZYThumbnailTableViewControllerDelegate, DiyTopViewDelegate>
{
    ZYThumbnailTableViewController *zyThumbnailTableVC;
    NSMutableArray     *dataList;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureNav];
    [self configureZYTableView];
    
    self.title = @"1111";
}

- (void)configureNav
{
    self.navigationController.navigationBar.translucent = YES;
    self.title = @"ZYThumbnailTabelView";
    
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    self.navigationItem.backBarButtonItem = barItem;
}

- (void)configureZYTableView
{
    zyThumbnailTableVC = [[ZYThumbnailTableViewController alloc] init];
    zyThumbnailTableVC.tableViewCellReuseId = @"DIYTableViewCell";
    zyThumbnailTableVC.tableViewCellHeight = 100.0;
    //模拟创建一些数据作为演示
    dataList = [self createDataSource];
    //--------configure your diy tableview cell datalist
    zyThumbnailTableVC.tableViewDataList = dataList;
    
    //--------insert your diy tableview cell
    zyThumbnailTableVC.configureTableViewCellBlock = ^{
        return [[DIYTableViewCell alloc] creatCell];
    };
    
    __block ZYThumbnailTableViewController *weak_zyThumbnailTableVC = zyThumbnailTableVC;
    __block ViewController *weak_self = self;
    
    //--------update your cell here
    zyThumbnailTableVC.updateTableViewCellBlock =  ^(UITableViewCell* cell, NSIndexPath *indexPath){
        DIYTableViewCell *myCell = (DIYTableViewCell*)cell;
        
        //Post is my data model
        Post *dataSource = weak_zyThumbnailTableVC.tableViewDataList[indexPath.row];
        if (dataSource) {
            [myCell updateCell:dataSource];
        }
    };
    
    //--------insert your diy TopView
    zyThumbnailTableVC.createTopExpansionViewBlock = ^(NSIndexPath* indexPath){
        Post *post = weak_zyThumbnailTableVC.tableViewDataList[indexPath.row];
        TopView *topView = [[TopView alloc] creatView:indexPath Post:post];
        topView.delegate = weak_self;
        return topView;
    };
    
    BottomView *diyBottomView = [[BottomView alloc] creat];
    //--------let your inputView component not cover by keyboard automatically (animated) (ZYKeyboardUtil)
    //全自动键盘遮盖处理
    zyThumbnailTableVC.keyboardAdaptiveView = diyBottomView.inputTextField;
    //--------insert your diy BottomView
    zyThumbnailTableVC.createBottomExpansionViewBlock = ^(NSIndexPath* indexPath){
        return diyBottomView;
    };
    
    zyThumbnailTableVC.title = @"ZYThumbnailTableView";
}


- (IBAction)clickEnterButton:(UIButton*)sender
{
    [self.navigationController pushViewController:zyThumbnailTableVC animated:YES];
}

#pragma mark - delegate
- (void)zyTableViewDidSelectRow:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
}

- (void)topViewDidClickFavoriteBtn:(TopView *)topView
{
    Post *post = zyThumbnailTableVC.tableViewDataList[topView.indexPath.row];
    post.favorite = !post.favorite;
    [zyThumbnailTableVC reloadMainTableView];
}

- (void)topViewDidClickMarkAsReadButton:(TopView *)topView
{
    Post *post = zyThumbnailTableVC.tableViewDataList[topView.indexPath.row];
    post.read = !post.read;
    [zyThumbnailTableVC reloadMainTableView];
}

//此方法作用是虚拟出tableview数据源，不用理会
//MARK: -Virtual DataSource
- (NSMutableArray*)createDataSource
{
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    [dataSource addObject:@{@"name" : @"NURGIO",
                            @"avatar" : @"avatar0",
                            @"desc" : @"Beijing,Chaoyang District",
                            @"time" : @"3 minute",
                            @"content" : @"The lesson of the story, I suggested, was that in some strange sense we are more whole when we are missing something. \n    The man who has everything is in some ways a poor man. \n    He will never know what it feels like to yearn, to hope, to nourish his soul with the dream of something better. \n    He will never know the experience of having someone who loves him give him something he has always wanted or never had.",
                            @"favorite" : @"1",
                              @"read" : @"0"}];
    
    [dataSource addObject:@{@"name" : @"Cheers",
                            @"avatar" : @"avatar1",
                            @"desc" : @"Joined on Dec 18, 2014",
                            @"time" : @"8 minute",
                            @"content" : @"You know that you do not need to be in the limelight to gain happiness. If you constantly aim to be in the spotlight, you are looking to others for validation. \n    In actuality, you should just be yourself. People do not like characters that are always in your line of vision and trying to gain your attention.\n    You know that you can just be yourself with others, without the need to be in the limelight. \n    People will see you as a beautiful girl when you are being you, not trying to persistently have all attention on you. \n    Who can have a real conversation with someone who is eagerly looking around and making sure all eyes are on them?",
                            @"favorite" : @"0",
                            @"read" : @"1"}];
    
    [dataSource addObject:@{@"name" : @"Adleys",
                            @"avatar" : @"avatar2",
                            @"desc" : @"The Technology Studio",
                            @"time" : @"16 minute",
                            @"content" : @"To each parent he responded with one line: \"Are you going to help me now?\" \n    And then he continued to dig for his son, stone by stone. \n    The fire chief showed up and tried to pull him off the school s ruins saying, \"Fires are breaking out, explosions are happening everywhere. \n    You’re in danger. We’ll take care of it. Go home.\" To which this loving, caring American father asked, \"Are you going to help me now?\"",
                            @"favorite" : @"0",
                            @"read" : @"0"}];
    
    [dataSource addObject:@{@"name" : @"Coder_CYX",
                            @"avatar" : @"avatar3",
                            @"desc" : @"Joined on Mar 26, 2013",
                            @"time" : @"21 minute",
                            @"content" : @"One year after our \"talk,\" I discovered I had breast cancer. I was thirty-two, the mother of three beautiful young children, and scared. \n    The cancer had metastasized to my lymph nodes and the statistics were not great for long-term survival. \n    After my surgery, friends and loved ones visited and tried to find the right words. No one knew what to say, and many said the wrong things. \n    Others wept, and I tried to encourage them. I clung to hope myself.",
                            @"favorite" : @"1",
                            @"read" : @"0"}];
    
    [dataSource addObject:@{@"name" : @"Coleman",
                            @"avatar" : @"avatar4",
                            @"desc" : @"Zhejiang University of Technology",
                            @"time" : @"28 minute",
                            @"content" : @"You don’t let others hold you back from being yourself. To many people, showing your real face to others is terrifying. But you are always yourself.\n    You don’t let others opinions scare you into being someone else. Instead you choose to be you, flaws and all. You are truly a beautiful girl if you possess this quality. \n    People can often sense when you are being fake, or notice if you are reserved and afraid to speak. To be able to be yourself is inspiring and beautiful, because you are putting yourself out there (without fear).",
                            @"favorite" : @"0",
                            @"read" : @"0"}];
    
    [dataSource addObject:@{@"name" : @"Moguilay",
                            @"avatar" : @"avatar5",
                            @"desc" : @"zbien.com",
                            @"time" : @"33 minute",
                            @"content" : @"You don’t let others hold you back from being yourself. To many people, showing your real face to others is terrifying. But you are always yourself.\n    You don’t let others opinions scare you into being someone else. Instead you choose to be you, flaws and all. You are truly a beautiful girl if you possess this quality. \n    People can often sense when you are being fake, or notice if you are reserved and afraid to speak. To be able to be yourself is inspiring and beautiful, because you are putting yourself out there (without fear).",
                            @"favorite" : @"0",
                            @"read" : @"0"}];
    
    [dataSource addObject:@{@"name" : @"Dikey",
                            @"avatar" : @"avatar6",
                            @"desc" : @"Pluto at the moment",
                            @"time" : @"33 minute",
                            @"content" : @"You don’t let others hold you back from being yourself. To many people, showing your real face to others is terrifying. But you are always yourself.\n    You don’t let others opinions scare you into being someone else. Instead you choose to be you, flaws and all. You are truly a beautiful girl if you possess this quality. \n    People can often sense when you are being fake, or notice if you are reserved and afraid to speak. To be able to be yourself is inspiring and beautiful, because you are putting yourself out there (without fear).",
                            @"favorite" : @"0",
                            @"read" : @"0"}];
    
    [dataSource addObject:@{@"name" : @"fmricky",
                            @"avatar" : @"avatar7",
                            @"desc" : @"Waterloo, ON",
                            @"time" : @"42 minute",
                            @"content" : @"You don’t let others hold you back from being yourself. To many people, showing your real face to others is terrifying. But you are always yourself.\n    You don’t let others opinions scare you into being someone else. Instead you choose to be you, flaws and all. You are truly a beautiful girl if you possess this quality. \n    People can often sense when you are being fake, or notice if you are reserved and afraid to speak. To be able to be yourself is inspiring and beautiful, because you are putting yourself out there (without fear).",
                            @"favorite" : @"0",
                            @"read" : @"0"}];
    
    [dataSource addObject:@{@"name" : @"Robert Waggott",
                            @"avatar" : @"avatar8",
                            @"desc" : @"Beijing chaoyang",
                            @"time" : @"46 minute",
                            @"content" : @"You don’t let others hold you back from being yourself. To many people, showing your real face to others is terrifying. But you are always yourself.\n    You don’t let others opinions scare you into being someone else. Instead you choose to be you, flaws and all. You are truly a beautiful girl if you possess this quality. \n    People can often sense when you are being fake, or notice if you are reserved and afraid to speak. To be able to be yourself is inspiring and beautiful, because you are putting yourself out there (without fear).",
                            @"favorite" : @"0",
                            @"read" : @"0"}];
    
    //source dict to model
    NSMutableArray *postArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in dataSource) {
        Post *post = [[Post alloc] init];
        post.name = [dict objectForKey:@"name"];
        post.desc = [dict objectForKey:@"desc"];
        post.time = [dict objectForKey:@"time"];
        post.content = [dict objectForKey:@"content"];
        post.avatar = [dict objectForKey:@"avatar"];
        post.favorite = [[dict objectForKey:@"favorite"] integerValue]?YES:NO;
        post.read = [[dict objectForKey:@"read"] integerValue]?YES:NO;
        [postArray addObject:post];
    }
    
    return postArray;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
