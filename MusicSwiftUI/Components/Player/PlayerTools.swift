//
//  PlayerTools.swift
//  MusicSwiftUI
//
//  Created by zhanghao on 2024/1/19.
//

import SwiftUI


extension View {
    func dragUpdated(miniHandler: MinimizableViewHandler,value: DragGesture.Value) {
        if miniHandler.isMinimized == false && value.translation.height > 0   { // expanded state
            withAnimation(.spring(response: 0)) {
                miniHandler.draggedOffsetY = value.translation.height  // divide by a factor > 1 for more "inertia"
            }
            
        } else if miniHandler.isMinimized && value.translation.height < 0   {// minimized state
            if miniHandler.draggedOffsetY >= -60 {
                withAnimation(.spring(response: 0)) {
                    miniHandler.draggedOffsetY = value.translation.height // divide by a factor > 1 for more "inertia"
                }
            }
        }
    }
    
    func dragOnEnded(miniHandler: MinimizableViewHandler,value: DragGesture.Value) {
        
        if miniHandler.isMinimized == false && value.translation.height > 90  {
            miniHandler.minimize()
            
        } else if miniHandler.isMinimized &&  value.translation.height <= -60 {
            miniHandler.expand()
        }
        withAnimation(.spring()) {
            miniHandler.draggedOffsetY = 0
        }
    }
    
    func backgroundView(miniHandler: MinimizableViewHandler,colorScheme: ColorScheme) -> some View {
        VStack(spacing: 0){
            BlurView(style: .systemChromeMaterial)
            if miniHandler.isMinimized {
                Divider()
            }
        }
        .cornerRadius(miniHandler.isMinimized ? 0 : 20)
        .shadow(color: .gray.opacity(colorScheme == .light ? 0.5 : 0), radius: 5, x: 0, y: -5)
        .onTapGesture(perform: {
            if miniHandler.isMinimized {
                miniHandler.expand()
                //alternatively, override the default animation. self.miniHandler.expand(animation: Animation)
            }
        })
    }
}
struct CustomStyleModifier: ViewModifier {
    var colorScheme: ColorScheme
    
    func body(content: Content) -> some View {
        if colorScheme == .dark {
            return content
                .foregroundColor(.white)
        } else {
            return content
                .foregroundColor(.black)
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> some UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
