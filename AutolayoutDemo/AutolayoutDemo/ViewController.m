//
//  ViewController.m
//  AutolayoutDemo
//
//  Created by Binfeng Peng - Vendor on 2019/2/25.
//  Copyright © 2019年 Binfeng Peng - Vendor. All rights reserved.
//

#import "ViewController.h"
#import "VersionManager.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [VersionManager isAppstoreVersionUpdate:@"414478124" versionBlock:^(BOOL isUpdate) {
        NSLog(@"isUpdate:%d", isUpdate);
        if (isUpdate) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"app更新了" message:@"app有新版更新，是否更新？" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"点击取消");
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [VersionManager jumpToAppStoreApp:@"itms-apps://itunes.apple.com/cn/app//id414478124?mt=8"];
            }]];
            // 由于它是一个控制器 直接modal出来就好了
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    }];
    
    /*
     + (instancetype)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c;

     这个方法创建了一个约束对象，这个约束对象定义了View1的attribute1属性和View2的attribute2属性之间的关系。他们之间有这样的一个线性等式的关系：
     item1.attribute1 = multiplier × item2.attribute2 + constant
     
     view1
     就是约束左边的视图，也就是上面核心等式中的item1
     
     attr1
     上面核心等式左边的视图的属性，它是NSLayoutAttribute的枚举类型。
     NSLayoutAttribute：
     
     relation
     relation指的是左边的约束和右边的约束之间的关系，左边和右边的云总共有三种关系，即=，>=,<=。所以relation也是一个枚举值：
     
     view2
     约束右边的视图
     
     attr2
     约束右边的视图的属性，和attr1一样是枚举值。
     
     multiplier
     这个就是上面的核心等式中的multiplier，就是乘的倍数。
     
     c
     就是乘的倍数后面加上的一个常量
     */
    
    // 1.example 1
    [self exampleOne];
    
    // 2.example 2
    [self exampleTwo];
    
    /*
     VFL语言
     VFL全称是Visual Format Language，翻译过来是“可视化格式语言”
     VFL是苹果公司为了简化Autolayout的编码而推出的抽象语言
     VFL语法：
     H
     水平方向的约束
     
     V:
     垂直方向的约束
     
     |
     边界
     
     []
     方括号里面是视图
     
     ()
     圆括号里面是数值
     
     == , >=,<=
     表示数值的大小关系
     
     实例：
     
     H:|-50-[button]-50-|
     表达的就是button这个控件距离左边界的距离是50，距离右边界的距离是50。
     2.H:|-20-[button(50)]
     表示button这个控件距离左边界的距离是20且button宽度是50。
     3.V:[button(40)]-20-|
     表示button这个控件的高度是40，且其距离下边界的距离是20
     4.V:[redview]-[yellowview(==redview)]
     在垂直方向上，首先有一个视图redview，然后在其下方，紧挨着有一个视图yellowview，并且redview和yellowview的高度一致
     
     使用VFL来创建约束数组
     在第二部分代码实现AutoLayout中提到过NSLayoutConstraint类创建具体的约束对象有两种方法，在那部分我们只讲了第一种方法，还有第二种方法我们没有讲。
     第二种方法就是：
     
     + (NSArray *)constraintsWithVisualFormat:(NSString *)format options:(NSLayoutFormatOptions)opts metrics:(NSDictionary *)metrics views:(NSDictionary *)views;
     这种方法就是使用VFL语法来创建一组约束对象。这个方法返回的是一个数组，这个数组中的对象都是NSLayoutConstraint类的实例对象。
     format
     VFL描述语句
     
     opts
     它是NSLayoutFormatOptions的枚举值
     
     比如说现在的VFL语句是@"H:|-50-[redview]-20-[blueview(==redview)]-50-|",而NSLayoutFormatOptions枚举类型是NSLayoutFormatAlignAllCenterY,那么表达的意思就是在水平方向上redview距离左边界是50，blueview距离右边界是50，redview和blueview之间的水平距离是20，redview和blueview的宽度相等，并且，redview和blueview的垂直高度一致。opts在这里的作用就是添加一个约束。
     metrics
     这是一个字典类型的参数，这个字典的键必须是出现在VFL语句中的常量字符串，而值则是我们想要这个常量字符串想要代表的值。
     
     views
     这是一个字典类型，表示VFL语句中用到的控件。比如说我们在VFL语句中为了简便起见，使用rv代表_redview,使用bv代表_blueview，那么views可以这样写：@{@"rv":_redview,@"bv":_blueview}
     */
    [self exampleThree];
    [self exampleFour];
}

/*
 1.创建一个红色的视图和一个蓝色的视图
 红色视图和蓝色视图等宽，为100
 红色视图和蓝色视图等高，为50
 红色视图和蓝色视图在同一水平线上，红色视图在前，红色视图距离左边界为50，蓝色视图距离右边界为50
 红色视图和蓝色视图在垂直方向上距离边界的距离都是50。
 */
- (void)exampleOne {
    UIView *redView = [[UIView alloc] init];
    redView.backgroundColor = [UIColor redColor];
    redView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *blueView = [[UIView alloc] init];
    blueView.backgroundColor = [UIColor blueColor];
    blueView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:redView];
    [self.view addSubview:blueView];
    //redview在垂直方向上距离边界为100
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:redView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:100];
    
    //设置redview的宽
    NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:redView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1
                                                                    constant:100];
    
    //设置redview的高
    NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:redView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1
                                                                    constant:50];
    
    //设置blueview在垂直高度上和redview等高
    NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:blueView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:redView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1
                                                                   constant:0];
    
    //设置blueview和redview等宽
    NSLayoutConstraint *constraint5 = [NSLayoutConstraint constraintWithItem:blueView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:redView
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1
                                                                    constant:0];
    
    //设置blueview和redview等高
    NSLayoutConstraint *constraint6 = [NSLayoutConstraint constraintWithItem:blueView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:redView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1
                                                                   constant:0];
    
    //redview距离左边界为50
    NSLayoutConstraint *constraint7 = [NSLayoutConstraint constraintWithItem:redView
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1
                                                                    constant:50];
    
    //blueview距离右边界为50
    NSLayoutConstraint *constraint8 = [NSLayoutConstraint constraintWithItem:blueView
                                                                   attribute:NSLayoutAttributeTrailing
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeTrailing
                                                                  multiplier:1
                                                                    constant:-50];
    
    [self.view addConstraint:constraint1];
    [self.view addConstraint:constraint2];
    [self.view addConstraint:constraint3];
    [self.view addConstraint:constraint4];
    [self.view addConstraint:constraint5];
    [self.view addConstraint:constraint6];
    [self.view addConstraint:constraint7];
    [self.view addConstraint:constraint8];
}

/*
 2.创建一个红色视图和一个蓝色视图
 红色视图和蓝色视图的右边界对齐
 蓝色视图的宽度是红色视图的宽度的一半
 红色视图居中对齐
 红色视图在上，蓝色视图在下
 代码：
 */
- (void)exampleTwo {
    UIView *redView = [[UIView alloc] init];
    redView.backgroundColor = [UIColor redColor];
    redView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *blueView = [[UIView alloc] init];
    blueView.backgroundColor = [UIColor blueColor];
    blueView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:redView];
    [self.view addSubview:blueView];
    
    //redview在垂直方向上距离边界为200
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:redView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:200];
    //设置redview的宽
    NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:redView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1
                                                                    constant:200];
    //设置redview的高
    NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:redView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1
                                                                    constant:50];
    //设置redview居中
    NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:redView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1
                                                                    constant:0];
    //设置blueview宽度是redview的0.5倍
    NSLayoutConstraint *constraint5 = [NSLayoutConstraint constraintWithItem:blueView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:redView
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:0.5
                                                                    constant:0];
    //设置blueview和redview等高
    NSLayoutConstraint *constraint6 = [NSLayoutConstraint constraintWithItem:blueView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:redView
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1
                                                                    constant:0];
    //redview和blueview的右边界对齐
    NSLayoutConstraint *constraint7 = [NSLayoutConstraint constraintWithItem:redView
                                                                   attribute:NSLayoutAttributeTrailing
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:blueView
                                                                   attribute:NSLayoutAttributeTrailing
                                                                  multiplier:1
                                                                    constant:0];
    //blueview顶部距离redview为50
    NSLayoutConstraint *constraint8 = [NSLayoutConstraint constraintWithItem:blueView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:redView
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1
                                                                    constant:50];
    
    [self.view addConstraint:constraint1];
    [self.view addConstraint:constraint2];
    [self.view addConstraint:constraint3];
    [self.view addConstraint:constraint4];
    [self.view addConstraint:constraint5];
    [self.view addConstraint:constraint6];
    [self.view addConstraint:constraint7];
    [self.view addConstraint:constraint8];
}

/*
 使用Demo
 1.创建一个红色的视图和一个蓝色的视图
 红色视图和蓝色视图等宽等高
 红色视图和蓝色视图在垂直高度上相等
 红色视图和蓝色视图之间的水平距离为20
 红色视图距离左边界的距离为50，蓝色视图距离右边界的距离为50
 代码：
 */
- (void)exampleThree {
    UIView *redView = [[UIView alloc] init];
    redView.backgroundColor = [UIColor redColor];
    redView.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *blueView = [[UIView alloc] init];
    blueView.backgroundColor = [UIColor blueColor];
    blueView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:redView];
    [self.view addSubview:blueView];
    //设置redview距离左边界为50，blueview距离右边界为50，redview和blueview之间的水平距离为20，且redview和blueview等宽，并且redview和blueview在垂直高度上等高，怎么样？是不是一次性约束了很多条件？
    NSString *vflString = @"H:|-50-[redview]-20-[blueView(==redview)]-50-|";
    NSArray *constaints1 = [NSLayoutConstraint constraintsWithVisualFormat:vflString
                                                                   options:NSLayoutFormatAlignAllCenterY
                                                                   metrics:nil
                                                                     views:@{@"redview": redView, @"blueView": blueView}];
    //垂直方向上，redView距离上边界为400，且redview的高度是80
    NSArray *constaints2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-400-[redview(80)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:@{@"redview":redView}];
    //设置redview和blueview的头部在同一高度
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:redView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:0
                                                                     toItem:blueView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1
                                                                   constant:0];
    
    [self.view addConstraints:constaints1];
    [self.view addConstraints:constaints2];
    [self.view addConstraint:constraint];
}

/*
 2.创建一个红色的视图和一个蓝色的视图
 红色视图和蓝色视图的右边界对齐
 红色视图的宽度是蓝色视图的两倍
 红色视图在水平方向上居中
 红色视图在蓝色视图的上面，红色视图和蓝色视图紧挨着
 代码：
 */
- (void)exampleFour {
    UIView *redView = [[UIView alloc] init];
    redView.backgroundColor = [UIColor redColor];
    redView.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *blueView = [[UIView alloc] init];
    blueView.backgroundColor = [UIColor blueColor];
    blueView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:redView];
    [self.view addSubview:blueView];
    //水平方向上，设置redview距离右边界为50，距离左边界为50
    NSArray *consts1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[redview]-50-|"
                                                               options:0
                                                               metrics:nil
                                                                 views:@{@"redview":redView}];
    
    //垂直方向上，redView距离上边界为500，且redview的高度是80，下面紧挨着blueview，且redview和blueview右边界对齐
    NSArray *consts2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-500-[redview(80)][blueview(==redview)]"
                                                               options:NSLayoutFormatAlignAllRight
                                                               metrics:nil
                                                                 views:@{@"redview": redView, @"blueview": blueView}];
    //设置blueview的宽是redview的一半
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:blueView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:redView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:0.5
                                                                   constant:0];
    [self.view addConstraints:consts1];
    [self.view addConstraints:consts2];
    [self.view addConstraint:constraint];
}

@end
