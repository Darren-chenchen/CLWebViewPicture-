//
//  ViewController.m
//  CLWebViewPicture
//
//  Created by darren on 16/8/26.
//  Copyright © 2016年 shanku. All rights reserved.
//

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#import "ViewController.h"
#import "CLWebPicture.h"

@interface ViewController ()
@property (nonatomic,strong) UIWebView *webView;

@property (nonatomic,strong) UIView *bgview;
@property (nonatomic,strong) UIImageView *imgView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *url = [NSURL URLWithString:@"http://dantang.liwushuo.com/posts/3121/content"];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.webView setScalesPageToFit:YES];
    [self.view addSubview:self.webView];
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    [self.webView sizeToFit];
    [self.view addSubview:self.webView];
    
    //  把CLWebPicture拖入项目中，实现这句代码
    self.webView.delegate = [CLWebPicture sharedCLWebPicture];
}
@end
