//
//  ZHRequestManager.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/5.
//

import SwiftUI
import Alamofire
import ColorfulX
class ZHRequestManager: ObservableObject {
    
    
    @Published var playLists: [ZHPlayList] = []
    @Published var playSongs: [ZHPlaySong] = []
    
    
    var offset: Int = 0
    var songIdArr : [String] = []
    
    @MainActor
    func requestPlayList(completion:@escaping ([ZHPlayList])->()) async {
        let url = playListApi
        MNetwork.request(url: url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, methodType: .get, parameters: [:].self, encoding: URLEncoding.default, useBaseUrl: true) { [self] result in
            if let code = result["code"],code as! Int == 200 {
               
                if let arr = result["playlists"] as? [Dictionary<String,Any>] {
                    var index = 0
                    for dic in arr {
                        let model : ZHPlayList = ZHJsonUtil.dictionaryToModel(dic, ZHPlayList.self) as! ZHPlayList
                        let creatorModel : ZHPlayListCreator = ZHJsonUtil.dictionaryToModel(dic["creator"] as! [String : Any], ZHPlayListCreator.self) as! ZHPlayListCreator
                        model.creator = creatorModel
                        model.index = index
                        downloadImage_playList(url: model.coverImgUrl!, model: model)
                        playLists.append(model)
                        index += 1
                    }
                    completion(playLists)
                }
            }
//            print(result)
        } failureCallBack: { error in

        }
    }
//    获取歌单下所有歌曲
//    @MainActor
    func requestPlaySong(playId: String,completion:@escaping ([ZHPlaySong])->()) {
//        let param = ["id":playId,"limit":"10","offset":String(offset)]
//        print("param===\(param)")
        
        let url = playSongApi + "?id=" + playId + "&limit=10" + "&offset=" + String(offset)
        
        MNetwork.request(url: url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, methodType: .get, parameters: [:].self, encoding: URLEncoding.default, useBaseUrl: true) { [self] result in
//            if offset == 0 {
//                playSongs.removeAll()
//                songIdArr.removeAll()
//            }
//            print(result["songs"])
            if let code = result["code"],code as! Int == 200 {
                if let arr = result["songs"] {
                    let dataArr : [Dictionary] = arr as! [Dictionary<String, Any>]
                    
                    var idArr : [String] = []
                    for dic in dataArr {
                        
                        
                        let model : ZHPlaySong = ZHJsonUtil.dictionaryToModel(dic , ZHPlaySong.self) as! ZHPlaySong
                        
                        let id : Int = dic["id"] as! Int
                        let name: String = dic["name"] as? String ?? ""
                        
                        print(name)
                        idArr.append(String(id))
                        
                        
                        let al : Dictionary = dic["al"] as! Dictionary<String, Any>
                        let ar : Array = dic["ar"] as! Array<Any>
                        let alModel : ZHSongAlModel = ZHJsonUtil.dictionaryToModel(al, ZHSongAlModel.self) as! ZHSongAlModel
                        model.al = alModel
                        if ar.count > 0 {
                            let arDic = ar.first
                            let arModel : ZHSongArModel = ZHJsonUtil.dictionaryToModel(arDic as! [String : Any], ZHSongArModel.self) as! ZHSongArModel
                            model.ar = arModel
                        }
                        playSongs.append(model)
                    }
                    if idArr.count > 0 {
                        requestPlaySongUrl(songId: idArr.joined(separator: ","), completion: { playSongArr in
                            completion(playSongArr)
                        })
                    }
                }
            }
        } failureCallBack: { error in

        }
    }
//    根据歌曲id获取歌曲url
    func requestPlaySongUrl(songId: String,completion:@escaping ([ZHPlaySong])->()) {
        let url = playSongUrl + "?id=" + songId + "&type=1000"
        MNetwork.request(url: url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, methodType: .get, parameters: [:].self, encoding: URLEncoding.default, useBaseUrl: true) { [self] result in
            if let code = result["code"],code as! Int == 200 {
                if let arrayValue = (result["data"] as? [Dictionary<String, Any>]) {
                    var i = 0
                    
                    for dic in arrayValue {
                        let id : Int = (dic["id"] as? Int)!
                        for playSong in playSongs {
                            if id == playSong.id {
                                playSong.url = dic["url"] as? String
                                playSong.index = i + offset
                            }
                              
                        }
                        
//                        let model : ZHPlaySong = playSongs[i + offset]
//                        model.url = dic["url"] as? String
//                        model.index = i + offset
//                        print(model.index)
                        i += 1
                    }
                }
            }
            let sortedArray = playSongs.sorted { $0.index < $1.index }
            completion(sortedArray)
//          print(result)
        } failureCallBack: { error in
        }
    }
    
    func cloudsearch(keyword:String,type:SegmentIndex,completion:@escaping ([Any])->()) {
        let url = searchApi + "?keywords=" + keyword + "&type=\(type == .list ? "1000" : "1")" + "&limit=30" + "&offset=" + String(offset)
        MNetwork.request(url: url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, methodType: .get, parameters: [:].self, encoding: URLEncoding.default, useBaseUrl: true) { [self] result in
            
            
            
            if type == .list {
                if offset == 0 {
                    playLists.removeAll()
                }
                if let code = result["code"],code as! Int == 200 {
                    var dataArr: [ZHPlayList] = []
                    if let result = result["result"] as? Dictionary<String,Any> {
    //                    let resultDic: Dictionary = result
                        if let arr = result["playlists"] {
                            let arr2: Array = (arr as? [Dictionary<String,Any>])!
                            var index = 0
                            for dic in arr2 {
                                let model : ZHPlayList = ZHJsonUtil.dictionaryToModel(dic, ZHPlayList.self) as! ZHPlayList
                                let creatorModel : ZHPlayListCreator = ZHJsonUtil.dictionaryToModel(dic["creator"] as! [String : Any], ZHPlayListCreator.self) as! ZHPlayListCreator
                                model.creator = creatorModel
                                model.index = index
                                downloadImage_playList(url: model.coverImgUrl!, model: model)
                                dataArr.append(model)
                                index += 1
                            }
                        }
                        completion(dataArr)
                    }
                }
            }else{
                if offset == 0 {
                    playSongs.removeAll()
                }
                if let code = result["code"],code as! Int == 200 {
                    
                    if let result = result["result"] as? Dictionary<String,Any> {
                        
                        let arr: Array = result["songs"] as! Array<Dictionary<String,Any>>
                        
                        var index = 0
                        var idArr : [String] = []
                        for dic in arr {
                            let model : ZHPlaySong = ZHJsonUtil.dictionaryToModel(dic, ZHPlaySong.self) as! ZHPlaySong
                            model.url = model.mp3Url
                            if let album = dic["album"]{
                                
                                let albumDic : Dictionary = album as? Dictionary<String, Any> ?? [:]
                                if let artist = albumDic["artist"] as? Dictionary<String, Any> {
                                    if let img1v1Url = artist["img1v1Url"] {
                                        model.picUrl = img1v1Url as? String
                                    }
                                }
                                
                            }
                            idArr.append(String(model.id ?? 0))
                            model.index = index
                            playSongs.append(model)
                            index += 1
                        }
                        if idArr.count > 0 {
                            requestPlaySongUrl(songId: idArr.joined(separator: ","), completion: { playSongArr in
                                completion(playSongArr)
                            })
                        }
                    }
//                }
            }
        }
            
        } failureCallBack: { error in
            print(error)
        }
    }
    
    func newSongsRequest(completion:@escaping ([ZHPlaySong])->()) async {
        let url = newSongsApi
        MNetwork.request(url: url, methodType: .get, parameters: [:].self, encoding: URLEncoding.default, useBaseUrl: true) { [self] result in
            if let code = result["code"],code as! Int == 200 {
               
                if let arr = result["data"] as? [Dictionary<String,Any>] {
                    var index = 0
                    var idArr : [String] = []
                    for dic in arr {
                        let model : ZHPlaySong = ZHJsonUtil.dictionaryToModel(dic, ZHPlaySong.self) as! ZHPlaySong
                        model.url = model.mp3Url
                        if let album = dic["album"]{
                            let albumDic : Dictionary = album as! Dictionary<String, Any>
                            if let blurPicUrl = albumDic["blurPicUrl"] {
                                let alModel = ZHSongAlModel()
                                alModel.picUrl = blurPicUrl as? String
                                model.al = alModel
                                downloadImage(url: alModel.picUrl ?? "", model: model)
                            }
                        }
                        idArr.append(String(model.id ?? 0))
                        model.index = index
                        playSongs.append(model)
                        index += 1
                    }
                    if idArr.count > 0 {
                        requestPlaySongUrl(songId: idArr.joined(separator: ","), completion: { playSongArr in
                            completion(playSongArr)
                        })
                    }
                }
            }
        } failureCallBack: { error in

        }
    }
    
    func downloadImage(url:String,model:ZHPlaySong) {
        guard let url = URL(string: url) else { return }
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    model.image = image
                    
                    let colors : [UIColor] = image.dominantColors()
                    
                    var arr: [Color] = []
                    for uicolor in colors {
                        arr.append(Color((uicolor)))
                    }
                    model.colors = arr
                }
            }.resume()
        }
    func downloadImage_playList(url:String,model:ZHPlayList) {
        guard let url = URL(string: url) else { return }
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    model.image = image
                    
                    let colors : [UIColor] = image.dominantColors()
                    
                    var arr: [Color] = []
                    for uicolor in colors {
                        arr.append(Color((uicolor)))
                    }
                    model.colors = arr
                }
            }.resume()
        }
//    获取歌词
    func requestLyric(id:String,completion:@escaping ([LrcLyric])->()) {
        let param = ["id":id]
        MNetwork.request(url: songsLyric + "?id=" + id, methodType: .get, parameters: param, encoding: URLEncoding.default, useBaseUrl: true) { [self] result in
            //                print("result=================>>>===\(result)")
            if let lrc : Dictionary = result["lrc"] as? Dictionary<String, Any> {
                let lyric : String = (lrc["lyric"] as? String)!
                let arr : Array = lyric.components(separatedBy: "\n")
                self.analyzerLrc(arr: self.newArr(arr: arr), completion: { arr in
                    completion(arr)
                })
            }
        } failureCallBack: { error in
            
        }
    }
//    处理歌词
    func newArr(arr:Array<String>) -> Array<String> {
        var newA : Array<String> = []
        for str : String in arr {
            if str.lengthOfBytes(using:.utf8) > 0 {
                newA.append(str)
            }
        }
        return newA
    }
//    public var id = UUID()
//    public var indexNum: Int
//    public var lyric: String
//    public var time: Double
    func analyzerLrc(arr:Array<String>,completion:@escaping ([LrcLyric])->()) {
        var lyricArr : [LrcLyric] = []
        var currentInterval: TimeInterval = 0
        var ID = 0
        for str : String in arr {
           
            let eachLineArr : Array = str.components(separatedBy: "]")
            
            if eachLineArr.count > 1 {
                let lrc  = eachLineArr.last
                
                
//                model.lrc = lrc
//                model.id = ID
//                model.indexNum = ID
                let timeStr : String = eachLineArr.first!
                let format = DateFormatter()
                format.dateFormat = "[mm:ss.SS"
                let date = format.date(from: timeStr)
                let date2 = format.date(from: "[00.00.00")
                var interval : TimeInterval = date?.timeIntervalSince1970 ?? 0
                let interval2 : TimeInterval = date2?.timeIntervalSince1970 ?? 0
                interval = interval - interval2
                if interval < 0 {
                    interval = -1 * interval
                }
//                model.time = interval
//                model.duration = interval - currentInterval
                
                let model : LrcLyric = LrcLyric(indexNum: ID, lyric: lrc ?? "暂无歌词", time: interval)
                
                currentInterval = interval
                lyricArr.append(model)
                ID += 1
            }
        }
        completion(lyricArr)
        
    }
    
    
}
