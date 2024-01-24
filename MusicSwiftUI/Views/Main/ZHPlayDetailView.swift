//
//  ZHPlayDetailView.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/8.
//

import SwiftUI
import URLImage
import Refresh
import Shimmer
import ColorfulX
@available(iOS 17.0, *)
struct ZHPlayDetailView: View {
    
    @ObservedObject var miniHandler: MinimizableViewHandler = MinimizableViewHandler()
    @GestureState var dragOffset = CGSize.zero
    let screenW = UIScreen.main.bounds.width
    var namespace: Namespace.ID
    @StateObject var playItem = ZHPlayList()
    var isAnimated = true
    @State var viewState: CGSize = .zero
    @State var showSection = false
    @State var appear = [false, false, false]
    @State var selectedSection : ZHPlaySong! = ZHPlaySong()
    @ObservedObject var requestData = ZHRequestManager()
    @State var playSongs : [ZHPlaySong] = []
    @EnvironmentObject var model: Model
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State private var headerRefreshing: Bool = false
    @State private var footerRefreshing: Bool = false
    @State private var noMore: Bool = false
    @State var textHeight: CGFloat = 0.0
    @State var isShowMoreText: Bool = false
    @State var colors: [Color] = [.white]
    
    var body: some View {
        listView
            .onAppear {
                reload()
                colors = playItem.colors ?? [.white]
            }
    }
    var listView: some View {
        ZStack {
            ScrollView {
                cover
                if playSongs.count > 0 {
                    sectionsSection
                        .opacity(appear[2] ? 1 : 0)
                    RefreshFooter(refreshing: $footerRefreshing, action: {
                        self.loadMore()
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
                    .preload(offset: 10)
                }else{
                    sestionsSectionPlaceholder
                        .redacted(reason: .placeholder)
                        .shimmering()
                }
            }
            .enableRefresh()
            .background(
                ColorfulView(color: $colors)
                    .ignoresSafeArea()
            )
            .coordinateSpace(name: "scroll")
            .background(Color("Background"))
            .mask(RoundedRectangle(cornerRadius: appear[0] ? 0 : 30))
            .mask(RoundedRectangle(cornerRadius: viewState.width / 3))
            .modifier(OutlineModifier(cornerRadius: viewState.width / 3))
            .shadow(color: Color("Shadow").opacity(0.5), radius: 30, x: 0, y: 10)
            .scaleEffect(-viewState.width/500 + 1)
            .background(Color("Shadow").opacity(viewState.width / 500))
            .background(.ultraThinMaterial)
            .gesture(isAnimated ? drag : nil)
            .ignoresSafeArea()
            .slideOverCard(isPresented: $isShowMoreText, style: SOCStyle(corners: 30.0,
                                                                         continuous: true,
                                                                         innerPadding: 20.0, outerPadding: 10.0,
                                                                         dimmingOpacity: 0.1,
                                                                         style: .clear)) {
                
                ScrollView {
                    Text(playItem.description ?? "")
                        .font(.footnote).bold()
                        .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .leading)
                        .foregroundColor(.primary.opacity(0.7))
                        .padding(.top,30)
                }
            }
            Button {
                isAnimated ?
                withAnimation(.closeCard) {
                    model.showSearchViewBar = true
                    model.showDetail = false
                    model.selectedCourse = 0
                }
                : presentationMode.wrappedValue.dismiss()
            } label: {
                if !isShowMoreText {
                    CloseButton()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(50)
            .ignoresSafeArea()
        }
        .statusBar(hidden: self.miniHandler.isPresented && self.miniHandler.isMinimized == false)
        .minimizableView(content: {
            PlayerView(playSongs: playSongs, animationNamespaceId: self.namespace)},
                         compactView: {
            EmptyView()  // replace EmptyView() by CompactViewExample() to see the a different approach for the compact view
        }, backgroundView: {
            self.backgroundView(miniHandler: self.miniHandler, colorScheme: self.colorScheme)
        },
                         dragOffset: $dragOffset,
                         dragUpdating: { (value, state, _) in
            state = value.translation
            self.dragUpdated(miniHandler: miniHandler, value: value)
            print("1====\(value)")
            
        }, dragOnChanged: { (value) in
            print("3====\(value)")
        },
                         dragOnEnded: { (value) in
            print("5====\(value)")
            self.dragOnEnded(miniHandler: miniHandler, value: value)
        }, minimizedBottomMargin: 0, settings: MiniSettings(minimizedHeight: 90,minimumDragDistance: 70))
        .environmentObject(self.miniHandler)
        .zIndex(1)
        .onAppear {
            fadeIn()
        }
        .onChange(of: model.showDetail) { value in
            fadeOut()
        }
    }
    var cover: some View {
        GeometryReader { proxy in
            let scrollY = proxy.frame(in: .named("scroll")).minY
            VStack {
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: scrollY > 0 ? screenW + scrollY : screenW )
            //            .background(
            //                AsyncImage(url: URL(string: (playItem.coverImgUrl)!)!) { phase in
            //
            //                    if let image = phase.image {
            //                        image
            //                            .resizable()
            //                            .aspectRatio(contentMode: .fill)
            //                            .matchedGeometryEffect(id: "background\(String(describing: playItem.index))", in: namespace)
            //                            .offset(y: scrollY > 0 ? -scrollY : 0)
            //                            .scaleEffect(scrollY > 0 ? scrollY / 1000 + 1 : 1)
            //                            .blur(radius: scrollY > 0 ? scrollY / 10 : 0)
            //                            .accessibility(hidden: true)
            //                    } else if phase.error != nil {
            //                        // 加载失败时显示的视图
            //                        Text("Failed to load the image")
            //                    } else {
            //                        // 加载中显示的视图
            //                        ProgressView()
            //                    }
            //                }
            //            )
            .mask(
                RoundedRectangle(cornerRadius: appear[0] ? 0 : 30)
                    .matchedGeometryEffect(id: "mask\(String(describing: playItem.index))", in: namespace)
                    .offset(y: scrollY > 0 ? -scrollY : 0)
            )
            //            .overlay(
            //                Image(horizontalSizeClass == .compact ? "Waves 1" : "Waves 2")
            //                    .frame(maxHeight: .infinity, alignment: .bottom)
            //                    .offset(y: scrollY > 0 ? -scrollY : 0)
            //                    .scaleEffect(scrollY > 0 ? scrollY / screenW + 1 : 1)
            //                    .opacity(1)
            //                    .matchedGeometryEffect(id: "waves\(String(describing: playItem.index))", in: namespace)
            //                    .accessibility(hidden: true)
            //            )
            .overlay(
                VStack(alignment: .leading, spacing: 16) {
                    Text(playItem.name ?? "")
                        .font(.title).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.primary)
                        .matchedGeometryEffect(id: "title\(String(describing: playItem.index))", in: namespace)
                    
                    GeometryReader { geometry in
                        VStack {
                            Text(playItem.description ?? "")
                                .font(.footnote).bold()
                                .frame(maxWidth: .infinity,maxHeight: 150, alignment: .leading)
                                .foregroundColor(.primary.opacity(0.7))
                            //                                .background(Color.red)
                                .matchedGeometryEffect(id: "subtitle\(String(describing: playItem.index))", in: namespace)
                                .onTapGesture {
                                    print("dianjile")
                                    
                                    withAnimation(.linear) {
                                        
                                    }
                                    isShowMoreText.toggle()
                                }
                        }
                    }
                    .onAppear {
                        // 在这里可以访问textHeight
                        print("Text height: \(textHeight)")
                    }
                    Divider()
                        .foregroundColor(.secondary)
                        .opacity(appear[1] ? 1 : 0)
                    
                    HStack {
                        LogoView(image: playItem.creator?.avatarUrl ?? "")
                        Text((playItem.creator?.nickname ?? ""))
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .opacity(appear[1] ? 1 : 0)
                    .accessibilityElement(children: .combine)
                }
                    .padding(20)
                    .padding(.vertical, 10)
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .cornerRadius(30)
                            .blur(radius: 30)
                            .matchedGeometryEffect(id: "blur\(String(describing: playItem.index))", in: namespace)
                            .opacity(appear[0] ? 0 : 1)
                        //                        .background(.yellow)
                    )
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .backgroundStyle(cornerRadius: 30)
                            .opacity(appear[0] ? 1 : 0)
                    )
                    .offset(y: scrollY > 0 ? -scrollY * 1.8 : 0)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .offset(y: 100)
                    .padding(20)
            )
        }
        //        .background(Color.red)
        .frame(height: screenW)
    }
    
    @available(iOS 17.0, *)
    var sestionsSectionPlaceholder: some View {
        VStack(spacing: 16) {
            ForEach(0..<10) { index in
                SectionRow(section: ZHPlaySong())
                
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .backgroundStyle(cornerRadius: 30)
        .padding(20)
        .padding(.vertical, 80)
    }
    var sectionsSection: some View {
        VStack(spacing: 16) {
            ForEach(Array(playSongs.enumerated()), id: \.offset) { index, playSong in
                if index != 0 {
                    //                        Divider()
                }
                SectionRow(section: playSong)
                    .onTapGesture {
                        //                        开始播放音乐
                        showSection.toggle()
                        selectedSection.name = playSong.name
                        selectedSection.id = playSong.id
                        selectedSection.al = playSong.al
                        selectedSection.ar = playSong.ar
                        selectedSection.picUrl = playSong.picUrl
                        selectedSection.url = playSong.url
                        //                            PlayerViewModel.shared.currentModel = selectedSection
                        PlayerViewModel.shared.preparePlay(model: selectedSection)
                        self.miniHandler.present()
                    }
            }
            
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .backgroundStyle(cornerRadius: 30)
        .padding(20)
        .padding(.vertical, 80)
        //            .fullScreenCover(isPresented: $showSection) {
        //                    PlayerView2(viewModel: PlayerViewModel(model: selectedSection),playSongs:playSongs)
        //                    PlayerView(viewModel: PlayerViewModel(model: selectedSection),playSongs:playSongs)
        
        //            }
    }
    
    func close() {
        withAnimation {
            viewState = .zero
        }
        withAnimation(.closeCard.delay(0.2)) {
            model.showDetail = false
            model.selectedCourse = 0
        }
    }
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 30, coordinateSpace: .local)
            .onChanged { value in
                guard value.translation.width > 0 else { return }
                if value.startLocation.x < 100 {
                    withAnimation {
                        viewState = value.translation
                    }
                }
                
                if viewState.width > 120 {
                    close()
                }
            }
            .onEnded { value in
                if viewState.width > 80 {
                    close()
                } else {
                    withAnimation(.openCard) {
                        viewState = .zero
                    }
                }
            }
    }
    
    func reload() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // 在这里放置延迟后执行的代码
            requestData.offset = 0
            if let ID = playItem.id {
                requestData.requestPlaySong(playId: String(ID), completion: { playSongs in
                    self.playSongs = playSongs
                    self.headerRefreshing = false
                    self.noMore = false
                })
            }
        }
        
    }
    
    func loadMore() {
        requestData.offset += 10
        if let ID = playItem.id {
            requestData.playSongs = playSongs
            requestData.requestPlaySong(playId: String(ID), completion: { playSongs in
                //                self.playSongs.append(contentsOf: playSongs)
                self.playSongs = playSongs
                self.footerRefreshing = false
                self.noMore = self.playSongs.count > 50
            })
        }
    }
    
    func fadeIn() {
        withAnimation(.easeOut.delay(0.3)) {
            appear[0] = true
        }
        withAnimation(.easeOut.delay(0.4)) {
            appear[1] = true
        }
        withAnimation(.easeOut.delay(0.5)) {
            appear[2] = true
        }
    }
    
    func fadeOut() {
        withAnimation(.easeIn(duration: 0.1)) {
            appear[0] = false
            appear[1] = false
            appear[2] = false
        }
    }
}
@available(iOS 17.0, *)
struct ZHPlayDetailView_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        ZHPlayDetailView(namespace: namespace)
            .environmentObject(Model())
    }
}


//
