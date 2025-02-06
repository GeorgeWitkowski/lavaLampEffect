//
//  Home.swift
//  LavaLampEffect
//
//  Created by George on 02/02/2025.
//

import SwiftUI

enum MetaballOption: String, CaseIterable, Identifiable {
    case single  = "Single"
    case clubbed = "Clubbed"
    
    var id: String { rawValue }
}

private var theGradient: LinearGradient {
    .linearGradient(colors: [Color("Gradient1"),
                             Color("Gradient2")],
                    startPoint: .top,
                    endPoint: .bottom)
}

struct Home: View {
    //  MARK: Animation properties
    @State var dragOffset: CGSize = .zero
    @State var startAnimation: Bool = true
    @State var selected: MetaballOption = .single
    
    var body: some View {
        VStack {
            Text("Metaball Animation")
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(15)
            
            Picker("", selection: $selected) {
                ForEach(MetaballOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 15)
            
            switch selected {
                case .single:
                    SingleBlob()
                case .clubbed:
                    ClubbedView()
            }
        }
    }
    
    @ViewBuilder
    func ClubbedView() -> some View {
        let numberOfBalls = 15
        let ballIndexes = 1...numberOfBalls
        // Tips: animationCycle
        let animationCycle = 2.0 //how long the animation needs to be changed
        let ballMovingTime = 1.9 // animation time
        
        return Rectangle()
            .fill(theGradient)
            .mask({
                TimelineView(.animation(minimumInterval: animationCycle, paused: false)) { _ in
                    Canvas { context, size in
                        // Adding Filters
                        context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                        // This blur Radius determines the amount of elasticity between two elements
                        context.addFilter(.blur(radius: 30))
                        
                        // Draw Layer
                        context.drawLayer { layerContext in
                            // Placing Symbols
                            for index in ballIndexes {
                                if let resolvedView = context.resolveSymbol(id: index) {
                                    layerContext.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                }
                            }
                        }
                    } symbols: {
                        ForEach(ballIndexes, id: \.self) { index in
                            // Generating Custom Offset For Each Time
                            // Thus It will be at random place and clubbed with each other
                            let offset   = startAnimation
                            ? CGSize(width: .random(in: -180...180), height: .random(in: -240...240)) // The range in which the Ball moves around
                            : .zero
                            let diameter = startAnimation ? CGFloat.random(in: 120...160) : 140
                            Ball(offset: offset, diameter: diameter)
                                .tag(index)
                                .animation(.easeOut(duration: ballMovingTime), value: offset)
                        }
                    }
                }
            })
            .contentShape(Rectangle())
            .onTapGesture {
                startAnimation.toggle()
            }
    }
    
    @ViewBuilder
    func ClubbedRoundedRectangle(offset: CGSize) -> some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(.green)
            .frame(width: 120, height: 120)
            .offset(offset)
        // MARK: Adding Animation[Less Than TimelineView Refresh Rate]
            .animation(.easeInOut(duration: 4), value: offset)
    }
    
    
    @ViewBuilder
    func SingleBlob() -> some View {
        return Rectangle()
            .fill(theGradient)
            .mask {
                Canvas { context, size in
                    //  MARK: adding filters
                    //make changes here for custom color
                    context.addFilter(.alphaThreshold(min: 0.5, color: .yellow))
                    //  MARK: This blur Radius determines the amount of elasticity between two elements
                    context.addFilter(.blur(radius: 35))
                    
                    //Drawing layer
                    context.drawLayer { layerContext in
                        //placing symbols
                        for index in [1,2] {
                            if let resolvedView = context.resolveSymbol(id: index){
                                layerContext.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                            }
                        }
                    }
                } symbols: {
                    Ball()
                        .tag(1)
                    Ball(offset: dragOffset)
                        .tag(2)
                }
            }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { _ in
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                                dragOffset = .zero
                            }
                        }
                )
            }
    }
    
    @ViewBuilder
    func Ball(offset: CGSize = .zero, diameter: CGFloat = 150) -> some View {
        Circle()
            .fill(.black)
            .frame(width: diameter, height: diameter)
            .offset(offset)
    }
    

#Preview {
    ContentView()
}
