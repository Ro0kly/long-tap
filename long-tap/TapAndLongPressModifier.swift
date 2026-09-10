//
//  TapAndLongPressModifier.swift
//  long-tap
//

import SwiftUI

extension View {
    /// Handles a tap and a long press on the same view, including the moment the long press is released.
    ///
    /// Once the long press is recognized, the finger can be dragged outside the view. `onLongPressMove`
    /// and `onLongPressEnd` report its location in `coordinateSpace`, so the caller can check whether
    /// it was released over another view by comparing with that view's frame in the same space.
    func onTapAndLongPress(
        minimumDuration: Double = 0.5,
        coordinateSpace: CoordinateSpace = .global,
        onTap: @escaping () -> Void,
        onLongPressStart: @escaping () -> Void,
        onLongPressMove: @escaping (CGPoint) -> Void = { _ in },
        onLongPressEnd: @escaping (CGPoint?) -> Void
    ) -> some View {
        modifier(TapAndLongPressModifier(
            minimumDuration: minimumDuration,
            coordinateSpace: coordinateSpace,
            onTap: onTap,
            onLongPressStart: onLongPressStart,
            onLongPressMove: onLongPressMove,
            onLongPressEnd: onLongPressEnd
        ))
    }
}

private struct TapAndLongPressModifier: ViewModifier {
    let minimumDuration: Double
    let coordinateSpace: CoordinateSpace
    let onTap: () -> Void
    let onLongPressStart: () -> Void
    let onLongPressMove: (CGPoint) -> Void
    let onLongPressEnd: (CGPoint?) -> Void

    /// `true` from the moment the long press is recognized until the finger is lifted.
    /// SwiftUI resets it both when the gesture ends and when the system cancels it,
    /// so the end callback can't be missed.
    @GestureState private var isLongPressing = false
    /// Last finger location during the long press. `nil` if the finger hasn't moved since recognition.
    @State private var location: CGPoint?

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            // The tap has to be attached before (inside) the long press, otherwise the long press swallows it.
            .onTapGesture { onTap() }
            .gesture(
                LongPressGesture(minimumDuration: minimumDuration)
                    // Keeps the gesture alive after recognition, so it ends only when the finger is lifted.
                    .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: coordinateSpace))
                    .updating($isLongPressing) { value, state, _ in
                        if case .second(true, _) = value {
                            state = true
                        }
                    }
                    .onChanged { value in
                        guard case .second(true, let drag?) = value else { return }
                        location = drag.location
                        onLongPressMove(drag.location)
                    }
            )
            .onChange(of: isLongPressing) { isLongPressing in
                if isLongPressing {
                    onLongPressStart()
                } else {
                    onLongPressEnd(location)
                    location = nil
                }
            }
    }
}
