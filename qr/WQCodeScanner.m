//
//  WQCodeScanner.m
//  CodeScanner
//
//  Created by wangyuxiang on 2017/3/27.
//  Copyright © 2017年 wangyuxiang. All rights reserved.
//

#import "WQCodeScanner.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "farwolf.h"
@interface WQCodeScanner ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, assign) BOOL isReading;

@property (nonatomic, assign) UIStatusBarStyle originStatusBarStyle;

@property (nonatomic, strong) UIImageView *lineImageView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) UIView *scanView;
@property (nonatomic, strong) UIView *camera;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;


@end

@implementation WQCodeScanner

- (id)init {
    self = [super init];
    if (self) {
        self.scanType = WQCodeScannerTypeAll;
    }
    return self;
}

- (void)dealloc {
    _session = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadCustomView];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (granted) {
                [self loadScanView];
              
                [self startRunning];
            } else {
                NSString *title = @"请在iPhone的”设置-隐私-相机“选项中，允许App访问你的相机";
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
                [alertView show];
            }
            
        });
    }];
    //判断权限
  
}
-(void)scan{
    [self startRunning];
}

-(void)stop{
     [self stopRunning];
}
- (CGRect)rectOfInterestByScanViewRect:(CGRect)rect {
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    CGFloat x = rect.origin.y/ height;
    CGFloat y = rect.origin.x/ width;
    
    CGFloat w = CGRectGetHeight(rect) / height;
    CGFloat h = CGRectGetWidth(rect) / width;
    
    return CGRectMake(x, y, w, h);
}

- (CGRect)coverToMetadataOutputRectOfInterestForRect:(CGRect)cropRect pre:(AVCaptureVideoPreviewLayer*)layer {
    CGSize size = layer.bounds.size;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 0.0;
 
    if ([_session.sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080]) {
        p2 = 1920./1080.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPreset352x288]) {
        p2 = 352./288.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPreset1280x720]) {
        p2 = 1280./720.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPresetiFrame960x540]) {
        p2 = 960./540.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPresetiFrame1280x720]) {
        p2 = 1280./720.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPresetHigh]) {
        p2 = 1920./1080.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPresetMedium]) {
        p2 = 480./360.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPresetLow]) {
        p2 = 192./144.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) { // 暂时未查到具体分辨率，但是可以推导出分辨率的比例为4/3
        p2 = 4./3.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPresetInputPriority]) {
        p2 = 1920./1080.;
    }
    else if (@available(iOS 9.0, *)) {
        if ([_session.sessionPreset isEqualToString:AVCaptureSessionPreset3840x2160]) {
            p2 = 3840./2160.;
        }
    } else {
        
    }
    if ([layer.videoGravity isEqualToString:AVLayerVideoGravityResize]) {
      return  CGRectMake((cropRect.origin.y)/size.height,(size.width-(cropRect.size.width+cropRect.origin.x))/size.width, cropRect.size.height/size.height,cropRect.size.width/size.width);
    } else if ([layer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (p1 < p2) {
            CGFloat fixHeight = size.width * p2;
            CGFloat fixPadding = (fixHeight - size.height)/2;
             return CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                        (size.width-(cropRect.size.width+cropRect.origin.x))/size.width,
                                                        cropRect.size.height/fixHeight,
                                                        cropRect.size.width/size.width);
        } else {
            CGFloat fixWidth = size.height * (1/p2);
            CGFloat fixPadding = (fixWidth - size.width)/2;
           return CGRectMake(cropRect.origin.y/size.height,
                                                        (size.width-(cropRect.size.width+cropRect.origin.x)+fixPadding)/fixWidth,
                                                        cropRect.size.height/size.height,
                                                        cropRect.size.width/fixWidth);
        }
    } else if ([layer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (p1 > p2) {
            CGFloat fixHeight = size.width * p2;
            CGFloat fixPadding = (fixHeight - size.height)/2;
          return CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                        (size.width-(cropRect.size.width+cropRect.origin.x))/size.width,
                                                        cropRect.size.height/fixHeight,
                                                        cropRect.size.width/size.width);
        } else {
            CGFloat fixWidth = size.height * (1/p2);
            CGFloat fixPadding = (fixWidth - size.width)/2;
            return CGRectMake(cropRect.origin.y/size.height,
                                                        (size.width-(cropRect.size.width+cropRect.origin.x)+fixPadding)/fixWidth,
                                                        cropRect.size.height/size.height,
                                                        cropRect.size.width/fixWidth);
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    NSString *codeStr = @"";
    switch (_scanType) {
        case WQCodeScannerTypeAll: codeStr = @"二维码/条码"; break;
        case WQCodeScannerTypeQRCode: codeStr = @"二维码"; break;
        case WQCodeScannerTypeBarcode: codeStr = @"条码"; break;
        default: break;
    }
    
    //title
    if (self.titleStr && self.titleStr.length > 0) {
        self.titleLabel.text = self.titleStr;
    } else {
        self.titleLabel.text = codeStr;
    }
    
    //tip
    if (self.tipStr && self.tipStr.length > 0) {
        self.tipLabel.text = self.tipStr;
    } else {
        self.tipLabel.text= [NSString stringWithFormat:@"将%@放入框内，即可自动扫描", codeStr];
    }

    [self startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:self.originStatusBarStyle animated:YES];
    
    [self stopRunning];
    
    [super viewWillDisappear:animated];
}

- (void)loadScanView {
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.output=output;
    //初始化链接对象
    self.session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self.session addInput:input];
    [self.session addOutput:output];
    //设置扫码支持的编码格式
    switch (self.scanType) {
        case WQCodeScannerTypeAll:
            output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,
                                         AVMetadataObjectTypeEAN13Code,
                                         AVMetadataObjectTypeEAN8Code,
                                         AVMetadataObjectTypeUPCECode,
                                         AVMetadataObjectTypeCode39Code,
                                         AVMetadataObjectTypeCode39Mod43Code,
                                         AVMetadataObjectTypeCode93Code,
                                         AVMetadataObjectTypeCode128Code,
                                         AVMetadataObjectTypePDF417Code];
            break;
            
        case WQCodeScannerTypeQRCode:
            output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode];
            break;
            
        case WQCodeScannerTypeBarcode:
            output.metadataObjectTypes=@[AVMetadataObjectTypeEAN13Code,
                                         AVMetadataObjectTypeEAN8Code,
                                         AVMetadataObjectTypeUPCECode,
                                         AVMetadataObjectTypeCode39Code,
                                         AVMetadataObjectTypeCode39Mod43Code,
                                         AVMetadataObjectTypeCode93Code,
                                         AVMetadataObjectTypeCode128Code,
                                         AVMetadataObjectTypePDF417Code];
            break;

        default:
            break;
    }
    
 
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _layer=layer;
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    CGRect frame= self.scanView.frame;
    CGRect rect=  [_layer metadataOutputRectOfInterestForRect:frame];
    [_output setRectOfInterest:rect];
    [self.camera.layer insertSublayer:layer atIndex:0];
}

- (void)loadCustomView {
    self.view.backgroundColor = [UIColor blackColor];
    _scanView=[UIView new];
//    _scanView.backgroundColor=[UIColor redColor];;
    [self.view addSubview:_scanView];
    __weak typeof (self)weakself=self;
    [_scanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(250.0));
        make.height.equalTo(@(250.0));
        make.center.equalTo(weakself.view);
    }];
    _camera=[UIView new];
    [self.view addSubview:_camera];
  
    [_camera mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakself.view);
    }];
      [self.view bringSubviewToFront:self.scanView];
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        CGRect frame= strongSelf.scanView.frame;
        CGRect rect=  [_layer metadataOutputRectOfInterestForRect:frame];
        [_output setRectOfInterest:rect];
    }];
}


-(void)setScanArea:(CGFloat)width height:(CGFloat)height color:(NSString*)color alph:(CGFloat)alph{
     _scanView.backgroundColor=[color toColor:alph];
//    _scanView.backgroundColor=[color toColor];
     __weak typeof (self)weakself=self;
    [_scanView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(width));
        make.height.equalTo(@(height));
        make.center.equalTo(weakself.view);
//        CGRect rect= [self coverToMetadataOutputRectOfInterestForRect:self.scanView.frame pre:_layer];
         CGRect frame= self.scanView.frame;
         CGRect rect=  [_layer metadataOutputRectOfInterestForRect:frame];
        [_output setRectOfInterest:rect];
//         [_output setRectOfInterest:[weakself rectOfInterestByScanViewRect:weakself.scanView.frame]];
    }];
}

- (void)startRunning {
    if (self.session) {
        _isReading = YES;
        
        [self.session startRunning];
        
        _timer=[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(moveUpAndDownLine) userInfo:nil repeats: YES];
    }
}

- (void)stopRunning {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil ;
    }
    
    [self.session stopRunning];
}

- (void)pressBackButton {
    UINavigationController *nvc = self.navigationController;
    if (nvc) {
        if (nvc.viewControllers.count == 1) {
            [nvc dismissViewControllerAnimated:YES completion:nil];
        } else {
            [nvc popViewControllerAnimated:NO];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


//二维码的横线移动
- (void)moveUpAndDownLine {
    CGFloat Y = self.lineImageView.frame.origin.y;
    if (_height + self.lineImageView.frame.size.width - 5 == Y) {
        [UIView beginAnimations: @"asa" context:nil];
        [UIView setAnimationDuration:1.5];
        CGRect frame = self.lineImageView.frame;
        frame.origin.y = _height;
        self.lineImageView.frame = frame;
        [UIView commitAnimations];
    } else if (_height == Y){
        [UIView beginAnimations: @"asa" context:nil];
        [UIView setAnimationDuration:1.5];
        CGRect frame = self.lineImageView.frame;
        frame.origin.y = _height + self.lineImageView.frame.size.width - 5;
        self.lineImageView.frame = frame;
        [UIView commitAnimations];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (!_isReading) {
        return;
    }
    if (metadataObjects.count > 0) {
        _isReading = NO;
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        NSString *result = metadataObject.stringValue;
        
        if (self.resultBlock) {
            self.resultBlock(result?:@"");
        }
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.isReading=true;
        });
//        [self pressBackButton];
    }
}

@end
