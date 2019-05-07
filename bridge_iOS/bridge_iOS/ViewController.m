//
//  ViewController.m
//  bridge_iOS
//
//  Created by Radish on 2019/5/6.
//  Copyright © 2019 Radish. All rights reserved.
//


#import <WebKit/WebKit.h>
#import <ReactiveCocoa.h>
#import <WKWebViewJavascriptBridge.h>
#import "ViewController.h"


#define KSCREEN_HEIGHT               [UIScreen mainScreen].bounds.size.height
#define KSCREEN_WIDTH                [UIScreen mainScreen].bounds.size.width
#define __WEAKSELF typeof(self) __weak wself = self;


@interface ViewController () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) UIProgressView *progressView;


@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self createWKWebView];
    [self createProgress];
    
    [self loadRequest:@"http://192.168.60.215:8080/#/home"];
    [self registerJSBridge];
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"radish",@"name",@"18",@"age",@"100",@"id", nil];
    [self sendToWebWithName:@"sendJsMessage" parameter:dic];
    
}


#pragma wkwebview 初始化

- (void)createWKWebView{
    // wkwebview的配置
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    config.preferences = [WKPreferences new];
    config.preferences.minimumFontSize = 10;
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
    // 创建wkwebview
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH, KSCREEN_HEIGHT) configuration:config];
    _webView.backgroundColor = _webView.scrollView.backgroundColor = [UIColor orangeColor];
    _webView.scrollView.showsVerticalScrollIndicator = _webView.scrollView.showsHorizontalScrollIndicator = NO;
    [_webView setOpaque:NO];
    [_webView sizeToFit];
    
    // 设置代理
    
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    // 是否弹性滚动
    _webView.scrollView.bounces = YES;
    
    [self.view addSubview:_webView];
}

// 加载网页路径
- (void)loadRequest:(NSString *)path {
    if ([path containsString:@"http"]) {
        // 加载http路径
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:path] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [_webView loadRequest:req];
    }
    else{
        // 加载本地文件
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        NSString *appHtml = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [_webView loadHTMLString:appHtml baseURL:baseURL];
    }
}


#pragma 顶部进度条
- (void)createProgress{
    //添加进度条
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressView.frame = CGRectMake(0, 0, KSCREEN_WIDTH, 3);
    // 设置进度条的色彩
    [_progressView setTrackTintColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0]];
    _progressView.progressTintColor = [UIColor redColor];
    [self.view addSubview:_progressView];
}

- (void)updateProgressView{
    [_progressView setAlpha:1.0f];
    BOOL animated = _webView.estimatedProgress > _progressView.progress;
    [_progressView setProgress:_webView.estimatedProgress animated:animated];
    
    if(_webView.estimatedProgress >= 1.0f) {
        [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.progressView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [self.progressView setProgress:0.0f animated:NO];
        }];
    }
}


#pragma mark iOS 与 web 交互方法

- (void)registerJSBridge{
    [WKWebViewJavascriptBridge enableLogging];
    //创建桥接
    _bridge = [WKWebViewJavascriptBridge bridgeForWebView:_webView];
    [_bridge setWebViewDelegate:self];
    
    // web 调用iOS 的方法
    [_bridge registerHandler:@"sendNavtiveMessage" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (data) {
            NSDictionary *orginData = [self dictionaryWithJsonString:data];
            // 根据方法名可以去调用iOS原生的方法
            NSString *funName = orginData[@"fun"];
            id params = orginData[@"data"];
            
        } else {
            NSLog(@"传递数据为空");
        }
//        responseCallback(@"iOS已经接收到JS发来的请求");
    }];
}

// iOS 调用 原生 JS方法
- (void)sendToWebWithName:(NSString *)name parameter:(id)parameter{
    NSString *json = nil;
    if ([parameter isKindOfClass:[NSDictionary class]]) {
        json = [self createJsonWithDic:parameter];
    } else{
        NSLog(@"传入的非字典类型 不需要转换 == %@  %@", NSStringFromClass([parameter class]), parameter);
        json = parameter;
    }
    // 发送过去的数据必须为json字符串
    [_bridge callHandler:name data:json responseCallback:^(id responseData) {
        NSLog(@"ObjC received response: %@", responseData);
    }];
}

// NSDictionary 和 NSString 互转换
- (NSString *)createJsonWithDic:(id)dict{
    if (!dict) {
        NSLog(@"不能传入空字典");
        return nil;
    }
    if ([dict isKindOfClass:[NSString class]]) {
        NSLog(@"已经是json字符串");
        return dict;
    }
    NSString *jsonString = nil;
    @try {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        if (jsonData && !error) {
            NSLog(@"字段转换json成功");
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        else{
            NSLog(@"字典转换json失败 %@", error);
        }
    } @catch (NSException *exception) {
        NSLog(@"字典转化json字符串出错");
    } @finally {
        //这里一定执行，无论你异常与否
        return jsonString;
    }
}

- (NSDictionary *)dictionaryWithJsonString:(id)jsonString{
    if (!jsonString) {
        NSLog(@"不能传入空json字符串");
        return nil;
    }
    if ([jsonString isKindOfClass:[NSDictionary class]]) {
        NSLog(@"已经是字典");
        return jsonString;
    }
    NSDictionary *dic = nil;
    @try {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if(err) {
            NSLog(@"json解析失败：%@",err);
        }
    } @catch (NSException *exception) {
        NSLog(@"字典转化json字符串出错");
    } @finally {
        //这里一定执行，无论你异常与否
        return dic;
    }
}




#pragma mark - wkwebview代理方法。基本上没啥卵用

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"alert 提示框内容 === %@ ===", [message stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    completionHandler();
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    //这里可以通过name 进行js和oc的交互。使用 WebViewJavascriptBridge 组件就不需要在这里做监听
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSLog(@"在发送请求之前，决定是否跳转");
    decisionHandler(WKNavigationActionPolicyAllow);
    
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSLog(@"在响应完成时，调用的方法。如果设置为不允许响应，web内容就不会传过来");
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"接收到服务器跳转请求之后调用");
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"开始加载");
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"开始返回");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    //设置标题
    if (self.title.length == 0 && webView.title.length > 0) {
        self.title = webView.title;
    }
    NSLog(@"加载完成");
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"加载失败");
}



@end
