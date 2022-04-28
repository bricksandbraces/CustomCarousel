//
//  SnapCarousel.swift
//  CustomCarousel
//
//  Created by Hendrik Ulbrich on 25.04.22.
//

import SwiftUI

public struct SnapCarousel<Content: View, T: Identifiable>: View {
    
    public var content: (T) -> Content
    public var list: [T]
    
    public var spacing: CGFloat
    public var trailingSpace: CGFloat
    public var threshold: CGFloat = 0.15
    
    @GestureState public var offset: CGFloat = 0
    @State private var currentIndex: Int = 0
    
    public init(spacing: CGFloat = 15, trailingSpace: CGFloat = 100, items: [T], @ViewBuilder content: @escaping (T)-> Content) {
        self.list = items
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let midOffset = currentIndex > 0 ? spacing : 0
            let width = proxy.size.width - trailingSpace + spacing
            
            HStack(spacing: spacing) {
                ForEach(list) {
                    item in
                    content(item)
                        .frame(width: proxy.size.width - trailingSpace)
                }
            }
            .padding(.leading, spacing)
            .offset(x: (CGFloat(currentIndex) * -width) + offset + midOffset)
            .gesture(
                DragGesture()
                    .updating($offset, body: { value, out, _ in
                            out = value.translation.width
                    })
                    .onEnded { value in
                        let offsetX = -value.translation.width
                        let delta = (offsetX / width).truncatingRemainder(dividingBy: 1)
                        if delta.magnitude > threshold {
                            currentIndex = delta > 0 ? currentIndex + 1 : currentIndex - 1
                            currentIndex = max(min(list.count - 1, currentIndex), 0)
                        }
                    }
            )
        }
        .animation(.easeInOut, value: offset)
        .animation(.easeOut, value: offset == 0)
    }
}
