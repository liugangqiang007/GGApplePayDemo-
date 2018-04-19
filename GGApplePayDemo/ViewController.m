//
//  ViewController.m
//  GGApplePayDemo
//
//  Created by LGQ on 16/2/23.
//  Copyright © 2016年 LGQ. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>

@interface ViewController ()<PKPaymentAuthorizationViewControllerDelegate>

@end

@implementation ViewController


/********   Apple pay 开发流程  *********/

/**
 
 一.配置环境
 
 1.注册一个 merchant ID
    打开苹果官方开发者平台https://developer.apple.com --> 
    Member Center --> 
    Certificates, Identifiers & Profiles -->
    (iOS Apps)Identifiers -->
    Merchant IDs --> 
    点击右上角"+"号按钮 -->
    填写 Description 和 ID(ID必须以 "merchant." 开头),之后单击Continue(继续),单击Register(注册)
 
 2.给注册好的 merchant ID 配置一个证书
    (1)生成CSR文件
        打开 Mac 的 钥匙串访问 --> 证书助理 --> 从证书颁发机构请求证书 -->
        填写"用户电子邮箱地址"和"常用名称"(这两个可以随便填,不影响代码运行,后果..不清楚 o(╯□╰)o), 
        选择"存储到磁盘",单击继续,把生成的文件保存到自己能找到的地方
    (2)配置 merchant ID,安装
        打开苹果官方开发者平台https://developer.apple.com -->
        Member Center -->
        Certificates, Identifiers & Profiles -->
        (iOS Apps)Identifiers -->
        Merchant IDs -->
        选择之前生成的 merchant ID, 单击 Edit(编辑) -->
        Are you processing your payments outside of the United States?,选择YES(如果不在美国以外的地区使用,选择NO),单击单击Continue(继续) -->
        单击Continue(继续),单击"Choose File",选择生成的CSR文件,单击Generate(生成) -->
        单击Download(下载),下载完成后,点击下载的文件,完成安装
 */

/**
 
 二.添加项目对 Apple Pay 的支持
 
 1.创建项目
 2.选择项目 -->
    点击 Capabilities -->
    打开 Apple Pay开关 -->
    勾选当初注册的 merchant ID
    (这时应该有三个灰色的小对勾"√")
 
*/

/**
 三.写代码,如下
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1 导入PassKit框架    #import <PassKit/PassKit.h>
    
    // 2.0 确认用户是否可以进行付款操作,如果设备能够使用pay,返回YES,反之NO.
    BOOL canPay = [PKPaymentAuthorizationViewController canMakePayments];
    
    if (canPay) {
        
        // 2.1 使用 PKPaymentSummaryItem 类创建商品信息的对象,每个对象都是一个商品信息的实例, 最后一个实例对象为汇总
        PKPaymentSummaryItem *good1 = [PKPaymentSummaryItem summaryItemWithLabel:@"HHKB professional2" amount:[NSDecimalNumber decimalNumberWithString:@"0.1"]];
        PKPaymentSummaryItem *good2 = [PKPaymentSummaryItem summaryItemWithLabel:@"ipad mini" amount:[NSDecimalNumber decimalNumberWithString:@"0.1"]];
        PKPaymentSummaryItem *good3 = [PKPaymentSummaryItem summaryItemWithLabel:@"三相之力 强化+1" amount:[NSDecimalNumber decimalNumberWithString:@"0.1"]];
        PKPaymentSummaryItem *totle = [PKPaymentSummaryItem summaryItemWithLabel:@"德玛西亚套装" amount:[NSDecimalNumber decimalNumberWithString:@"0.5"]];
        
        // 2.2 使用 PKPaymentRequest类创建一个支付请求,并设置属性
        PKPaymentRequest *requset = [[PKPaymentRequest alloc] init];
        // 商品类表,最后一个是总计
        requset.paymentSummaryItems = @[good1, good2, good3, totle];
        // iOS国家码,设置国家
        requset.countryCode = @"CN";
        // iOS货币单位码,设置货币单位
        requset.currencyCode = @"CNY";
        // Wallet绑定的卡的类型,例如visa,中国银联
        requset.supportedNetworks = @[PKPaymentNetworkMasterCard,
                                      PKPaymentNetworkVisa,
                                      PKPaymentNetworkChinaUnionPay];
        // 支付处理标准, 3ds(必须支持), 信用卡, 借记卡, emv
        requset.merchantCapabilities = PKMerchantCapability3DS | PKMerchantCapabilityCredit | PKMerchantCapabilityDebit;
        // 商业证书名称,必须跟添加的证书中的一个相同
        requset.merchantIdentifier = @"merchant.GGApplePay";
        // 账单邮寄信息,用于账单邮寄,可以设置: 无, 完整的地址, 电话, 邮箱, 名字.当设置之后,只有需要的账单地址存在,才能进行支付.
        requset.requiredBillingAddressFields = PKAddressFieldPostalAddress | PKAddressFieldPhone | PKAddressFieldEmail | PKAddressFieldName;
        // 配送信息,用于邮寄商品,可以设置: 无, 完整的地址, 电话, 邮箱, 名字.当设置之后,只有需要的信息存在,才能进行支付
        requset.requiredShippingAddressFields = PKAddressFieldPostalAddress | PKAddressFieldPhone | PKAddressFieldEmail | PKAddressFieldName;
        
        // 2.3 创建用来显示支付信息的控制器, modal出来
        PKPaymentAuthorizationViewController *paymentPane = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:requset];
        // 2.4 为支付控制器设置代理,有两个代理方法必须是现实
        paymentPane.delegate = self;
        [self presentViewController:paymentPane animated:YES completion:nil];
    }
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate

/**
 *  用户发送支付请求后会调用该方法,在这个方法中发送相关的支付信息到你的服务器,最后通过服务器来处理.
 *  如果处理成功,那么需要调用completion的block并传入PKPaymentAuthorizationStatusSuccess的标记即可.
 *  如果不成功,传入一个其它标记.
 */
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    completion(PKPaymentAuthorizationStatusSuccess);
}

/**
 *  完成支付或者取消,点用这个方法
 *  控制器dismiss要在这个方法中实现
 */
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}



/********   Apple pay 开发流程  *********/
@end
