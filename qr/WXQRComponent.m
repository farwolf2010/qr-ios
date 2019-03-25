//
//  WXQRComponent.m
//  AFNetworking
//
//  Created by 郑江荣 on 2019/3/2.
//

#import "WXQRComponent.h"
#import "CCQrCode.h"
#import "farwolf.h"

#import <WeexPluginLoader/WeexPluginLoader.h>
WX_PlUGIN_EXPORT_COMPONENT(qr, WXQRComponent)

@implementation WXQRComponent
WX_EXPORT_METHOD(@selector(scan:))
WX_EXPORT_METHOD(@selector(stop))
-(UIView*)loadView{
//    CCQrCode *code = [CCQrCode new];
//    code.empty=true;
    
    UIView *v=[UIView new];
    return v;
    
}

-(void)viewDidLoad
{
//    CCQrCode *code = [CCQrCode new];
    _scanner = [[WQCodeScanner alloc] init];
    [self.view addSubview:_scanner.view];
    [self.weexInstance.viewController addChildViewController:_scanner];
    __weak typeof (self) weakself=self;
    [_scanner.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakself.view);
    }];
}


-(void)scan:(WXModuleKeepAliveCallback)callback
{
//    CCQrCode *code=(CCQrCode*)self.view;
    __weak typeof (self) weakself=self;
    [_scanner scan];
//    [code startReading:^(AVCaptureOutput *captureOutput, NSArray *metadataObjects, AVCaptureConnection *connection, AVMetadataMachineReadableCodeObject *metadataObj, NSString *stringValue) {
//
//        callback(@{@"res":stringValue},true);
//        NSLog(@"%@",stringValue);
////        [code stopReading];
//    }];
    _scanner.resultBlock = ^(NSString *value) {
        callback(@{@"res":value},true);
    };
}


-(void)stop{
//     CCQrCode *code=(CCQrCode*)self.view;
//      [code stopReading];
    
    [_scanner stop];
}

@end
