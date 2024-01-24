//
//  HomeView.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/8.
//

import SwiftUI


@available(iOS 17.0, *)
struct HomeView: View {
    @ObservedObject var requestData = ZHRequestManager()
    @State var playLists : [ZHPlayList] = []
    
    @State var newSongArr : [ZHPlaySong] = []
    @State var showStatusBar = true
    @State var contentHasScrolled = false
    @State var selectedPlay: ZHPlaySong = ZHPlaySong()
    @State var slidePlay: ZHPlaySong = ZHPlaySong()
    @State private var selectedTab = 0
    @State var showPlayListDetail = false
    var columns = [GridItem(.adaptive(minimum: 300), spacing: 20)]
    @EnvironmentObject var model: Model
    
    
    @ObservedObject var miniHandler: MinimizableViewHandler = MinimizableViewHandler()
//    @ObservedObject var viewModel: PlayerViewModel
//    @State var playSongs : [ZHPlaySong] = []
    @Environment(\.colorScheme) var colorScheme
    @State var miniViewBottomMargin: CGFloat = 0
    @GestureState var dragOffset = CGSize.zero
    @Namespace var namespace
    
    var body: some View {

        ZStack {
            Color("Background").ignoresSafeArea()
            if model.showDetail {
                detail
            }
            ScrollView {
                scrollDetection
                Rectangle()
                    .frame(width: 100, height: 72)
                    .opacity(0)
                topView
                Text("精品歌单".uppercased())
                    .sectionTitleModifier()
                    .offset(y: -80)
                    .accessibilityAddTraits(.isHeader)
                
                if model.showDetail {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(playLists) { course in
                            Rectangle()
                                .fill(.white)
                                .frame(height: 300)
                                .cornerRadius(30)
                                .shadow(color: Color("Shadow").opacity(0.2), radius: 20, x: 0, y: 10)
                                .opacity(0.3)
                        }
                    }
                    .padding(.horizontal, 20)
                    .offset(y: -80)
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        playItem.frame(height: 300)
                    }
                    .padding(.horizontal, 20)
                    .offset(y: -80)
                }
            }
            .coordinateSpace(name: "scroll")
        }
        .onChange(of: model.showDetail) { value in
            withAnimation {
                model.showTab.toggle()
                model.showNav.toggle()
                showStatusBar.toggle()
            }
        }
        .overlay(
            NavigationBar(title: "歌单",playLists: playLists, contentHasScrolled: $contentHasScrolled)
        )
        
        .statusBar(hidden: !showStatusBar)
        .statusBar(hidden: self.miniHandler.isPresented && self.miniHandler.isMinimized == false)
        .minimizableView(content: {
            PlayerView(playSongs: newSongArr, animationNamespaceId: self.namespace)},
                         compactView: {
            EmptyView()  // replace EmptyView() by CompactViewExample() to see the a different approach for the compact view
        }, backgroundView: {
            self.backgroundView(miniHandler: self.miniHandler, colorScheme: self.colorScheme)},
                         dragOffset: $dragOffset,
                         dragUpdating: { (value, state, _) in
            state = value.translation
            self.dragUpdated(miniHandler: self.miniHandler, value: value)
            print("1====\(value)")
            
        }, dragOnChanged: { (value) in
            print("3====\(value)")
        },
                         dragOnEnded: { (value) in
            print("5====\(value)")
            self.dragOnEnded(miniHandler: self.miniHandler, value: value)
        }, minimizedBottomMargin: self.miniViewBottomMargin, settings: MiniSettings(minimizedHeight: 90,minimumDragDistance: 70))
        .environmentObject(self.miniHandler)

        
    }
    var detail: some View {
        ForEach(playLists) { course in
            if course.index == model.selectedCourse {
                ZHPlayDetailView(namespace: namespace,playItem: course)
            }
        }
    }
    
    var playItem: some View {
        ForEach(playLists) { course in
            PlayListItem(namespace: namespace, playList: course)
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isButton)
        }
    }
    var scrollDetection: some View {
        GeometryReader { proxy in
            let offset = proxy.frame(in: .named("scroll")).minY
            Color.clear.preference(key: ScrollPreferenceKey.self, value: offset)
        }
        .onPreferenceChange(ScrollPreferenceKey.self) { value in
            withAnimation(.easeInOut) {
                if value < 0 {
                    contentHasScrolled = true
                } else {
                    contentHasScrolled = false
                }
            }
        }
    }
    @available(iOS 17.0, *)
    var topView: some View {
        TabView(selection: $selectedTab){
            ForEach(Array(newSongArr.enumerated()), id: \.offset) { index, songList in
                GeometryReader { proxy in
                    ZHPlayListItem(songList: songList, namespace: namespace)
                        .cornerRadius(30)
                        .modifier(OutlineModifier(cornerRadius: 30))
                        .rotation3DEffect(
                            .degrees(proxy.frame(in: .global).minX / -10),
                            axis: (x: 0, y: 1, z: 0), perspective: 1
                        )
                        .shadow(color: Color("Shadow").opacity(0.3),
                                radius: 30, x: 0, y: 30)
                        .blur(radius: abs(proxy.frame(in: .global).minX) / 40)
                        .tag(index)
                        .padding(20)
                        .onTapGesture {
                            showPlayListDetail.toggle()
                            selectedPlay.id = songList.id
                            selectedPlay.name = songList.name
                            selectedPlay.url = songList.url
                            selectedPlay.al = songList.al
                            selectedPlay.colors = songList.colors
                            selectedPlay.image = songList.image
                            
                            PlayerViewModel.shared.preparePlay(model: selectedPlay)
                            self.miniHandler.present()
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityAddTraits(.isButton)
                }
            }
        }
        .onChange(of: selectedTab) { value in
            print("Selected tab: \(value)")
            slidePlay = newSongArr[value]
            // 在这里执行滑动选项卡的回调
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 460)
        .background(
            AsyncImage(url: URL(string: (slidePlay.picUrl ?? ""))) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .offset(x: 0, y: -200)
                        .accessibility(hidden: true)
                } else if phase.error != nil {
                    // 加载失败时显示的视图
                    Text("Failed to load the image")
                } else {
                    // 加载中显示的视图
                    ProgressView()
                }
            }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5))
        )
        .task {
            await requestData.requestPlayList(completion: { playLists in
                self.playLists = playLists
                
            })
            
            await requestData.newSongsRequest { newSongArr in
                self.newSongArr = newSongArr
                if newSongArr.count > 0 {
                    selectedPlay = newSongArr[0]
                    slidePlay = newSongArr[0]
                }
            }
        }
//        .fullScreenCover(isPresented: $showPlayListDetail) {
           
            
//            PlayerView(viewModel: PlayerViewModel(model: selectedPlay),playSongs:newSongArr)
//        }
    }
}
@available(iOS 17.0, *)
#Preview {
    HomeView()
        .environmentObject(Model())
}

