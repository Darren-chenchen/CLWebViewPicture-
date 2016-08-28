//
//  CLWebPicture.m
//  CLWebViewPicture
//
//  Created by darren on 16/8/26.
//  Copyright © 2016年 shanku. All rights reserved.
//
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#import "CLWebPicture.h"

@interface CLWebPicture()

@property (nonatomic,strong) UIView *bgview;
@property (nonatomic,strong) UIImageView *imgView;

@end

@implementation CLWebPicture

+ (CLWebPicture *)sharedCLWebPicture
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CLWebPicture alloc] init];
    });
    
    return sharedInstance;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //调整字号
    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '95%'";
    [webView stringByEvaluatingJavaScriptFromString:str];
    //js方法遍历图片添加点击事件 返回图片个数
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    for(var i=0;i<objs.length;i++){\
    objs[i].onclick=function(){\
    document.location=\"myweb:imageClick:\"+this.src;\
    };\
    };\
    return objs.length;\
    };";
    
    [webView stringByEvaluatingJavaScriptFromString:jsGetImages];//注入js方法
    NSString *resurlt = [webView stringByEvaluatingJavaScriptFromString:@"getImages()"];
    NSLog(@"---调用js方法--%@  %s  jsMehtods_result = %@",self.class,__func__,resurlt);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //将url转换为string
    NSString *requestString = [[request URL] absoluteString];
    //hasPrefix 判断创建的字符串内容是否以pic:字符开始
    if ([requestString hasPrefix:@"myweb:imageClick:"]) {
        NSString *imageUrl = [requestString substringFromIndex:@"myweb:imageClick:".length];
        if (self.bgview) {
            //设置不隐藏，还原放大缩小，显示图片
            self.bgview.hidden = NO;
            self.bgview.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            [self.imgView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]]];
            self.imgView.contentMode = UIViewContentModeScaleAspectFit;
        } else
            [self showBigImage:imageUrl];//创建视图并显示图片
        return NO;
    }
    return YES;
}
#pragma mark 显示大图片
- (void)showBigImage:(NSString *)imageUrl{
    //创建灰色透明背景，使其背后内容不可操作
    self.bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.bgview setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.9]];
    [[UIApplication sharedApplication].keyWindow addSubview:self.bgview];
    
    //创建边框视图
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,kScreenWidth, kScreenHeight)];
    [borderView setCenter:self.bgview.center];
    [self.bgview addSubview:borderView];
    //创建关闭按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(removeBigImage) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setFrame:CGRectMake(kScreenWidth-50, 25, 25, 25)];
    [self.bgview addSubview:closeBtn];
    //创建显示图像视图
    self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, kScreenHeight-80)];
    self.imgView.userInteractionEnabled = YES;
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.imgView.clipsToBounds  =YES;
    [self.imgView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]]];
    [borderView addSubview:self.imgView];
    
    //添加捏合手势
    [self.imgView addGestureRecognizer:[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)]];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(clickPan:)];
    [self.imgView addGestureRecognizer:panGesture];
}
- (void)clickPan:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self.imgView];
    self.imgView.transform = CGAffineTransformTranslate(self.imgView.transform, point.x, point.y);
    [pan setTranslation:CGPointZero inView:self.imgView];
}
- (void)removeBigImage
{
    self.bgview.hidden = YES;
}

- (void)handlePinch:(UIPinchGestureRecognizer*) recognizer
{
    //缩放:设置缩放比例
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

@end
