//
//  MNetwork.swift
//  MNetwork
//
//  Created by Lynx on 03/04/2020.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit
import Alamofire
import HandyJSON

typealias SuccessCallBack = ((_ result:[String: Any]) -> ())?
typealias FailureCallBack = ((_ error: Error) -> ())?
 

let songDetail = "song/detail"
let songUrl = "song/url"
let songList = "personalized"
let qrCodeKey = "login/qr/key"
let qrCreate = "login/qr/create"
let qrCheck = "login/qr/check"
let checkMusicApi = "check/music"
let userAccount = "user/account"
//登录状态
let loginStatus = "login/status"
let recommendSongs = "recommend/songs"//获取每日推荐歌曲
let recommendResource = "recommend/resource"//获取每日推荐歌单
let songsLikelist = "likelist"//获取我喜欢的歌曲
let songsLyric = "lyric"//获取歌词
let songsSearch = "cloudsearch"//搜索
let songsLike = "like"//喜欢
let songsCommentHot = "comment/hot"//喜欢

let likelist = "likelist" //
let hotRadio = "dj/hot"//热门电台

let playListApi = "top/playlist/highquality"  //获取精品歌单
let playSongApi = "playlist/track/all" //歌单下所有歌曲
let playSongUrl = "song/url"//根据id获取歌曲url

let sendCodeApi = "captcha/sent"//发送手机验证码，参数：phone
let captchaVerifyAPi = "captcha/verify"//验证手机验证码
let loginCellphoneApi = "login/cellphone" //手机验证码登录

let defautAvatarUrl = "https://picsum.photos/200"//默认头像

let searchApi = "search" //搜索
/*
必选参数 : keywords : 关键词
可选参数 : limit : 返回数量 , 默认为 30 offset : 偏移数量，用于分页 , 如 : 如 :( 页数 -1)*30, 其中 30 为 limit 的值 , 默认为 0
type: 搜索类型；默认为 1 即单曲 , 取值意义 : 1: 单曲, 10: 专辑, 100: 歌手, 1000: 歌单, 1002: 用户, 1004: MV, 1006: 歌词, 1009: 电台, 1014: 视频, 1018:综合, 2000:声音(搜索声音返回字段格式会不一样)
*/

let newSongsApi = "top/song" //新歌速递
/*
type: 地区类型 id,对应以下:
全部:0
华语:7
欧美:96
日本:8
韩国:16
*/


//let playListApi = "top/playlist"  //歌单 ( 网友精选碟 )

let musicPlayBaseUrl = "https://xxx.cn/"//更换服务器地址
enum APIURL {
    static var disBaserURL = musicPlayBaseUrl
    static var devBaseURL = musicPlayBaseUrl
    
//https://neteasecloudmusicapi.vercel.app/#/?id=neteasecloudmusicapi
    #if DEBUG
    static var baseURL = devBaseURL
    #else
    static var baseURL = disBaserURL
    #endif
}

class MNetwork: NSObject {
    struct ResponseType: Codable {
            let success: String
            let message: String
            let data: [String]
        }
    static let lastNetWorkRequestParamers = MNetWorkParameter()
    static var apiKey: String = "Basic NjQyNjllMDQ3ZDU2YmM5OTZmMjdkZjFkOjE2ZTBlOGI3MDhmY2VjMjAzYjVkMWE0Nw=="
    public static var headers: HTTPHeaders {
        var headers:HTTPHeaders = [:]
//        let session = LCApplication.default.currentUser?.sessionToken?.stringValue
//        headers["X-LC-Session"] = session
        headers["X-LC-Id"] = "ynMAn7XOvvxivG61hKnibx0P-gzGzoHsz"
        headers["X-LC-Key"] = "bJozAX2UEPCNqmriHhTiceIc"
        headers["Content-Type"] = "application/json"
        headers["Authorization"] = apiKey
        return headers
    }
    static var isDebugServer: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isDebugServer")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isDebugServer")
        }
    }
    /// 网络请求
    ///
    /// - Parameters:
    ///   - url: 各个接口的url
    ///   - methodType: 请求方式
    ///   - parameters: 请求参数
    ///   - isNestedData: 是否为嵌套型字典（是则使用Json，否则使用键值对）
    ///   - useBaseUrl: 是否使用基础URL
    ///   - successCallBack: 请求成功回调，可选
    ///   - failureCallBack: 失败回调，可选
    static func request(url:String, methodType: HTTPMethod = .get, parameters:[String:Any] = [:], encoding:ParameterEncoding = URLEncoding.default, useBaseUrl:Bool = true,file: String = #file,lineNum: Int = #line, successCallBack:SuccessCallBack = nil, failureCallBack: FailureCallBack = nil) {
        var fullURL = url
        if useBaseUrl {
            fullURL = APIURL.baseURL + url
        }
        let mutableParameters = getFullParameters(parameters: parameters, url: url)
        AF.request(fullURL, method: methodType, parameters: methodType == .get ? nil : mutableParameters, encoding: encoding, headers: headers).responseDecodable(of: ResponseType.self) { (response) in
            if let data = response.data {
//                try! JSONSerialization.jsonObject(with: data, options: .mutableContainers)as! Dictionary<String,String>
                let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                if dict == nil {
                    successCallBack!(["data":String(data: data, encoding: .utf8)!] as! Dictionary)
                }else{
                    guard let dic = dict else { return }
                    if dic is Dictionary<String, Any> {
                        successCallBack!(dict as! Dictionary)
                    }else{
                        successCallBack!(["data":dict as Any])
                    }
                }
//                print("-*-*-*-*-*-:",String(data: data, encoding: .utf8)!)
             }
        }
    }
   
    ///Add the default parameters.
    private static func getFullParameters(parameters:[String:Any], url:String) -> [String:Any] {
        var mutableParameters = [String: Any]()
        mutableParameters += parameters
        return mutableParameters
    }
    ///Request again after failed.
    private static func recoverLastNetWorkRequest() {
        let methodType = lastNetWorkRequestParamers.methodType
        let url = lastNetWorkRequestParamers.url
        let parameters = lastNetWorkRequestParamers.parameters
        let file = lastNetWorkRequestParamers.file
        let lineNum = lastNetWorkRequestParamers.lineNum
        let isNestedData = lastNetWorkRequestParamers.isNestedData
        let useBaseUrl = lastNetWorkRequestParamers.useBaseUrl
        let encoding = lastNetWorkRequestParamers.encoding
        let successCallBack = lastNetWorkRequestParamers.successCallBack!
        let failureCallBack = lastNetWorkRequestParamers.failureCallBack
        MNetwork.request(url: url, methodType: methodType, parameters: parameters, encoding: encoding, useBaseUrl: useBaseUrl, file: file, lineNum: lineNum, successCallBack: successCallBack, failureCallBack: failureCallBack)
    }
    
    ///Assign  the value to the baseURL again when the app activates.
    static func initBaseURL() {
        #if DEBUG
        if MNetwork.isDebugServer {
            APIURL.baseURL = APIURL.devBaseURL
        } else {
            APIURL.baseURL = APIURL.disBaserURL
        }
        #endif
    }
    
    static func switchBaseURL() {
        MNetwork.isDebugServer = !MNetwork.isDebugServer
        var message = "当前为：正式服"
        if MNetwork.isDebugServer {
            APIURL.baseURL = APIURL.devBaseURL
            message = "当前为：开发服"
        } else {
            APIURL.baseURL = APIURL.disBaserURL
            message = "当前为：正式服"
        }
        print(message)
    }
}

func += <KeyType, ValueType> ( left: inout Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}
