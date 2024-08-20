//
//  AnimatedGradientStrokeView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 20/8/24.
//  Code reference: https://uvolchyk.medium.com/making-things-glow-and-shine-with-swiftui-80448c560f88
//

import SwiftUI

struct AnimatedGradientStrokeView: View, Animatable {
  var progress: Double
  var lineWidth: Double
  private let delay = 0.3

  var animatableData: Double {
    get { progress }
    set { progress = newValue }
  }

  var body: some View {
    Rectangle()
      .trim(
        from: {
          if progress > 1 - delay {
            2 * progress - 1.0
          } else if progress > delay {
            progress - delay
          } else {
            .zero
          }
        }(),
        to: progress
      )
      .glow(
        fill: .palette,
        lineWidth: lineWidth
      )
  }
}

extension View where Self: Shape {
  func glow(
    fill: some ShapeStyle,
    lineWidth: Double,
    blurRadius: Double = 8.0,
    lineCap: CGLineCap = .round
  ) -> some View {
    self
      .stroke(style: StrokeStyle(lineWidth: lineWidth / 2, lineCap: lineCap))
      .fill(fill)
      .overlay {
        self
          .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
          .fill(fill)
          .blur(radius: blurRadius)
      }
      .overlay {
        self
          .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
          .fill(fill)
          .blur(radius: blurRadius / 2)
      }
  }
}

extension ShapeStyle where Self == AngularGradient {
  static var palette: some ShapeStyle {
    .angularGradient(
      stops: [
        .init(color: .blue, location: 0.0),
        .init(color: .purple, location: 0.2),
        .init(color: .red, location: 0.4),
        .init(color: .mint, location: 0.5),
        .init(color: .indigo, location: 0.7),
        .init(color: .pink, location: 0.9),
        .init(color: .blue, location: 1.0),
      ],
      center: .center,
      startAngle: Angle(radians: .zero),
      endAngle: Angle(radians: .pi * 2)
    )
  }
}
