//
//  YCViewController.m
//  ShecarePASDKDemo
//
//  Created by mac on 2019/11/7.
//  Copyright © 2019 ikangtai. All rights reserved.
//

#import "YCViewController.h"

@interface YCViewController ()

@end

@implementation YCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = false;
}

-(NSString *)errorMsgWith:(NSError *)error {
    if (error == nil) {
        return @"";
    }
    SCErrorCode errCode = error.code;
    switch (errCode) {
        case SCErrorCodeNoError:
            return @"";
            break;
        case SCErrorCodeNoPaper:
            return @"没有找到试纸";
            break;
        case SCErrorCodeTooFar:
            return @"距离过远，请调整拍摄距离";
            break;
        case SCErrorCodeTooDirty:
            return @"背景有干扰，请在浅色纯背景下拍摄";
            break;
        case SCErrorCodeTooClose:
            return @"距离过近，请调整拍摄距离";
            break;
        case SCErrorCodeNotCompleted:
            return @"试纸不全，请保持全部试纸处在取景框内";
            break;
        case SCErrorCodeHedNetError:
            return @"算法处理中，请稍候";
            break;
        case SCErrorCodeTooManyPapers:
            return @"一次只能拍摄一张试纸";
            break;
        case SCErrorCodeUnderExposure:
            return @"光线太暗，请调整光线或打开闪光灯后拍摄";
            break;
        case SCErrorCodeExposed:
            return @"光线太强，请调整光线或关掉闪光灯后拍摄";
            break;
        case SCErrorCodePartlyExposed:
            return @"局部光线太强，请调整光线或关掉闪光灯后拍摄";
            break;
        case SCErrorCodeBlurred:
            return @"画面模糊，请保持手机稳定或重新对焦";
            break;
        case SCErrorCodeUnderExposure2:
            return @"光线太暗，请调整光线或打开闪光灯后拍摄";
            break;
        case SCErrorCodeUnknownError:
            return @"未知错误";
            break;
        case SCErrorCodeUserCanceled:
            return @"用户取消确认";
            break;
        case SCErrorCodeNoCLine:
            return @"未检测到T线和C线，如果T线和C线存在，请拖动到相应的位置";
            break;
        case SCErrorCodeNoTLine:
            return @"未检测到T线，如果T线存在，请拖动到相应的位置";
            break;
        case SCErrorCodeGetValueError:
            return @"试纸分析出错，请稍后重试";
            break;
        case SCErrorCodeSDKError:
            return @"SDK 校验失败或无效";
            break;
        case SCErrorCodeVideoOutofDate:
            return @"扫描超时";
            break;
        case SCErrorCodeManualClipError:
            return @"手动裁剪失败，请检查传入的图片和坐标点";
            break;
        case SCErrorCodeInvalidParam:
            return @"请求参数不合法";
            break;
        case SCErrorCodeResultToJSONFailed:
            return @"分析结果转化为 JSON 时出错";
            break;
        case SCErrorCodeAnalysisFailedForServer:
            return @"分析失败，服务返回";
            break;
        case SCErrorCodeBase64Failed:
            return @"图片 Base64 编解码失败";
            break;
        case SCErrorCodeAuthFailed:
            return @"认证错误";
            break;
        case SCErrorCodeAuthOutOfTime:
            return @"超时，认证无效";
            break;
        case SCErrorCodeAccessDenied:
            return @"请求频率过高，访问受限";
            break;
        case SCErrorCodeInvalidParamForAuth:
            return @"认证时缺少相关参数";
            break;
        case SCErrorCodeInvalidPaper:
            return @"试纸无效";
            break;
        case SCErrorCodeAnalysisFailed:
            return @"分析失败";
            break;
        default:
            return error.localizedDescription;
    }
}

@end
