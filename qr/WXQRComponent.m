//
//  WXQRComponent.m
//  AFNetworking
//
//  Created by 郑江荣 on 2019/3/2.
//

#import "WXQRComponent.h"
#import "CCQrCode.h"
#import "farwolf.h"
#import "Weex.h"
#import <WeexPluginLoader/WeexPluginLoader.h>
WX_PlUGIN_EXPORT_COMPONENT(qr, WXQRComponent)

@implementation WXQRComponent
WX_EXPORT_METHOD(@selector(scan:))
WX_EXPORT_METHOD(@selector(stop))
WX_EXPORT_METHOD(@selector(setScanArea:))
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

-(void)setScanArea:(NSMutableDictionary*)dic{
    CGFloat width=100;
    CGFloat height=100;
     CGFloat alph=0.3;
    NSString *color=@"#000000";
    if([dic objectForKey:@"width"]){
        width=[@"" add: [dic objectForKey:@"width"]].floatValue;
    }
    if([dic objectForKey:@"height"]){
        height=[@"" add: [dic objectForKey:@"height"]].floatValue;
    }
    if([dic objectForKey:@"alph"]){
        alph=[@"" add: [dic objectForKey:@"alph"]].floatValue;
    }
    if([dic objectForKey:@"color"]){
        color=[@"" add: [dic objectForKey:@"color"]];
    }
    width=[Weex length:width instance:self.weexInstance ];
    height=[Weex length:height instance:self.weexInstance ];
    [_scanner setScanArea:width height:height color:color alph:alph];
    
}
-(void)stop{
//     CCQrCode *code=(CCQrCode*)self.view;
//      [code stopReading];
    
    [_scanner stop];
}

@end
