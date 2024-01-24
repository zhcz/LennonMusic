//
//MinimizableView Example
//
//  Created by Dominik Butz on 6/10/2019.
//  Copyright © 2019 Duoyun. All rights reserved.
//

import SwiftUI
import PlayButton
import MediaPlayer
import Combine
import CoreMedia
import UIKit
import Closures
fileprivate let HORIZONTAL_SPACING: CGFloat = 30


struct PlayButtonView2: UIViewRepresentable {
 
    @Binding var isPlaying: Bool
    var onTap: () -> Void
    
    func makeUIView(context: Context) -> PlayButton {
        let playBtn =  PlayButton()
        playBtn.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        playBtn.playBufferingBackgroundColor = UIColor(named: "EFF0F9_282C31")
        playBtn.pauseStopBackgroundColor = UIColor(named: "EFF0F9_282C31")
        playBtn.playBufferingTintColor = UIColor(named: "657592_C6CBDA")
        playBtn.pauseStopTintColor = UIColor(named: "657592_C6CBDA")
        playBtn.setMode(isPlaying ? .pause : .play, animated: true)
       
        
        playBtn.addAction(
          UIAction { _ in
            print("button clicked")
          }, for: .touchUpInside
        )
        playBtn.on(.touchUpInside, handler: {sender,forEvent in 
            print("rrrr")
        })
        playBtn.onTapp = {
            if playBtn.mode == .pause {
                playBtn.setMode(.play, animated: true)
            }else{
                playBtn.setMode(.pause, animated: true)
            }
            onTap()
        }
        return playBtn
    }
    func updateUIView(_ uiView: PlayButton, context: Context) {
        // 在这里更新视图的状态（如果需要）
        uiView.setMode(isPlaying ? .pause : .play, animated: true)
    }
}

@available(iOS 17.0, *)
struct PlayerView: View {
    
    
    
    @EnvironmentObject var miniHandler: MinimizableViewHandler
    
   @State var showLyric: Bool = false
    @State var playSongs : [ZHPlaySong] = []
    @State var lyricArr: [LrcLyric] = []
    @State var count : Int = 0
    @State var playBtn : PlayButton!
    @State private var lrcConfig : AMLLLrcConfig?
    @State private var isNextTrackButtonEnabled = true
    @State var cancellable: AnyCancellable?
    @State var volume : CGFloat = 0
    
    @ObservedObject var viewModel: PlayerViewModel = PlayerViewModel.shared
    @ObservedObject var requestData = ZHRequestManager()
    
    var safeArea = UIApplication.shared.windows.first?.safeAreaInsets
    
   
    var animationNamespaceId: Namespace.ID
    
    var body: some View {
        GeometryReader { proxy in
//            ZStack {
//                Color.primary_color.edgesIgnoringSafeArea(.all)
                VStack(alignment: .center, spacing: 0) {
                    HStack {
                        if miniHandler.isMinimized == false {
                            Spacer(minLength: 0)
                        }
                        if miniHandler.isMinimized{
                            ZStack {
                                AsyncImage(url: URL(string: (viewModel.currentModel.al?.picUrl)!)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(20)
                                }placeholder: {
                                    // 加载中显示的视图
                                    ProgressView()
                                }
                            }
                            VStack {
                                HStack{
                                    Text(viewModel.currentModel.name ?? "").foregroundColor(.text_primary)
                                        .font(.headline)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                    Spacer()
                                }
                                HStack {
                                    Text(viewModel.currentModel.ar?.name ?? "").foregroundColor(.text_primary_f1.opacity(0.7))
                                        .font(.footnote)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                            }
                            Spacer()
                            HStack (spacing: 15) {
                                Button(action: {
                                    if viewModel.currentModel.index > 0 {
                                        viewModel.currentModel = playSongs[viewModel.currentModel.index-1]
                                        viewModel.resetPlayer()
                                        requestLyric()
                                    }
                                }, label: {
                                    Image(systemName: "backward.end.fill")
                                        .font(.title2)
                                        .foregroundColor(.text_primary)
                                })
                                Button(action: {
                                    viewModel.playPause()
                                }, label: {
                                    
                                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.title2)
                                        .foregroundColor(.text_primary)
                                })
                                Button(action: {
                                    if viewModel.currentModel.index < playSongs.count-1 {
                                        viewModel.currentModel = playSongs[viewModel.currentModel.index+1]
                                        viewModel.resetPlayer()
                                        requestLyric()
                                    }
                                }, label: {
                                    Image(systemName: "forward.end.fill")
                                        .font(.title2)
                                        .foregroundColor(.text_primary)
                                })
                            }
//                            .background(
//                                Rectangle()
//                                    .fill(.ultraThinMaterial)
//                                    .backgroundStyle(cornerRadius: 30)
//                            )
                        } else {
                            Spacer(minLength: 0)
                        }
                    }
                    .onTapGesture {
                        self.miniHandler.expand()
                    }
                    .padding(15)
                    
                    VStack {
                        capsuleView
                        topView
                        discoView
                        sliderView
                        playToolsView
                    }
                    .frame(height: self.miniHandler.isMinimized ? 0 : nil)
                        .opacity(self.miniHandler.isMinimized ? 0 : 1)
                }
                .onAppear(perform: { [self] in
                    lockScreenView()
                    print("appearing & presenting")
                    self.miniHandler.onDismissal = {
                        print("dismissing")
                    }
                    self.miniHandler.onExpansion = {
                        print("expanding")
                    }
                    self.miniHandler.onMinimization = {
                        print("contracting")
                    }
                })
//            }
        }.transition(AnyTransition.move(edge: .bottom))
    }
    var capsuleView: some View {
        Capsule()
            .fill(Color.gray)
        // .frame(width: self.miniHandler.isMinimized == false ? 40 : 0, height: self.miniHandler.isMinimized == false ? 5 : 0)
            .frame(width: 40, height: 5)
        // .opacity(self.miniHandler.isMinimized == false ? 1 : 0)
            .padding(.top, safeArea?.top ?? 5)
    }
    var playToolsView: some View {
        HStack(alignment: .center) {
            Button(action: {
                if PlayerViewModel.shared.currentModel.index > 0 {
                    PlayerViewModel.shared.currentModel = playSongs[PlayerViewModel.shared.currentModel.index-1]
                    PlayerViewModel.shared.resetPlayer()
                    requestLyric()
                }
            }) {
                Image.next.resizable().frame(width: 18, height: 18)
                    .rotationEffect(Angle(degrees: 180))
                    .padding(20).background(Color.primary_color)
                    .cornerRadius(40).modifier(NeuShadow())
            }
            Spacer()
            PlayButtonView2(isPlaying: $viewModel.isPlaying, onTap: {
                PlayerViewModel.shared.playPause()
            })
            .frame(width: 60, height: 60)
            .padding(10)
            .background(Color.primary_color)
            .cornerRadius(70)
            .modifier(NeuShadow())
            .zIndex(1)
            Spacer()
            Button(action: {
                if PlayerViewModel.shared.currentModel.index < playSongs.count-1 {
                    PlayerViewModel.shared.currentModel = playSongs[PlayerViewModel.shared.currentModel.index+1]
                    PlayerViewModel.shared.resetPlayer()
                    requestLyric()
                }
            }) {
                Image.next.resizable().frame(width: 18, height: 18)
                    .padding(20).background(Color.primary_color)
                    .cornerRadius(40).modifier(NeuShadow())
            }
        }
        .padding(.horizontal, 50)
        .padding(.top,30)
    }
    var discoView: some View {
        ZStack {
            PlayerDiscView(coverImage: (PlayerViewModel.shared.currentModel.al?.picUrl ?? PlayerViewModel.shared.currentModel.picUrl) ?? "")
                .frame(maxHeight: 350)
            if showLyric {
                animation(.easeIn) { _ in
                    AMLLView(playedTime: $viewModel.currentTime, lrcLyricsArray: lyricArr, lrcConfig: $lrcConfig) { seekTime in
                        print(seekTime)
                    }
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .cornerRadius(30)
                            .blur(radius: 30)
                    )
//                    .background(Color.primary_color.opacity(0.8))
                    .frame(maxHeight: 350)
                }
            }
        }
        .frame(height: self.miniHandler.isMinimized ? 0 : nil)
        .opacity(self.miniHandler.isMinimized ? 0 : 1)
        .padding(.top,60)
        .onTapGesture {
            showLyric.toggle()
        }
    }
    var sliderView: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(PlayerViewModel.shared.convertTime(totalSeconds: Int(PlayerViewModel.shared.currentTime))).foregroundColor(.text_primary)
                .font(.headline)
            
            Slider(value: $viewModel.currentTime, in: 0...PlayerViewModel.shared.duration, onEditingChanged: sliderEditingChanged)
                .accentColor(.text_primary)
            
            Text(PlayerViewModel.shared.convertTime(totalSeconds: Int(PlayerViewModel.shared.duration))).foregroundColor(.text_primary)
                .font(.headline)
            
        }.padding(.horizontal, 35)
            .padding(.top,30)
    }
    var topView: some View {
        HStack {
            Button(action: {
                //                        self.presentationMode.wrappedValue.dismiss()
                self.miniHandler.minimize()
            }) {
                Image.close.resizable()
                    .frame(width: 20, height: 20)
                    .padding(8)
                    .background(Color.primary_color)
                    .cornerRadius(20)
                    .modifier(NeuShadow())
            }
            
            .frame(width: self.miniHandler.isMinimized == false ? nil : 0, height: self.miniHandler.isMinimized == false ? nil : 0)
            
            Spacer()
            
            
            VStack {
                Text(PlayerViewModel.shared.currentModel.name ?? "").foregroundColor(.text_primary)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                  
                Text(PlayerViewModel.shared.currentModel.ar?.name ?? "").foregroundColor(.text_primary_f1.opacity(0.7))
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
            .frame(width: self.miniHandler.isMinimized == false ? nil : 0, height: self.miniHandler.isMinimized == false ? nil : 0)
            
            Spacer()
            
            Button(action: {
                self.miniHandler.dismiss()
            }) {
                Image.xmark.frame(width: 16, height: 16)
                    .padding(10)
                    .background(Color.primary_color)
                    .foregroundStyle(Color.text_header)
                    .cornerRadius(20)
                    .modifier(NeuShadow())
                    
            }
            .frame(width: self.miniHandler.isMinimized == false ? nil : 0, height: self.miniHandler.isMinimized == false ? nil : 0)
        }
        .zIndex(1)
        .padding()
        .frame(width: self.miniHandler.isMinimized == false ? nil : 0, height: self.miniHandler.isMinimized == false ? nil : 0)
    }
    
    func lockScreenView() {
        PlayerViewModel.shared.playbackFinished = { success in
            if PlayerViewModel.shared.currentModel.index < playSongs.count-1 {
                PlayerViewModel.shared.currentModel = playSongs[PlayerViewModel.shared.currentModel.index+1]
                PlayerViewModel.shared.resetPlayer()
            }
        }
        requestLyric()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        self.cancellable = (commandCenter.nextTrackCommand.addTarget { [self] event in
            if PlayerViewModel.shared.currentModel.index < playSongs.count-1 {
                PlayerViewModel.shared.currentModel = playSongs[PlayerViewModel.shared.currentModel.index+1]
                PlayerViewModel.shared.resetPlayer()
                requestLyric()
            }
            print("下一首")
            return .success
        }) as? AnyCancellable
        
        self.cancellable = (commandCenter.previousTrackCommand.addTarget { [self] event in
            if PlayerViewModel.shared.currentModel.index > 0 {
                PlayerViewModel.shared.currentModel = playSongs[PlayerViewModel.shared.currentModel.index-1]
                PlayerViewModel.shared.resetPlayer()
                requestLyric()
            }
            print("上一首")
            return .success
        }) as? AnyCancellable
        
        
        self.cancellable = (commandCenter.playCommand.addTarget { [self] event in
            PlayerViewModel.shared.player?.play()
            PlayerViewModel.shared.isPlaying = true
            print("播放")
            return .success
        }) as? AnyCancellable
        
        self.cancellable = (commandCenter.pauseCommand.addTarget { [self] event in
            PlayerViewModel.shared.player?.pause()
            PlayerViewModel.shared.isPlaying = false
            print("暂停")
            return .success
        }) as? AnyCancellable
    }
    func requestLyric() {
        if PlayerViewModel.shared.currentModel.id == nil { return }
        let url = musicPlayBaseUrl + songsLyric + "?id=" + String(PlayerViewModel.shared.currentModel.id ?? 0)
        lrcConfig = AMLLLrcConfig(lrcType: .lrc, lrcURLType: .local, lrcURL: URL.init(string: url)!, coderType: .utf8)
        requestData.requestLyric(id: String(PlayerViewModel.shared.currentModel.id ?? 0)) { lyricArr in
            self.lyricArr = lyricArr
        }
    }
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            PlayerViewModel.shared.player?.pause()
        } else {
            PlayerViewModel.shared.player?.seek(to: CMTime(seconds: PlayerViewModel.shared.currentTime, preferredTimescale: 1000)) { _ in
                if PlayerViewModel.shared.isPlaying {
                    PlayerViewModel.shared.player?.play()
                }
            }
        }
    }
    
    
    
    // square shaped, so we only need the edge length
    func imageSize(proxy: GeometryProxy)->CGFloat {
        if miniHandler.isMinimized {
            return 55 + abs(self.miniHandler.draggedOffsetY) / 2
        } else {
            return proxy.size.height * 0.33
        }
        
    }
}

fileprivate struct PlayerDiscView: View {
    let coverImage: String
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    @State private var rotationDegrees = 0.0
    var body: some View {
        
        ZStack {
            
            Circle().foregroundColor(.primary_color)
                .frame(width: 300, height: 300).modifier(NeuShadow())
            ForEach(0..<15, id: \.self) { i in
                RoundedRectangle(cornerRadius: (150 + CGFloat((8 * i))) / 2)
                    .stroke(lineWidth: 0.25)
                    .foregroundColor(.disc_line)
                    .frame(width: 150 + CGFloat((8 * i)),
                           height: 150 + CGFloat((8 * i)))
            }
            
            AsyncImage(url: URL(string: coverImage)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120).cornerRadius(60)
                    .rotationEffect(.degrees(rotationDegrees))
                    .onAppear {
                        PlayerViewModel.shared.isPlaying = true
                    }
                    .onReceive(timer) { _ in
                        if PlayerViewModel.shared.isPlaying {
                            // 持续增加角度，而不是重置为0
                            rotationDegrees += 0.5
                        }
                    }
            } placeholder: {
                // 加载中显示的视图
                ProgressView()
            }
            Image("cm6_play_needle_play_long")
                .resizable()
                .scaleEffect(0.8) // 缩小到50%
                .scaledToFill()
                .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .topLeading)
                .rotationEffect(Angle.degrees(PlayerViewModel.shared.isPlaying ? 0 : -30))
                .animation(.easeInOut(duration: 1), value: PlayerViewModel.shared.isPlaying)
            //                .background(.red)
                .offset(y: -220)
            //                .animation(isRotating ? rotation : .default, value: isRotating)
        }
        .onDisappear {
            PlayerViewModel.shared.stop()
        }
        //        var rotation: Animation {
        //            Animation.linear(duration: 20)
        //                .repeatForever(autoreverses: false)
        //        }
    }
}
