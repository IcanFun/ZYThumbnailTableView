# ZYThumbnailTableView
#####首先感谢liuzhiyi1992的分享，工作需要用到这个效果，但公司的项目都是用OC，所以抽空将liuzhiyi1992的项目翻译成了OC，附上原地址
[swift项目](https://github.com/liuzhiyi1992/ZYThumbnailTableView)
#####可展开型预览TableView，开放接口，完全自由定制
#####An expandable preview TableView, custom-made all the modules completely with open API you can.  
######Design by [Sergii Ganushchak](https://dribbble.com/shots/2261899-3D-Touch-Preview) 
![](https://img.shields.io/badge/pod-v0.5.1-blue.svg)
![](https://img.shields.io/badge/objc-expect-red.svg)
![](https://img.shields.io/badge/swift-perfect-green.svg)
![](https://img.shields.io/badge/Supporting-iOS7.1+-orange.svg)
![](https://img.shields.io/badge/build-passing-brightgreen.svg)
![](https://img.shields.io/badge/license-MIT-brightgreen.svg)  
<br>

a TableView have thumbnail cell only, and you can use gesture let it expands other expansionView, all DIY  
高度自由定制可扩展TableView, 其中tableViewCell，topExpansionView，bottomExpansionView均提供接口自由定制，功能堪比小型阅读app

![](https://raw.githubusercontent.com/liuzhiyi1992/MyStore/master/ZYThumbnailTableView/ZYThumbnailTableView%E6%BC%94%E7%A4%BAgif2.gif)   


##Summary:  
tableView的皮肤，类似一个小型app的强大交互心脏，四肢高度解耦高度自由定制，每个cell其实都是一个业务的缩略view，原谅我语文不太好不懂表达，这样的缩略view下文就叫做thumbnailView，可以根据上下手势展开更多的功能视图块，这些视图块已经开放了接口，支持使用者自己diy提供创建，同时接口中带的参数基本满足使用者需要的交互，当然tableviewCell也是完全自由diy的

- 工作特点：tableViewCell充当一个缩略内容的容器，初始内容展示局限于cellHeight，当cell被点击后，根据缩略view内容重新计算出完整的高度，装入另外一个容器中完整展示出来，并且可以上下拖拽扩展出上下功能视图。  

- 自由定制：看见的除了功能以外，全部视图都开放接口灵活Diy，tableViewCell，头部扩展视图(topView)，底部扩展视图(bottomView)都是自己提供。  

- 使用简单：只需要把自己的tableViewCell，topView，bottomView配置给ZYThumbnailTableViewController对象。  


<br>  

<br>
##Usage:  
------结合[Demo](https://github.com/ICANFUN/ZYThumbnailTableView)介绍使用方法，手把手定制自己的ThumbnailTableView：  
创建ZYThumbnailTableViewController对象：  
```oc
zyThumbnailTableVC = [[ZYThumbnailTableViewController alloc] init]
```  
<br>
配置tableViewCell必须的参数：cell高，cell的重用标志符，tableView的数据源等
```oc
zyThumbnailTableVC.tableViewCellReuseId = "DIYTableViewCell"
zyThumbnailTableVC.tableViewCellHeight = 100.0
//当然cell高可以在任何时候动态配置
zyThumbnailTableVC.tableViewDataList = dataList
```  
<br>
接下来给ZYTableView配置你自己的tableViewCell，当然除了createCell外还可以在里面进行其他额外的操作，不过这个Block只会在需要生成cell的时候被调用，而重用cell并不会
```oc
//--------insert your diy tableview cell
zyThumbnailTableVC.configureTableViewCellBlock = {
return [[DIYTableViewCell alloc] creatCell];
}
```  
<br>
配置cell的update方法，tableView配置每个cell必经之处，除了updateCell可以添加额外的操作。这里要注意updateCell的时候建议尽量使用zyThumbnailTableVC对象里的数据源datalist,同时要注意时刻保证VC对象里的数据源为最新，接口回调更改数据源时不要忘了对zyThumbnailTableVC.tableViewDataList的更新。
```oc
zyThumbnailTableVC.updateTableViewCellBlock =  ^(UITableViewCell* cell, NSIndexPath *indexPath){
DIYTableViewCell *myCell = (DIYTableViewCell*)cell;

//Post is my data model
Post *dataSource = weak_zyThumbnailTableVC.tableViewDataList[indexPath.row];
if (dataSource) {
[myCell updateCell:dataSource];
}
};
```  
<br>
配置你自己的顶部扩展视图 & 底部扩展视图（expansionView）  
- 两个Block均提供indexPath参数，只是因为我的BottomView的业务暂时不需要识别对应的是哪个cell，所以使用时把参数省略掉了。  
- 这里还有一个对zyThumbnailTableVC.keyboardAdaptiveView的赋值，是因为我的BottomView中包含有TextField，正如上文所说，```ZYKeyboardUtil```会自动帮我处理键盘遮挡事件。(==注意==：赋值给keyboardAdaptiveView的和我往Block里送的是同一个对象)
```oc
//--------insert your diy TopView
zyThumbnailTableVC.createTopExpansionViewBlock = ^(NSIndexPath* indexPath){
Post *post = weak_zyThumbnailTableVC.tableViewDataList[indexPath.row]; //post是原版数据demo
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
```  
<br>
结合[ZYKeyboardUtil](https://github.com/liuzhiyi1992/ZYKeyboardUtil)工作的效果:  

![](https://raw.githubusercontent.com/liuzhiyi1992/MyStore/master/ZYThumbnailTableView/ZYThumbnailTableView%E9%85%8D%E5%90%88ZYKeyboardUtil%E6%BC%94%E7%A4%BAgif.gif)  

<br>
就这样，属于你自己的thumbnailtableView就完成了。展开，关闭，基本功能上都能使用，但是如果在topView，bottomView中有什么交互功能之类的，就要在自己的头部尾部扩展控件和自定义的tableViewCell里面完成了，ZYThumbnailTableView提供cell的```indexPath```贯通三者通讯交流。  

<br>
回看下Demo中的交互是怎样利用```indexPath```的：  
![](https://raw.githubusercontent.com/liuzhiyi1992/MyStore/master/ZYThumbnailTableView/zyTableView%E4%B8%A4%E4%B8%AA%E4%BA%A4%E4%BA%92%E6%BC%94%E7%A4%BAgif.gif)  

- 标记为已读后，小圆点会消失  
- 标识为喜欢后，会在对应的cell旁边出现一个星星  

createView的时候我将从createTopExpansionViewBlock参数中得到的indexPath储存在我的topView对象中，当favorite按钮被点击时就可以indexPath为凭据利用代理改变对应数据源里的对应状态，同时在下次createView时根据indexPath取得对应的数据源来显示。如果这些交互会更新一些与cell相关的数据，还可以在代理方法中调用```[zyThumbnailTableVC reloadMainTableView]```让tableView重新加载一遍。
```oc
//TopView---------------------------------------------
- (instancetype)creatView:(NSIndexPath*)indexpath Post:(Post*)post
{
TopView *view = [[[NSBundle mainBundle] loadNibNamed:@"TopView" owner:nil options:nil] firstObject];
view->indexPath = indexpath;
//--------do something

return view;
}

//touch up inside---------------------------------------------
- (IBAction)clickFavoriteButton:(UIButton*)sender {
//--------do something
[delegate topViewDidClickFavoriteBtn:self];
}

//代理方法---------------------------------------------
- (void)topViewDidClickFavoriteBtn:(TopView *)topView
{
Post *post = zyThumbnailTableVC.tableViewDataList[topView.indexPath.row];//post是原版数据demo
post.favorite = !post.favorite;
[zyThumbnailTableVC reloadMainTableView];
}
```  
<br>


<br>
##profile:  
**Block:**  
typedef UITableViewCell* (^ConfigureTableViewCellBlock)();
typedef void (^UpdateTableViewCellBlock)(UITableViewCell*,NSIndexPath*);
typedef UIView* (^CreateTopExpansionViewBlock)(NSIndexPath*);
typedef UIView* (^CreateBottomExpansionViewBlock)(NSIndexPath*);  

**Define:**  
- NOTIFY_NAME_DISMISS_PREVIEW   
通知名(让展现出来的thumbnailView消失)  
- MARGIN_KEYBOARD_ADAPTATION    
自动处理键盘遮挡输入控件后，键盘与输入控件保持的间距（自动处理键盘遮挡事件使用[ZYKeyboardUtil](https://github.com/liuzhiyi1992/ZYKeyboardUtil)实现  
- TYPE_EXPANSION_VIEW_TOP  
处理展开抖动事件时，顶部扩展控件的标识  
- TYPE_EXPANSION_VIEW_BOTTOM  
处理展开抖动事件时，底部扩展控件的标识  

**Property:**  
开放：  
- tableViewCellHeight  
- tableViewDataList  
- tableViewCellReuseId  
- tableViewBackgroudColor
- keyboardAdaptiveView  你自定义控件里如果有希望不被键盘遮挡的输入控件，赋值给他，会帮你==自动处理遮盖事件==  

私有：  
- mainTableView  
- clickIndexPathRow  记录被点击cell的indexPath row  
- spreadCellHeight  存储thumbnailCell展开后的真实高度  
- cellDictionary  存储所有存活中的cell  
- thumbnailView  缩略view
- thumbnailViewCanPan  控制缩略view展开(扩展topView&buttomView)手势是否工作  
- animator  UI物理引擎控制者  
- expandAmplitude  view展开时抖动动作的振幅  
- keyboardUtil  自动处理键盘遮挡事件工具对象[ZYKeyboardUtil](https://github.com/liuzhiyi1992/ZYKeyboardUtil)  


**Delegate func:**  
- (void)zyTableViewDidSelectRow:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath


**对外会用到的func:**  
- (void)dismissPreview 
让thumbnailView消失，在TopView,BottomView等没有zyThumbnailTableView对象的地方可以使用通知NOTIFY_NAME_DISMISS_PREVIEW    
- (void)reloadMainTableView
重新加载tableView  


<br>
##Relation:  
[@ICANFUN](https://github.com/ICANFUN) on Github
<br>
[@liuzhiyi1992](https://github.com/liuzhiyi1992) on Github  

<br>
##License:  

<br>
有什么问题可以在github中提交issues交流，谢谢