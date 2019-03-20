//
//  MasonryViewController.m
//  AutolayoutDemo
//
//  Created by Binfeng Peng - Vendor on 2019/2/25.
//  Copyright © 2019年 Binfeng Peng - Vendor. All rights reserved.
//

#import "MasonryViewController.h"
#import "Masonry.h"

@interface MasonryViewController ()

@property (nonatomic, strong) UIView *yellowView;
@property (nonatomic, strong) UIView *blueView;
@property (nonatomic, strong) UIView *greenView;
@property (nonatomic, strong) UIView *redView;

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation MasonryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.初始化
    [self initUI];
    
    // 2.增加约束
    [self addConstraint];
    [self practice];
    [self practice2];
    [self practice3];
}

- (void)initUI
{
    self.yellowView = [[UIView alloc] init];
    self.yellowView.backgroundColor = [UIColor yellowColor];
    self.blueView = [[UIView alloc] init];
    self.blueView.backgroundColor = [UIColor blueColor];
    self.greenView = [[UIView alloc] init];
    self.greenView.backgroundColor = [UIColor greenColor];
    self.redView = [[UIView alloc] init];
    self.redView.backgroundColor = [UIColor redColor];
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.textColor = [UIColor blueColor];
    self.textLabel.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:self.yellowView];
    [self.view addSubview:self.blueView];
    [self.view addSubview:self.greenView];
    [self.view addSubview:self.redView];
    [self.view addSubview:self.textLabel];
}

- (void)addConstraint
{
    // 设置内边距
    /**
     设置yellow视图和self.view等大，并且有10的内边距。
     注意根据UIView的坐标系，下面right和bottom进行了取反。所以不能写成下面这样，否则right、bottom这两个方向会出现问题。
     make.edges.equalTo(self.view).with.offset(10);
     
     除了下面例子中的offset()方法，还有针对不同坐标系的centerOffset()、sizeOffset()、valueOffset()之类的方法。
     */
    [self.yellowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(10);
        make.top.equalTo(self.view).with.offset(10);
        make.right.equalTo(self.view).with.offset(-10);
        make.bottom.equalTo(self.view).with.offset(-10);
    }];
    
    // 通过insets简化设置内边距的方式
    /**
     下面的方法和上面例子等价，区别在于使用insets()方法。
     */
    [self.blueView mas_makeConstraints:^(MASConstraintMaker *make) {
        // 下、右不需要写负号，insets方法中已经为我们做了取反的操作了。
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(40, 40, 40, 40));
    }];
    
    // 更新约束
    // 设置greenView的center和size
    [self.greenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        // 这里通过mas_equalTo给size设置了基础数据类型的参数，参数为CGSize的结构体
        make.size.mas_equalTo(CGSizeMake(300, 300));
    }];
    
    // 为了更清楚的看出约束变化的效果，在显示两秒后更新约束。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 指定更新size，其他约束不变。
        [self.greenView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 100));
        }];
    });
    
    // 大于等于和小于等于某个值的约束
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        // 设置宽度小于等于200
        make.width.lessThanOrEqualTo(@200);
        // 设置高度大于等于10
        make.height.greaterThanOrEqualTo(@(10));
    }];
    self.textLabel.text = @"这是测试的字符串。能看到1、2、3个步骤，第一步当然是上传照片了，要上传正面近照哦。上传后，网站会自动识别你的面部，如果觉得识别的不准，你还可以手动修改一下。左边可以看到16项修改参数，最上面是整体修改，你也可以根据自己的意愿单独修改某项，将鼠标放到选项上面，右边的预览图会显示相应的位置。";
    
    //textLabel只需要设置一个属性即可
    self.textLabel.numberOfLines = 0;
    
    // 使用基础数据类型当做参数
    /**
     如果想使用基础数据类型当做参数，Masonry为我们提供了"mas_xx"格式的宏定义。
     这些宏定义会将传入的基础数据类型转换为NSNumber类型，这个过程叫做封箱(Auto Boxing)。
     
     "mas_xx"开头的宏定义，内部都是通过MASBoxValue()函数实现的。
     这样的宏定义主要有四个，分别是mas_equalTo()、mas_offset()和大于等于、小于等于四个。
     */
    [self.redView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view).centerOffset(CGPointMake(0, 200));
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(100);
    }];
    
    // 设置约束优先级
    /**
     Masonry为我们提供了三个默认的方法，priorityLow()、priorityMedium()、priorityHigh()，这三个方法内部对应着不同的默认优先级。
     除了这三个方法，我们也可以自己设置优先级的值，可以通过priority()方法来设置。
     
     Masonry也帮我们定义好了一些默认的优先级常量，分别对应着不同的数值，优先级最大数值是1000。
     static const MASLayoutPriority MASLayoutPriorityRequired = UILayoutPriorityRequired;
     static const MASLayoutPriority MASLayoutPriorityDefaultHigh = UILayoutPriorityDefaultHigh;
     static const MASLayoutPriority MASLayoutPriorityDefaultMedium = 500;
     static const MASLayoutPriority MASLayoutPriorityDefaultLow = UILayoutPriorityDefaultLow;
     static const MASLayoutPriority MASLayoutPriorityFittingSizeLevel = UILayoutPriorityFittingSizeLevel;
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.redView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view).centerOffset(CGPointMake(0, 200));
            make.width.equalTo(self.view).priorityLow();
            make.width.mas_equalTo(20).priorityHigh();
            make.height.equalTo(self.view).priority(200);
            make.height.mas_equalTo(100).priority(1000);
        }];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 设置约束比例
        // 设置当前约束值乘以多少，例如这个例子是redView的宽度是self.view宽度的0.2倍。
        [self.redView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view).centerOffset(CGPointMake(0, 200));
            make.height.mas_equalTo(30);
            make.width.equalTo(self.view).multipliedBy(0.2);
        }];
    });
}

/**
 子视图等高/等宽练习
 
 下面的例子是通过给equalTo()方法传入一个数组，设置数组中子视图及当前make对应的视图之间等高。
 
 需要注意的是，下面block中设置边距的时候，应该用insets来设置，而不是用offset。
 因为用offset设置right和bottom的边距时，这两个值应该是负数，所以如果通过offset来统一设置值会有问题。
 */
- (void)practice
{
    CGFloat padding = 10;
    UIView *redView = [[UIView alloc]init];
    redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:redView];
    
    UIView *blueView = [[UIView alloc]init];
    blueView.backgroundColor = [UIColor brownColor];
    [self.view addSubview:blueView];
    
    UIView *yellowView = [[UIView alloc]init];
    yellowView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:yellowView];
    
    /**********  等高   ***********/
    [redView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view).insets(UIEdgeInsetsMake(padding, padding, 0, padding));
        make.bottom.equalTo(blueView.mas_top).offset(-padding);
    }];
    [blueView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, padding, 0, padding));
        make.bottom.equalTo(yellowView.mas_top).offset(-padding);
    }];
    /**
     下面设置make.height的数组是关键，通过这个数组可以设置这三个视图高度相等。其他例如宽度之类的，也是类似的方式。
     */
    [yellowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view).insets(UIEdgeInsetsMake(0, padding, padding, padding));
        make.height.equalTo(@[redView, blueView]);
        
    }];
    
    
}

- (void)practice2
{
    CGFloat padding = 10;
    UIView *redView = [[UIView alloc]init];
    redView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:redView];
    
    UIView *blueView = [[UIView alloc]init];
    blueView.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:blueView];
    
    UIView *yellowView = [[UIView alloc]init];
    yellowView.backgroundColor = [UIColor brownColor];
    [self.view addSubview:yellowView];
    
    /**********  等宽   ***********/
    [redView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.view).insets(UIEdgeInsetsMake(padding, padding, padding, 0));
        make.right.equalTo(blueView.mas_left).offset(-padding);
    }];
    [blueView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.view).insets(UIEdgeInsetsMake(padding, 0, padding, 0));
        make.right.equalTo(yellowView.mas_left).offset(-padding);
    }];
    [yellowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.view).insets(UIEdgeInsetsMake(padding, 0, padding, padding));
        make.width.equalTo(@[redView, blueView]);
    }];
}

- (void)practice3
{
    CGFloat padding = 10;
    
    UIView *redView = [[UIView alloc]init];
    redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:redView];
    
    UIView *blueView = [[UIView alloc]init];
    blueView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:blueView];
    
    [redView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.left.equalTo(self.view).mas_offset(padding);
        make.right.equalTo(blueView.mas_left).mas_offset(-padding);
        //make.width.equalTo(blueView);
        make.height.mas_equalTo(150);
    }];
    
    [blueView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.right.equalTo(self.view).mas_offset(-padding);
        make.width.equalTo(redView);
        make.height.mas_equalTo(150);
    }];
}


@end
