//
//  Home.swift
//  LavaLampEffect
//
//  Created by George on 02/02/2025.
//

import SwiftUI

struct Home: View {
    //  MARK: Animation properties
    @State var dragOffset: CGSize = .zero
    var body: some View {
        //Single blob animation
        VStack {
            SingleBlob()
        }
    }
    @ViewBuilder
    func SingleBlob() -> some View {
        //for gradiet color use mask
        Canvas { context, size in
            //  MARK: adding filters
            //make changes here for custom color
            context.addFilter(.alphaThreshold(min: 0.5, color: .yellow))
            //  MARK: This blur Radius determines the amount of elasticity between two elements
            context.addFilter(.blur(radius: 100))
            
                //Drawing layer
            context.drawLayer { ctx in
                //placing symbols
                for index in [1,2] {
                    if let resolvedView = context.resolveSymbol(id: index){
                        ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                    }
                }
            }
        } symbols: {
            Ball()
                .tag(1)
            Ball(offset: dragOffset)
                .tag(2)
        }
        .gesture(
            DragGesture()
                .onChanged({ value in
                    dragOffset = value.translation
                }).onEnded({ _ in
                    withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                        dragOffset = .zero
                    }
                })
        )
    }
    
    @ViewBuilder
    func Ball(offset: CGSize = .zero) -> some View {
        Circle()
            .fill(.black)
            .frame(width: 150, height: 150)
            .offset(offset)
    }
}

#Preview {
    ContentView()
}
