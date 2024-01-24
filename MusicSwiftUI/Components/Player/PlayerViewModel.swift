//
//  PlayerViewModel.swift
//  Skailer
//
//  Created by zhanghao on 22/05/21.
//

import Foundation
import AVFoundation
import MediaPlayer

class PlayerViewModel: ObservableObject {
    
   
    var playbackFinished : ((_ success:Bool) -> Void)? = nil
    var player: AVPlayer?
    @Published var liked = true
    @Published var slider: Double = 30
    @Published var isPlaying = true
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    private var timeObserverToken: Any?
    @Published var currentModel: ZHPlaySong
    var playSongs: [ZHPlaySong]
    
    static let shared = PlayerViewModel()
    private init() {
            // 在这里进行AVPlayer的初始化等操作
        player = AVPlayer() // 初始化AVPlayer
        currentModel = ZHPlaySong()
        playSongs = []
    }
    func preparePlay(model: ZHPlaySong) {
        self.currentModel = model
        if model.url == nil && model.mp3Url == nil { return }
        
        if (self.player == nil) {
            player = AVPlayer()
        }
        
        let playerItem = AVPlayerItem(url: URL(string: (model.url ?? model.mp3Url)!)!)
        self.player = AVPlayer(playerItem: playerItem)
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
        
        self.duration = playerItem.asset.duration.seconds
       
        addPeriodicTimeObserver()
        player?.play()
        
        // 注册通知
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { [self] _ in
            // 在这里处理播放结束的逻辑
            print("Playback finished")
            playbackFinished?(true)
        }
        setPlaybackInfo(playbackStatus: Int(player?.rate ?? 0))
    }
    func setPlaybackInfo(playbackStatus:Int) {
            let mpic = MPNowPlayingInfoCenter.default()
            //专辑封面
            let mySize = CGSize(width: 400, height: 400)
           
        let albumArt = MPMediaItemArtwork(boundsSize: mySize) { [self] sz in
            return (currentModel.image ?? UIImage.init(named: "logo200x200"))!
        }
            
            //获取进度
            let position = Double(currentTime)
            let duration = Double(duration)
            
        mpic.nowPlayingInfo = [MPMediaItemPropertyTitle:currentModel.name ?? "未知",
                              MPMediaItemPropertyArtist:currentModel.ar?.name ?? "未知",
                                 MPMediaItemPropertyArtwork:albumArt,
                MPNowPlayingInfoPropertyElapsedPlaybackTime:position,
                        MPMediaItemPropertyPlaybackDuration:duration,
                       MPNowPlayingInfoPropertyPlaybackRate:playbackStatus]
        
        }
    
    
    func downloadImage(url:String) -> UIImage {
        var img = UIImage(named: "logo200x200")!
        guard let url = URL(string: url) else { return img }
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        self.downloadedImage = image
//                    }
                    img = image
                    
                }
            }.resume()
         return img
        }
    func resetPlayer() {
        stop()
        removeObserver()
        if currentModel.url == nil { return }
        let playerItem = AVPlayerItem(url: URL(string: currentModel.url ?? "")!)
        self.player = AVPlayer(playerItem: playerItem)
        self.duration = playerItem.asset.duration.seconds
        addPeriodicTimeObserver()
        isPlaying = true
        player?.play()
        // 注册通知
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { [self] _ in
            // 在这里处理播放结束的逻辑
            print("Playback finished")
            playbackFinished!(true)
        }
        setPlaybackInfo(playbackStatus: Int(player?.rate ?? 0))
    }
    func removeObserver() {
        player?.removeTimeObserver(self)
    }
    func stop() {
        player?.pause()
        player = nil // 如果你想释放播放器资源
        isPlaying = false
    }
    func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
//            print("currentTime====\(String(describing: self?.currentTime))")
        }
    }
    func playPause() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        
        isPlaying.toggle()
    }
    func convertTime(totalSeconds:Int) -> (String) {
        let seconds:Int = totalSeconds % 60
        let minutes:Int = (totalSeconds / 60) % 60
        let time:String = "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
        return time
    }
}
