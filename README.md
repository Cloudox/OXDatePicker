# OXDatePicker
传入指定时间戳数组，只显示指定的月份、日期、上午/下午


## 引
因为项目特殊的需求，需要根据时间戳数组来解析出月份、日期、上午/下午，并组装显示，因此直接做了个小组件，这个需求太特殊了，我想也不太可能有太多通用性，不过做的比较易用，在不连续的时间戳显示上还是可以拿来用的，只需要自己变一变显示就好了，我是直接把时间戳分成上午/下午来显示了，要显示具体的时间也很好改。

效果如下：

![](https://github.com/Cloudox/OXDatePicker/blob/master/demo.png)

## 用法&说明

只需要把工程中的OXDatePickerView类两个文件添加到你的工程，然后在需要的界面import，就可以通过下面几行代码来使用了。

```objective-c
/**
 按钮响应
 */
- (void)onClick {
    OXDatePickerView *pickerView = [[OXDatePickerView alloc] initWithDefaultDate:1499040000 dateArray:[NSMutableArray arrayWithArray:@[[NSNumber numberWithLong: 1499040000], [NSNumber numberWithLong:1499522400], [NSNumber numberWithLong:1499123200], [NSNumber numberWithLong:1499020000], [NSNumber numberWithLong:1498816800], [NSNumber numberWithLong:1499162400], [NSNumber numberWithLong:1498744800]]]];
    pickerView.delegate = self;
    [self.view addSubview:pickerView];
}

#pragma mark - OXDatePickerViewDelegate
- (void)choosedDate:(long)date {
    NSLog(@"选择：%ld", date);
    self.label.text = [NSString stringWithFormat:@"入院日期：%ld", date];
}
```

用法很简单，初始化时需要传入两个参数，一个是默认一开始显示的日期时间，另一个是可供选择的时间戳的数组，注意时间戳是long型的，但是转化成了NSNumber好添加进数组。

选择时间确定后通过Delegate回传数据，也是一个long型的时间戳。

如果你的系统也是通过时间戳来与后台交互，那就很方便了。

通过数组穿进去的时间戳不需要是连续的，甚至不需要是顺序的，我的类会先排一次序，然后把时间戳分月份、日期组装好再显示，所用的时间戳是UTC标准时间戳，不是中国的时区，要改的话可以自己改一下。

此外我会把0~12点的时间戳都归为上午，12~24点的时间戳都归为下午，要显示具体小时的话也可以自己改了。

里面最绕的部分是日期的分类组装，我都处理好了。

弹出日期选取器时会有一个从底部上移的弹出效果，收起的时候也有一个往下移的弹回效果，很类似于标准库的日期选取器。

收起后会把选取器置为nil，节省内存。

## 结
如引言所说，这个通用性不强，但是解决了时间戳-->日期的问题、日期排序的问题、不连续日期的问题等，有些需求变化的话也可以通过简单的修改来达到目的，整个组件很简单清爽，也比较易用啦。

