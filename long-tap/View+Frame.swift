//
//  View+Frame.swift
//  long-tap
//

import SwiftUI

extension View {
    /// Reports the view's frame in `coordinateSpace` on appear and whenever it changes.
    func onFrameChange(
        in coordinateSpace: CoordinateSpace = .global,
        perform action: @escaping (CGRect) -> Void
    ) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: FramePreferenceKey.self, value: proxy.frame(in: coordinateSpace))
            }
        )
        .onPreferenceChange(FramePreferenceKey.self, perform: action)
    }
}

private struct FramePreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
