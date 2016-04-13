//
//  ZYThumbnailTableViewController.m
//  ZYThumbnailTableView
//
//  Created by zengxiangpeng on 16/4/6.
//  Copyright (c) 2016年 zxp. All rights reserved.
//

#import "ZYThumbnailTableViewController.h"
#import "ZYKeyboardUtil.h"
#import "BlurUtil.h"
#import <objc/runtime.h>

#define KEY_INDEXPATH @"KEY_INDEXPATH"

#define MARGIN_KEYBOARD_ADAPTATION  20
#define TYPE_EXPANSION_VIEW_TOP  @"TYPE_EXPANSION_VIEW_TOP"
#define TYPE_EXPANSION_VIEW_BOTTOM  @"TYPE_EXPANSION_VIEW_BOTTOM"



@interface ZYThumbnailTableViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    /**
     tableView backgroundColor
     */
    UIColor     *tableViewBackgroudColor;
    
    
    UIColor     *blurTintColor;
    CGFloat     blurRadius;
    CGFloat     saturationDeltaFactor;
    
    /**
     main tableView
     */
    UITableView *mainTableView;
    /**
     the index you click to expand in tableview
     */
    int         clickIndexPathRow;
    /**
     the full height of the thumbnailView calculated after spread
     */
    CGFloat     spreadCellHeight;
    /**
     copy from the cell which be click ,and show simultaneously
     */
    UIView      *thumbnailView;
    /**
     control the panGesture working or not
     */
    BOOL        thumbnailViewCanPan;
    /**
     UIDynamicAnimator
     */
    UIDynamicAnimator   *animator;
    /**
     the amplitude while you pan(up or down) the thumbnailView
     */
    CGFloat     expandAmplitude;
    /**
     A Util Handed all keyboard events with Block Conveniently
     */
    ZYKeyboardUtil      *keyboardUtil;
}
@end

@implementation ZYThumbnailTableViewController
@synthesize tableViewCellReuseId, tableViewCellHeight, tableViewDataList, keyboardAdaptiveView, configureTableViewCellBlock, updateTableViewCellBlock, createBottomExpansionViewBlock, createTopExpansionViewBlock;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setDefaultData];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setView];
}

- (void)setDefaultData
{
    tableViewCellReuseId = @"diyCell";
    tableViewCellHeight = 100.0;
    tableViewDataList = [[NSMutableArray alloc] initWithCapacity:10];
    tableViewBackgroudColor = [UIColor whiteColor];
    
    blurTintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    blurRadius = 4.0;
    saturationDeltaFactor = 1.8;
    
    thumbnailViewCanPan = YES;
    
    expandAmplitude = 10;
    
    configureTableViewCellBlock = ^{
        NSCAssert(nil,@"ERROR: You must configure the configureTableViewCellBlock");
        return (UITableViewCell *)nil;
    };
    
    updateTableViewCellBlock = ^(UITableViewCell* cell,NSIndexPath* indexPath){
        NSCAssert(nil,@"ERROR: You must configure the updateTableViewCellBlock");
    };
    
    createTopExpansionViewBlock = ^(NSIndexPath* indexPath){
        NSLog(@"WARNNING: You have no configure the createTopExpansionViewBlock");
        return (UIView*)nil;
    };
    
    createBottomExpansionViewBlock = ^(NSIndexPath* indexPath) {
        NSLog(@"WARNNING: You have no configure the createBottomExpansionViewBlock");
        return (UIView*)nil;
    };
}

- (void)setView
{
    mainTableView = [[UITableView alloc] initWithFrame:self.view.frame];
    
    [self configureKeyboardUtil];
    [self configureTableView];
}

- (void)viewDidLayoutSubviews
{
    [mainTableView updateHeight:self.view.frame.size.height];
}

/**
 used ZYKeyboardUtil githubDemo: https://github.com/liuzhiyi1992/ZYKeyboardUtil
 */
- (void)configureKeyboardUtil
{
    if (!keyboardAdaptiveView) {
        return;
    }
    
    //全自动键盘遮盖处理
    keyboardUtil = [[ZYKeyboardUtil alloc]init];
    __weak UIViewController *weakself = self;
    __weak UIView   *weak_keyboardAdaptiveView = keyboardAdaptiveView;
    [keyboardUtil setAnimateWhenKeyboardAppearAutomaticAnimBlock:^NSDictionary *{
        NSDictionary *viewDict = [[NSDictionary alloc] initWithObjectsAndKeys:weak_keyboardAdaptiveView,ADAPTIVE_VIEW, weakself.view,CONTROLLER_VIEW,nil];
        return viewDict;
    }];
    
    [keyboardUtil setAnimateWhenKeyboardDisappearBlock:^(CGFloat keyboardHeight) {
        [weakself.view updateOriginY:0];
    }];
}

- (void)configureTableView
{
    [self.view addSubview:mainTableView];
    
    mainTableView.backgroundColor = tableViewBackgroudColor;
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [mainTableView reloadData];
}

#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableViewDataList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellReuseId];
    if (!cell) {
        //配置cell的Block
        cell = configureTableViewCellBlock();
        
        if (!cell) {
            NSCAssert(cell,@"ERROR: cell can not be nil, plase config cell aright with configureTableViewCellBlock");
            return [[UITableViewCell alloc] initWithFrame:CGRectZero];
        }
    }
    //这里updateCell
    updateTableViewCellBlock(cell,indexPath);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == clickIndexPathRow) {
        return tableViewCellHeight;
    }
    return tableViewCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (selectedCell) {
        //计算高度
        [self calculateCell:selectedCell indexPath:indexPath];
        
        //记录点击cell的index
        clickIndexPathRow = (int)indexPath.row;
        //update Cell
        [mainTableView beginUpdates];
        [mainTableView endUpdates];
        
        //动画纠正thumbnailView
        CGRect tempConvertRect = [mainTableView convertRect:selectedCell.frame toView:self.view];
        CGRect thumbnailViewFrame = thumbnailView.frame;
        thumbnailViewFrame.origin.y = tempConvertRect.origin.y;
        [UIView animateWithDuration:0.3 animations:^{
            thumbnailView.frame = thumbnailViewFrame;
        }];
    }
}

- (void)calculateCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    NSLayoutConstraint *tempConstraint =[NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CGRectGetWidth(mainTableView.frame)];
    [cell.contentView addConstraint:tempConstraint];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    [cell.contentView removeConstraint:tempConstraint];
    spreadCellHeight = size.height;
    [self previewCell:cell indexPath:indexPath];
}

- (void)previewCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    //create previewCover
    UIImageView *previewCover = [[UIImageView alloc] initWithFrame:mainTableView.frame];
    
    //blur background
    UIImage *blurImage = mainTableView.screenShot;
    previewCover.image = [blurImage applyBlurWithRadius:blurRadius tintColor:blurTintColor saturationDeltaFactor:saturationDeltaFactor maskImage:nil];
    previewCover.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPreviewCover)];
    [previewCover addGestureRecognizer:tapGesture];
    [self.view insertSubview:previewCover aboveSubview:mainTableView];
    
    //animator
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:previewCover];
    
    //create thumbnailView
    CGRect convertRect = [mainTableView convertRect:cell.frame toView:self.view];
    CGFloat thumbnailLocationY = CGRectGetMinY(convertRect);
    thumbnailView = [[UIView alloc] initWithFrame:CGRectMake(0, thumbnailLocationY, mainTableView.frame.size.width, tableViewCellHeight)];
    
    //binding the indexPath
    objc_setAssociatedObject(thumbnailView, KEY_INDEXPATH, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    thumbnailView.backgroundColor = [UIColor whiteColor];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThumbnailView:)];
    [thumbnailView addGestureRecognizer:panGesture];
    [previewCover addSubview:thumbnailView];
    
    //create a new one with configureTableViewCellBlock
    UITableViewCell *previewCell = configureTableViewCellBlock();
    previewCell.selectionStyle = UITableViewCellSelectionStyleNone;
    updateTableViewCellBlock(previewCell, indexPath);
    
    //layout cell contentView in thumbnailView with VFL
    UIView *contentView = previewCell.contentView;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = [NSDictionary dictionaryWithObjectsAndKeys:contentView,@"contentView", nil];
    [thumbnailView addSubview:contentView];
    thumbnailView.clipsToBounds = YES;
    
    //constraint
    [thumbnailView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [thumbnailView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    //spread thumbnailView
    CGRect toFrame = thumbnailView.frame;
    toFrame.size.height = spreadCellHeight;
    [UIView animateWithDuration:0.201992 animations:^{
        thumbnailView.frame = toFrame;
    } completion:^(BOOL finished) {
        [self handleOverFlowScreen:thumbnailView];
    }];
}

- (void)tapPreviewCover
{
    [self dismissPreview];
}

- (void)dismissPreview
{
    clickIndexPathRow = -1;
    //todo 这里给开发者一个选择，要动画过程还是立即完成
    //    [mainTableView reloadData];
    [mainTableView beginUpdates];
    [mainTableView endUpdates];
    [UIView animateWithDuration:0.301992 animations:^{
        thumbnailView.superview.alpha = 0;
    } completion:^(BOOL finished) {
        [thumbnailView.superview removeFromSuperview];
        thumbnailViewCanPan = YES;
    }];
}

- (void)panThumbnailView:(UIPanGestureRecognizer*)gesture
{
    CGFloat thumbnailViewHeight = gesture.view.frame.size.height;
    CGPoint gestureTranslation = [gesture translationInView:gesture.view];
    CGFloat thresholdValue = thumbnailViewHeight * 0.3;
    if (thumbnailViewCanPan) {
        if (gestureTranslation.y > thresholdValue) {
            thumbnailViewCanPan = NO;
            NSIndexPath *indexPath = objc_getAssociatedObject(gesture.view, KEY_INDEXPATH);
            [self layoutTopView:indexPath];
        }
        else if (gestureTranslation.y < -thresholdValue) {
            thumbnailViewCanPan = NO;
            NSIndexPath *indexPath = objc_getAssociatedObject(gesture.view, KEY_INDEXPATH);
            [self layoutBottomView:indexPath];
        }
    }
    
    //gesture state
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [animator removeAllBehaviors];
            break;
        case UIGestureRecognizerStateEnded:
            break;
        default:
            break;
    }
}

- (void)shock:(UIView*)view type:(NSString*)type
{
    //超出tableview范围不shock
    CGFloat expandShockAmplitude;
    CGRect convertRect = [view.superview convertRect:view.frame toView:self.view];
    
    if ([type isEqual:TYPE_EXPANSION_VIEW_TOP]) {
        expandShockAmplitude = expandAmplitude;
        if (CGRectGetMaxY(convertRect) > CGRectGetHeight(self.view.frame)) {
            //超出下面
            return;
        }
    }
    else if ([type isEqual:TYPE_EXPANSION_VIEW_BOTTOM]) {
        expandShockAmplitude = -expandAmplitude;
        if (CGRectGetMinY(convertRect) < 0) {
            //超出上面
            return;
        }
    }
    else {
        NSLog(@"ERROR: function shock parameter illegal");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:0.1];
        CGPoint snapPoint = view.center;
        snapPoint.y += expandShockAmplitude;
        UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:view snapToPoint:snapPoint];
        snapBehavior.damping = 0.9;
        dispatch_async(dispatch_get_main_queue(), ^{
            [animator addBehavior:snapBehavior];
        });
        
        [NSThread sleepForTimeInterval:0.1];
        
        snapPoint.y -= expandShockAmplitude;
        snapBehavior = [[UISnapBehavior alloc] initWithItem:view snapToPoint:snapPoint];
        snapBehavior.damping = 0.9;
        dispatch_async(dispatch_get_main_queue(), ^{
            [animator removeAllBehaviors];
            [animator addBehavior:snapBehavior];
        });
    });
}

- (void)layoutTopView:(NSIndexPath*)indexPath
{
    UIView *contentView = thumbnailView.subviews.firstObject;
    UIView *topView = createTopExpansionViewBlock(indexPath);
    if (!topView) {
        thumbnailViewCanPan = YES;
        return;
    }
    topView.translatesAutoresizingMaskIntoConstraints = NO;
    [thumbnailView addSubview:topView];
    NSDictionary *views = [NSDictionary dictionaryWithObjectsAndKeys:contentView, @"contentView", topView, @"topView", nil];
    
    //remove all constraints
    [thumbnailView removeConstraints:thumbnailView.constraints];
    [thumbnailView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topView]-0-[contentView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [thumbnailView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [thumbnailView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    //update Frame
    [topView updateOriginY:-topView.frame.size.height];
    [UIView animateWithDuration:0.201992 animations:^{
        [thumbnailView updateHeight:thumbnailView.frame.size.height+topView.frame.size.height];
        [contentView updateOriginY:topView.frame.size.height];
        [topView updateOriginY:0];
    } completion:^(BOOL finished) {
        //Overflow screen
        [self handleOverFlowScreen:thumbnailView];
    }];
    
    //shock
    [self shock:thumbnailView type:TYPE_EXPANSION_VIEW_TOP];
}

- (void)layoutBottomView:(NSIndexPath*)indexPath
{
    UIView *contentView = thumbnailView.subviews.firstObject;
    UIView *bottomView = createBottomExpansionViewBlock(indexPath);
    if (!bottomView) {
        thumbnailViewCanPan = YES;
        return;
    }
    thumbnailViewCanPan = NO;
    bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    [thumbnailView addSubview:bottomView];
    NSDictionary *views = [NSDictionary dictionaryWithObjectsAndKeys:contentView, @"contentView", bottomView, @"bottomView", nil];
    
    //remove all constraints
    [thumbnailView removeConstraints:thumbnailView.constraints];
    [thumbnailView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]-0-[bottomView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [thumbnailView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [thumbnailView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    //update Frame
    [UIView animateWithDuration:0.201992 animations:^{
        [thumbnailView updateHeight:thumbnailView.frame.size.height+bottomView.frame.size.height];
        [thumbnailView updateOriginY:thumbnailView.frame.origin.y-bottomView.frame.size.height];
    } completion:^(BOOL finished) {
        //Overflow screen
        if (thumbnailView.frame.origin.y < 0) {
            [UIView animateWithDuration:0.201992 animations:^{
                [thumbnailView updateOriginY:0];
            }];
        }
    }];
    
    //shock
    [self shock:thumbnailView type:TYPE_EXPANSION_VIEW_BOTTOM];
}

- (void)handleOverFlowScreen:(UIView*)handleView
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    CGRect convertRect = [[handleView superview] convertRect:handleView.frame toView:keyWindow];
    CGFloat diff = CGRectGetMaxY(convertRect) - CGRectGetMaxY([UIScreen mainScreen].bounds);
    if (diff > 0) {
        [UIView animateWithDuration:0.201992 animations:^{
            [handleView updateOriginY:handleView.frame.origin.y-diff];
        }];
    }
}

- (UIBezierPath*)movingPath:(CGPoint)startPoint keyPoints:(CGPoint*)keyPoints,...
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:startPoint];
    
    if (keyPoints) {
        [path addLineToPoint:*keyPoints];
        va_list argumentList;
        va_start(argumentList, keyPoints); // Start scanning for arguments after firstObject.
        CGPoint *keyPoint;
        while((keyPoint = va_arg(argumentList, CGPoint*))) {// As many times as we can get an argument of type "CGPoint"
            [path addLineToPoint:*keyPoint];
        }
        va_end(argumentList);
    }
    
    return path;
}

- (UIImage*)applyBlurOnImage:(UIImage*)image blurRadius:(CGFloat)blurradius
{
    UInt32 boxSize = blurradius * 100;
    boxSize -= (boxSize % 2) + 1;
    
    CGImageRef rawImage = image.CGImage;
    
    vImage_Buffer inBuffer;
    vImage_Buffer outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(rawImage);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(rawImage);
    inBuffer.height = CGImageGetHeight(rawImage);
    inBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    inBuffer.data = (char*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(rawImage);
    outBuffer.height = CGImageGetHeight(rawImage);
    outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    
    vImage_Flags flags = kvImageNoFlags;
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, boxSize, boxSize, nil, flags);
    if (error != 0) {
        NSLog(@"error from convolution \(error)");
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(rawImage));
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    free(pixelBuffer);
    
    return returnImage;
}

- (void)reloadMainTableView
{
    [mainTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

@implementation UIView(updata)

- (void)updateOriginX:(CGFloat)originX
{
    self.frame = CGRectMake(originX, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}
- (void)updateOriginY:(CGFloat)originY
{
    self.frame = CGRectMake(self.frame.origin.x, originY, self.frame.size.width, self.frame.size.height);
}

- (void)updateCenterX:(CGFloat)centerX
{
    self.center = CGPointMake(centerX, self.center.y);
}

- (void)updateCenterY:(CGFloat)centerY
{
    self.center = CGPointMake(self.center.x, centerY);
}

- (void)updateWidth:(CGFloat)width
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

- (void)updateHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

- (UIImage*)screenShot
{
    UIGraphicsBeginImageContext(self.bounds.size);
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        //ios7以上
        [self drawViewHierarchyInRect:self.frame afterScreenUpdates:false];
    } else {
        //ios7以下
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *screenShotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //可以选择压缩下图片
    NSData *imageData = UIImageJPEGRepresentation(screenShotImage, 0.7);
    screenShotImage = [UIImage imageWithData:imageData];
    return screenShotImage;
}

@end
