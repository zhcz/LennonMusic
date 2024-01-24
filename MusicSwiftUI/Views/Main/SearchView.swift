//
//  SearchView.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/11.
//

import SwiftUI
import Refresh

enum SegmentIndex: Int {
    case list
    case song
}
@available(iOS 17.0, *)
struct SearchView: View {
    
    @State var playSongs : [ZHPlaySong] = []
    @State private var selectedSegment = 0
    @State var text: String = ""
    @State var scopeSelection: Int = 0
    @State var playLists : [ZHPlayList] = []
    @ObservedObject var requestData = ZHRequestManager()
    @EnvironmentObject var model: Model
    @State var showDetail: Bool = false
    @State var showStatusBar = true
    @State var contentHasScrolled = false
    @State private var searchText: String = ""
    @State var segmentIndex: SegmentIndex = .list
    var columns = [GridItem(.adaptive(minimum: 300), spacing: 20)]
    @Namespace var namespace
    let segments = ["歌单", "歌曲"]
    
    @State private var headerRefreshing: Bool = false
    @State private var footerRefreshing: Bool = false
    @State private var noMore: Bool = false
    @State var viewState: CGSize = .zero
    @State var showSection = false
    @State var appear = [false, false, false]
    @State var selectedSection : ZHPlaySong! = ZHPlaySong()
    @State var isRequesting: Bool = false
    
    var body: some View {
//        Color("Background").ignoresSafeArea()
        if model.showSearchViewBar {
            searchView
        }
        if segmentIndex == .list {
            
            ZStack {
                listView
                if isRequesting{
                    SimpleRefreshingView()
                        .padding()
                        .frame(maxWidth: .infinity,maxHeight: .infinity)
                        .zIndex(1)
                }
            }
            
        }else{
            ZStack {
                songView
                if isRequesting{
                    SimpleRefreshingView()
                        .padding()
                        .frame(maxWidth: .infinity,maxHeight: .infinity)
                        .zIndex(1)
                }
            }
           
        }
    }
    //    顶部搜索栏
    var searchView: some View {
        SearchTopView(searchText: $searchText, onSearch: { text in
            isRequesting = true
            requestData.offset = 0
            requestData.cloudsearch(keyword: searchText,type: segmentIndex) { arr in
                if segmentIndex == .list {
                    self.playLists = (arr as? [ZHPlayList])!
                }else{
                    self.playSongs = (arr as? [ZHPlaySong])!
                }
                isRequesting = false
            }
        }, onSegmentSelected: { index in
            segmentIndex = index == 0 ? .list : .song
        })
    }
    //    单曲搜索
    var songView: some View {
        ZStack {
            ScrollView {
                sectionsSection
//                    .opacity(appear[2] ? 1 : 0)
                
                if playSongs.count > 0 {
                    RefreshFooter(refreshing: $footerRefreshing, action: {

                        requestData.offset += 30
                        requestData.playSongs = playSongs
//                        requestData.playLists = playLists
                        requestData.cloudsearch(keyword: searchText,type: segmentIndex) { arr in
//                            if segmentIndex == .list {
//                                self.playLists = (arr as? [ZHPlayList] ?? [ZHPlayList()])
//                            }else{
                                self.playSongs = (arr as? [ZHPlaySong] ?? [ZHPlaySong()])
//                            }
                            self.footerRefreshing = false
                            self.noMore = self.playSongs.count > 50
                        }
                        
                    }) {
                        if self.noMore {
                            Text("No more data !")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            SimpleRefreshingView()
                                .padding()
                        }
                    }
                    .noMore(noMore)
                    .preload(offset: 30)
                }
            }
            .enableRefresh()
            .coordinateSpace(name: "scroll")
            .background(Color("Background"))
//            .mask(RoundedRectangle(cornerRadius: appear[0] ? 0 : 30))
//            .mask(RoundedRectangle(cornerRadius: viewState.width / 3))
//            .modifier(OutlineModifier(cornerRadius: viewState.width / 3))
//            .shadow(color: Color("Shadow").opacity(0.5), radius: 30, x: 0, y: 10)
//            .scaleEffect(-viewState.width/500 + 1)
            .background(Color("Shadow").opacity(viewState.width / 500))
            .background(.ultraThinMaterial)
//            .gesture(drag)
//            .ignoresSafeArea()
            
        }
//        .zIndex(1)
//        .onAppear {
//            fadeIn()
//        }
//        .onChange(of: model.showDetail) { value in
//            fadeOut()
//        }
    }
    //    歌单搜索
    var listView: some View {
        
        ZStack {
            
            if model.showDetail {
                detail
            }
            ScrollView {
                if playLists.count == 0 {
                    VStack{
                        Text("没有数据！")
                            .frame(maxWidth: .infinity,maxHeight: .infinity)
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .backgroundStyle(cornerRadius: 30)
                    .padding(20)
                     
                }
                
                scrollDetection
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
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        playItem.frame(height: 300)
                    }
                    .padding(.horizontal, 20)
                }
                
                if playLists.count > 0 {
                    RefreshFooter(refreshing: $footerRefreshing, action: {

                        requestData.offset += 30
                        requestData.playLists = playLists
                        requestData.cloudsearch(keyword: searchText,type: segmentIndex) { arr in
//                            if segmentIndex == .list {
                                self.playLists = (arr as? [ZHPlayList] ?? [ZHPlayList()])
//                            }else{
//                                self.playSongs = (arr as? [ZHPlaySong] ?? [ZHPlaySong()])
//                            }
                            self.footerRefreshing = false
                            self.noMore = self.playLists.count > 50
                        }
                        
                    }) {
                        if self.noMore {
                            Text("No more data !")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            SimpleRefreshingView()
                                .padding()
                        }
                    }
                    .noMore(noMore)
                    .preload(offset: 30)
                }
            }
            .enableRefresh()
            .background(Color("Background"))
            .coordinateSpace(name: "scroll")
        }
        .onChange(of: model.showDetail) { value in
            withAnimation {
                model.showTab.toggle()
                model.showNav.toggle()
                showStatusBar.toggle()
            }
        }
        .statusBar(hidden: !showStatusBar)
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
    var sectionsSection: some View {
        
        VStack(spacing: 16) {
            
            if playSongs.count == 0 {
                Text("没有数据！")
                    .frame(maxWidth: .infinity,maxHeight: .infinity)
            }
            ForEach(Array(playSongs.enumerated()), id: \.offset) { index, playSong in
                if index != 0 {
                    Divider()
                }
                SectionRow(section: playSong)
                    .onTapGesture {
                        //                        开始播放音乐
                        showSection.toggle()
                        //                            selectedSection = playSong
                        selectedSection.name = playSong.name
                        selectedSection.id = playSong.id
                        selectedSection.al = playSong.al
                        selectedSection.ar = playSong.ar
                        selectedSection.picUrl = playSong.picUrl
                        selectedSection.url = playSong.url
                        //                            print("Selected section: \(selectedSection)")
                    }
                //                        .background(.red)
                //                        .accessibilityElement(children: .combine)
            }
            
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .backgroundStyle(cornerRadius: 30)
        .padding(20)
        
        .fullScreenCover(isPresented: $showSection) 
            {
                VStack {
//                    PlayerView(viewModel: PlayerViewModel(model: selectedSection),playSongs:playSongs, animationNamespaceId: <#Namespace.ID#>)
                }
                .onAppear {
                    //                    print("Before presenting full screen cover: \(selectedSection)")
                }
            }
    }
}
@available(iOS 17.0, *)
#Preview {
    SearchView()
}
