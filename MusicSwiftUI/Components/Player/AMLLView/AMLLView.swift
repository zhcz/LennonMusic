//
//  AMLLView.swift
//
//
//  Created by YICHAO LI on 2024/1/1.
//

import SwiftUI

@available(iOS 17.0, *)
public struct AMLLView: View {
    // MARK: Binding Data
    @Binding var playedTime     : Double
    
    // MARK: Init Config
    @Binding var lrcConfig      : AMLLLrcConfig?
    @State var viewConfig       : AMLLViewConfig = defaultAMLLViewConfig
    
    // MARK: Lyrics
    @State var lrcLyricsArray           : [LrcLyric]?   = nil
    @State private var ttmlLyricsArray          : [TtmlLyric]?  = nil
    // MARK: Lyrics Hightlight
    @State private var lrcHightlightCellIndex   : Int  = -1
    @State private var ttmlHighlightCellIndex   : Int  = -1
    // MARK: ScrollView
    @State private var isScrollViewGestrueScroll: Bool          = false
    @State private var inLongPress              : Bool          = false
    @State private var scorllValue              : CGFloat       = 0
    // MARK: Private to TTMLLyricCell
    @State private var singleFontWidth          : CGFloat = 0
    @State private var singleFontHeight         : CGFloat = 0
    
    // MARK: seek
    public var onSeek: ((Double) -> Void)?
    
    // MARK: Init
    public init(playedTime: Binding<Double>,
                lrcLyricsArray:[LrcLyric],
                lrcConfig: Binding<AMLLLrcConfig?>,
                viewConfig: AMLLViewConfig = defaultAMLLViewConfig,
                onSeek: ((Double) -> Void)?
    ) {
        self._playedTime = playedTime
        self._lrcConfig = lrcConfig
        self.viewConfig = viewConfig
        self.onSeek = onSeek
        self.lrcLyricsArray = lrcLyricsArray
    }
    
    // MARK: Main Body
    public var body: some View {
        if lrcConfig?.lrcType == .lrc {
            lrcScrollView
        } else if lrcConfig?.lrcType == .ttml {
            ttmlScorllView
        } else {
            Text("Not Supported")
        }
    }
    
    // MARK: LrcScrollView
    private var lrcScrollView : some View {
        GeometryReader { bounds in
            //MARK: ScrollView Reader
            ScrollViewReader { proxy in
                // MARK: Gestrue Event
                let longPress = LongPressGesture()
                let dragGesture = DragGesture()
                    .onChanged{ value in
                        isScrollViewGestrueScroll = true
                        scorllValue = value.translation.height
                    }
                    .onEnded{ _ in
                        calcLrcScrollViewDragEnd(proxy: proxy)
                    }
                let sequencedGesture = longPress.sequenced(before: dragGesture)
                
                // MARK: Lyrics ScrollView
                ScrollView(showsIndicators: false) {
                    ForEach( lrcLyricsArray ?? [], id:\.id ) { lyric in
                        HStack(spacing: 0) {
                            Spacer(minLength: 0)
                            LrcLyricCell(lyric: lyric,
                                         viewConfig: $viewConfig,
                                         lrcHightlightCellIndex: $lrcHightlightCellIndex,
                                         isScrollViewGestrueScroll: $isScrollViewGestrueScroll,
                                         onSeek: onSeek)
                            Spacer(minLength: 0)
                        }
                        .id(lyric.id)
                    }
                    .offset(y: scorllValue)
                }
                .scrollDisabled(viewConfig.isCloseDefaultScroll)
                .gesture(viewConfig.isCloseDefaultScroll ? sequencedGesture : nil)
                // MARK: calcHightlightCellChange
                .onChange(of: lrcHightlightCellIndex) { _, _ in
                    calcLrcScrollViewNewHightlightCell(proxy: proxy)
                }
            }
        }
        // MARK: receive time update
        .onChange(of: playedTime) { _, time in
            updateLrcLyric(timePosition: time)
        }
        // MARK: update Lyrics Config
        .onChange(of: lrcConfig) { oldValue, newValue in
            debugPrint("AAMLView onChange LrcConfig")
            guard let lrcConfig = lrcConfig else { return }
            Task {
                do {
                    try await lrcLyricsArray = AMLLResourceManager.shared.handlerLrc(urlType: lrcConfig.lrcURLType, URL: lrcConfig.lrcURL, coderType: lrcConfig.coderType, withExtraInfo: false)
                } catch {
                    debugPrint(error)
                }
            }
        }
        // MARK: onAppear Load Lyrics
        .onAppear {
            debugPrint("AAMLView LRC onAppear")
            guard let lrcConfig = lrcConfig else { return }
            Task {
                do {
                    try await lrcLyricsArray = AMLLResourceManager.shared.handlerLrc(urlType: lrcConfig.lrcURLType, URL: lrcConfig.lrcURL, coderType: lrcConfig.coderType, withExtraInfo: false)
                } catch {
                    debugPrint(error)
                }
            }
        }
    }
    
    // MARK: TtmlScrollView
    private var ttmlScorllView : some View {
        GeometryReader { bounds in
            //MARK: ScrollView Reader
            ScrollViewReader { proxy in
                // MARK: Gestrue Event
                let longPress = LongPressGesture()
                let dragGesture = DragGesture()
                    .onChanged{ value in
                        isScrollViewGestrueScroll = true
                        scorllValue = value.translation.height
                    }
                    .onEnded{ _ in
                        calcTtmlScrollViewDragEnd(proxy: proxy)
                    }
                let sequencedGesture = longPress.sequenced(before: dragGesture)
                
                // MARK: Lyrics ScrollView
                ScrollView(showsIndicators: false) {
                    ForEach( ttmlLyricsArray ?? [], id:\.id ) { lyric in
                        HStack(spacing: 0) {
                            Spacer(minLength: 0)
                            TtmlLyricCell(lyric: lyric,
                                          viewConfig: $viewConfig,
                                          ttmlHighlightCellIndex: $ttmlHighlightCellIndex,
                                          isScrollViewGestrueScroll: $isScrollViewGestrueScroll,
                                          onSeek: onSeek)
                            Spacer(minLength: 0)
                        }
                        .id(lyric.id)
                    }
                    .offset(y: scorllValue)
                }
                .scrollDisabled(viewConfig.isCloseDefaultScroll)
                .gesture(viewConfig.isCloseDefaultScroll ? sequencedGesture : nil)
                .background {
                    Text("A")
                        .monospaced()
                        .font(viewConfig.mainFontSize)
                        .fixedSize(horizontal: true, vertical: true)
                        .foregroundColor(.clear)
                        .background {
                            GeometryReader { gProxy in
                                Color.clear.onAppear {
                                    singleFontWidth  = gProxy.size.width
                                    debugPrint("singleFontWidth:", gProxy.size.width)
                                    singleFontHeight = gProxy.size.height
                                    debugPrint("singleFontHeight:", gProxy.size.height)
                                }
                            }
                        }
                }
                // MARK: calcHightlightCellChange
                .onChange(of: ttmlHighlightCellIndex) { _, _ in
                    calcTtmlScrollViewNewHighlightCell(proxy: proxy)
                }
            }
        }
        // MARK: receive time update
        .onChange(of: playedTime) { _, time in
            updateTtmlLyric(timePosition: time)
        }
        // MARK: update Lyrics Config
        .onChange(of: lrcConfig) { oldValue, newValue in
            debugPrint("AAMLView onChange LrcConfig")
            guard let lrcConfig = lrcConfig else { return }
            Task {
                do {
                    self.ttmlLyricsArray = try await AMLLResourceManager.shared.handleTtml(urlType: lrcConfig.lrcURLType, URL: lrcConfig.lrcURL)
                } catch {
                    debugPrint(error)
                }
            }
        }
        // MARK: Load ttml data
        .onAppear {
            debugPrint("AAMLView TTML onAppear")
            guard let lrcConfig = lrcConfig else { return }
            Task {
                do {
                    let array = try await AMLLResourceManager.shared.handleTtml(urlType: lrcConfig.lrcURLType, URL: lrcConfig.lrcURL)
                    self.ttmlLyricsArray = array
                } catch {
                    debugPrint(error)
                }
            }
        }
    }
}

// MARK: Animation
@available(iOS 17.0, *)
extension AMLLView {
    // Lrc
    private func calcLrcScrollViewDragEnd(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(viewConfig.transformAnimation) {
                scorllValue = 0
                isScrollViewGestrueScroll = false
                if let lyricsCount = lrcLyricsArray?.count, lyricsCount >= 1, lrcHightlightCellIndex > 0 {
                    proxy.scrollTo(lrcLyricsArray?[lrcHightlightCellIndex - 1].id, anchor: viewConfig.highlightAnchor)
                } else {
                    proxy.scrollTo(lrcLyricsArray?[0].id, anchor: .top)
                }
            }
        }
    }
    // Lrc
    private func calcLrcScrollViewNewHightlightCell(proxy: ScrollViewProxy) {
        if let lyricsCount = lrcLyricsArray?.count, lyricsCount >= 1, !isScrollViewGestrueScroll {
            DispatchQueue.main.async {
                withAnimation(viewConfig.transformAnimation) {
                    let scrollToIndex = lrcHightlightCellIndex > 0 ? lrcHightlightCellIndex - 1 : 0
                    proxy.scrollTo(lrcLyricsArray?[scrollToIndex].id, anchor: scrollToIndex > 0 ? viewConfig.highlightAnchor : .top)
                }
            }
        }
    }
    
    // Ttml
    private func calcTtmlScrollViewDragEnd(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(viewConfig.transformAnimation) {
                scorllValue = 0
                isScrollViewGestrueScroll = false
                if let lyricsCount = ttmlLyricsArray?.count, lyricsCount >= 1, ttmlHighlightCellIndex > 0 {
                    proxy.scrollTo(ttmlLyricsArray?[ttmlHighlightCellIndex - 1].id, anchor: viewConfig.highlightAnchor)
                } else {
                    proxy.scrollTo(ttmlLyricsArray?[0].id, anchor: .top)
                }
            }
        }
    }
    // Ttml
    private func calcTtmlScrollViewNewHighlightCell(proxy: ScrollViewProxy){
        if let lyricsCount = ttmlLyricsArray?.count, lyricsCount >= 1, !isScrollViewGestrueScroll {
            DispatchQueue.main.async {
                withAnimation(viewConfig.transformAnimation) {
                    let scrollToIndex = ttmlHighlightCellIndex > 0 ? ttmlHighlightCellIndex : 0
                    proxy.scrollTo(ttmlLyricsArray?[scrollToIndex].id, anchor: scrollToIndex > 0 ? viewConfig.highlightAnchor : .top)
                }
            }
        }
    }
}

// MARK: Update HighlightCellIndex
@available(iOS 17.0, *)
extension AMLLView {
    private func updateLrcLyric(timePosition: Double) {
        // Empty
        guard let lyricArray = self.lrcLyricsArray, !lyricArray.isEmpty else {
            DispatchQueue.main.async {
                lrcHightlightCellIndex = 0
            }
            return
        }
        if timePosition <= 0.1 {
            DispatchQueue.main.async {
                lrcHightlightCellIndex = 0
            }
        }
        DispatchQueue.main.async {
            for (index, lyric) in lyricArray.enumerated() {
                if index != lyricArray.count-1 {
                    if lyric.time < timePosition && lyricArray[index+1].time >= timePosition {
                        if index != lrcHightlightCellIndex {
                            lrcHightlightCellIndex = index
                            debugPrint("update", index, lyric.time)
                            break
                        }
                    }
                } else {
                    if lyric.time < timePosition {
                        if index != lrcHightlightCellIndex {
                            lrcHightlightCellIndex = index
                            debugPrint("update", index, lyric.time)
                            break
                        }
                    }
                }
            }
        }
    }
    
    private func updateTtmlLyric(timePosition: Double) {
        // Empty
        guard let lyricArray = self.ttmlLyricsArray, !lyricArray.isEmpty else {
            DispatchQueue.main.async {
                lrcHightlightCellIndex = 0
            }
            return
        }
        DispatchQueue.main.async {
            for (index, lyric) in lyricArray.enumerated() {
                if lyric.endTime < timePosition { continue }
                if lyric.beginTime > timePosition { continue }
                if lyric.beginTime <= timePosition && lyric.endTime > timePosition && index != ttmlHighlightCellIndex {
                    ttmlHighlightCellIndex = index
                    debugPrint("update", index, timePosition)
                }
            }
        }
    }
}
@available(iOS 17.0, *)
// MARK: LyricCell - Lrc Type
fileprivate struct LrcLyricCell: View, Equatable {
    // MARK:
    @State   var lyric                  : LrcLyric
    @Binding var viewConfig             : AMLLViewConfig
    @Binding var lrcHightlightCellIndex : Int
    @Binding var isScrollViewGestrueScroll : Bool
    // MARK: Internal Calc Value
    @State var isHighlight          : Bool = false
    @State var highlightCellIndex   : Int? = 0
    @State var isBlurEffectReduce   : Bool = false
    // MARK: Seek
    public var onSeek: ((Double) -> Void)?
    
    // MARK: Internal Display Value
    @State var isClick : Bool = false
    @State private var blurRadius: CGFloat = 1.2
    
    static func == (lhs: LrcLyricCell, rhs: LrcLyricCell) -> Bool {
        lhs.lyric == rhs.lyric
    }
    
    var body: some View {
        if (!lyric.lyric.isEmpty) {
            HStack(spacing: 0) {
                Text(lyric.lyric)
                    .font(viewConfig.mainFontSize)
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundColor(isHighlight ? viewConfig.mainFontColor : viewConfig.mainFontColor.opacity(0.8))
                    .blur(radius: blurRadius)
                    .scaleEffect(isHighlight ? 1 : 0.88, anchor: viewConfig.fontAnchor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isClick ? viewConfig.mainFontColor.opacity(0.3) : Color.clear)
                            .scaleEffect(isHighlight ? 1 : 0.88, anchor: viewConfig.fontAnchor)
                    )
                    .frame(maxWidth: .infinity)
//                    .background(.red)
                
                    .onTapGesture {
                        onSeek?(lyric.time)
                        withAnimation(.easeOut(duration: 0.3)) {
                            isClick = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isClick = false
                            }
                        }
                    }
                    .onChange(of: lrcHightlightCellIndex) { oldValue, newValue in
                        if (oldValue == lyric.indexNum) {
                            withAnimation(.spring()) {
                                self.isHighlight = false
                                updateBlurRadius()
                            }
                            return
                        }
                        if (newValue == lyric.indexNum) {
                            withAnimation(.spring()) {
                                self.isHighlight = true
                                updateBlurRadius()
                            }
                            return
                        }
                    }
                    .onChange(of: isScrollViewGestrueScroll) { _, _ in
                        withAnimation(.spring()) {
                            updateBlurRadius()
                        }
                    }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 2)
            
        } else {
            EmptyView().frame(height: 12)
        }
    }
    
    private func updateBlurRadius() {
        blurRadius = isHighlight ? 0 : (isScrollViewGestrueScroll ? 0.5 : 1.2)
    }
}
@available(iOS 17.0, *)
// MARK: TTML Lyrics Cell
fileprivate struct TtmlLyricCell: View, Equatable {
    // MARK:
    @State   var lyric                      : TtmlLyric
    @Binding var viewConfig                 : AMLLViewConfig
    @Binding var ttmlHighlightCellIndex     : Int
    @Binding var isScrollViewGestrueScroll  : Bool
    
    @State var mainLyricText : String = ""
    @State var bgLyricText   : String = ""

    @State private var isHighlight              : Bool = false
    
    // MARK: Seek
    public var onSeek: ((Double) -> Void)?
    
    // MARK: Internal Display Value
    @State var isClick : Bool = false
    @State private var blurRadius: CGFloat = 1.2
    
    static func == (lhs: TtmlLyricCell, rhs: TtmlLyricCell) -> Bool {
        lhs.lyric == rhs.lyric
    }
    
    var body: some View {
        if (!(lyric.mainLyric?.isEmpty ?? true)) {
            
//            let _ = debugPrint("Update Cell:" , lyric.indexNum)
            
            LazyVStack(spacing: 0) {
                // MARK: Main-Lyric
                HStack(spacing: 0) {
                    if (lyric.position == .sub) {
                        Spacer(minLength: 0)
                    }
                    
                    Text(mainLyricText)
                        .monospaced()
                        .font(viewConfig.mainFontSize).bold()
                        .foregroundColor(isHighlight ? viewConfig.mainFontColor : viewConfig.mainFontColor.opacity(0.8))
                        .multilineTextAlignment((lyric.position == .main) ? .leading : .trailing)
                        .truncationMode(.tail)
                        .blur(radius: blurRadius)
                        .scaleEffect(isHighlight ? 1 : 0.88, anchor:  scaleEffectAnchor(viewConfig.fontAnchor))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isClick ? viewConfig.mainFontColor.opacity(0.3) : Color.clear)
                                .scaleEffect(isHighlight ? 1 : 0.88, anchor: scaleEffectAnchor(viewConfig.fontAnchor))
                        )
                        .onTapGesture {
                            onSeek?(Double(lyric.beginTime))
                            withAnimation(.easeOut(duration: 0.3)) {
                                isClick = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isClick = false
                                }
                            }
                        }
                        .onChange(of: ttmlHighlightCellIndex) { oldValue, newValue in
                            if (oldValue == (lyric.indexNum)) {
                                withAnimation(.spring()) {
                                    self.isHighlight = false
                                    updateBlurRadius()
                                }
                                return
                            }
                            if (newValue == (lyric.indexNum)) {
                                withAnimation(.spring()) {
                                    self.isHighlight = true
                                    updateBlurRadius()
                                }
                                return
                            }
                        }
                    
                    if (lyric.position == .main) {
                        Spacer(minLength: 0)
                    }
                }
                // MARK: Translation && Roman
                if ( !(lyric.translation?.isEmpty ?? true) || !(lyric.roman?.isEmpty ?? true)) {
                    VStack(spacing: 0) {
                        // MARK: Translation
                        if (!(lyric.translation?.isEmpty ?? true)) {
                            HStack(spacing: 0) {
                                if (lyric.position == .sub) { Spacer(minLength: 0) }
                                Text(lyric.translation ?? "")
                                    .font(viewConfig.subFontSize)
                                    .blur(radius: blurRadius)
                                    .scaleEffect(isHighlight ? 1 : 0.88, anchor:  scaleEffectAnchor(viewConfig.fontAnchor))
                                    .padding(.horizontal, 10)
                                    .opacity(isHighlight ? 0.8 : 0.6)
                                if (lyric.position == .main) { Spacer(minLength: 0) }
                            }
                        }
                        // MARK: Roman
                        if (!(lyric.roman?.isEmpty ?? true)) {
                            HStack(spacing: 0) {
                                if (lyric.position == .sub) { Spacer(minLength: 0) }
                                Text(lyric.roman ?? "")
                                    .font(viewConfig.subFontSize)
                                    .blur(radius: blurRadius)
                                    .scaleEffect(isHighlight ? 1 : 0.88, anchor:  scaleEffectAnchor(viewConfig.fontAnchor))
                                    .padding(.horizontal, 10)
                                    .opacity(isHighlight ? 0.8 : 0.6)
                                if (lyric.position == .main) { Spacer(minLength: 0) }
                            }
                        }
                    }
                    .padding(.top, (!(lyric.translation?.isEmpty ?? true) || !(lyric.roman?.isEmpty ?? true)) ? 4 : 0)
                }
                
                // MARK: Bg-Lyric
                if (!(lyric.bgLyric?.subLyric?.isEmpty ?? true)) {
                    HStack(spacing: 0) {
                        if (lyric.position == .sub) {
                            Spacer(minLength: 0)
                        }
                        
                        Text(bgLyricText)
                            .monospaced()
                            .font(viewConfig.subFontSize).bold()
                            .blur(radius: blurRadius)
                            .scaleEffect(isHighlight ? 1 : 0.5, anchor: (lyric.position == .main) ? .topLeading : .topTrailing)
                            .padding(.horizontal, 10)
                            .padding(.vertical, isHighlight ? 8 : 0)
                            .opacity(isHighlight ? 0.9 : 0)
                        
                        if (lyric.position == .main) {
                            Spacer(minLength: 0)
                        }
                    }
                    .frame(height: isHighlight ? nil : 0)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 2)
            
            .onAppear {
                guard let mainLyric = lyric.mainLyric else { return }
                DispatchQueue.main.async {
                    for subLyric in mainLyric {
                        mainLyricText = mainLyricText + subLyric.text
                    }
                }
                guard let bgLyric = lyric.bgLyric else { return }
                guard let subLyric = bgLyric.subLyric else { return }
                DispatchQueue.main.async {
                    for sub in subLyric {
                        bgLyricText = bgLyricText + sub.text
                    }
                }
            }
        }
        else {
            EmptyView().frame(height: 12)
        }
    }
    
    func scaleEffectAnchor(_ viewConfigAnchor: UnitPoint) -> UnitPoint {
        if (viewConfigAnchor == .center) { return .center }
        if (lyric.position == .main) { return viewConfigAnchor }
        let x = viewConfigAnchor.x
        let y = viewConfigAnchor.y
        return UnitPoint(x: 1-x, y: 1-y)
    }
    
    func updateBlurRadius() {
        if isHighlight {
            blurRadius = 0
        } else if isScrollViewGestrueScroll {
            blurRadius = 0.5
        } else {
            blurRadius = 1.2
        }
//        blurRadius = isHighlight ? 0 : ((isScrollViewGestrueScroll or isScrolling) ? 0.5 : 1.2)
    }
}

@available(iOS 16.4, *)
fileprivate struct AnimatedMask: AnimatableModifier {
    var viewConfig  : AMLLViewConfig
    var isHighlight : Bool
    var blurRadius  : CGFloat
    var lyric       : TtmlLyric
    var lyricText   : String
    var phase       : CGFloat = 0
    var textWidth   : CGFloat
    var textHeight  : CGFloat
    var lyricFont   : Font
    var lineNumber  : Int // 当前Text有几行
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func body(content: Content) -> some View {
        if isHighlight {
            content
                .overlay(OverlayView(width: textWidth, maskHeight: textHeight, progress: phase, lineNumber: lineNumber))
                .mask(MaskTextView(lyricText: lyricText, font: lyricFont))
                .blur(radius: blurRadius)
                .scaleEffect(isHighlight ? 1 : 0.88, anchor: scaleEffectAnchor(viewConfig.fontAnchor))
        } else {
            content
        }
    }
    
    func scaleEffectAnchor(_ viewConfigAnchor: UnitPoint) -> UnitPoint {
        if (viewConfigAnchor == .center) { return .center }
        if (lyric.position == .main) { return viewConfigAnchor }
        let x = viewConfigAnchor.x
        let y = viewConfigAnchor.y
        return UnitPoint(x: 1-x, y: 1-y)
    }
}

fileprivate struct OverlayView: View {
    let width       : CGFloat
    let maskHeight  : CGFloat
    let progress    : CGFloat
    let lineNumber  : Int
    var body: some View {
        Path() { path in
            for i in 0...1 {
                let yValue : CGFloat = (18 * CGFloat(i+1)) + (20 * CGFloat(i))
                path.move(to: CGPoint(x: 0, y: yValue))
                path.addLine(to: CGPoint(x: width, y: yValue))
            }
        }
        .trim(from: 0, to: progress)
        .stroke(lineWidth: maskHeight)
    }
}


@available(iOS 16.4, *)
fileprivate struct MaskTextView : View {
    var lyricText : String
    var font : Font
    var body: some View {
        Text(lyricText)
            .monospaced()
            .font(font)
            .fixedSize(horizontal: false, vertical: true)
    }
}
