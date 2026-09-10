//
//  ContentView.swift
//  long-tap
//
//  Created by Rookly on 10.09.2026.
//

import SwiftUI

struct ContentView: View {
    /// How far outside the bin's frame the finger still counts as being over the bin.
    private let binHitSlop: CGFloat = 120

    @State private var isRecording = false
    /// 0 when the finger is out of range, grows to 1 as it reaches the bin.
    @State private var binProximity: CGFloat = 0
    @State private var binFrame: CGRect = .zero
    @State private var log = "Hold the mic to record"

    var body: some View {
        VStack(spacing: 24) {
            Text(log)
            HStack {
                Image(systemName: "trash")
                    .font(.title2)
                    .foregroundColor(binProximity > 0.5 ? .white : .red)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(Color.red.opacity(0.15 + 0.85 * binProximity)))
                    .scaleEffect(isOverBin ? 1.2 : 1)
                    .opacity(isRecording ? 1 : 0)
                    .onFrameChange { binFrame = $0 }

                Spacer()

                Image(systemName: "mic.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(isRecording ? Color.red : Color.accentColor))
                    .scaleEffect(isRecording ? 1.3 : 1)
                    .onTapAndLongPress(
                        onTap: {
                            log = "Hold the mic to record"
                        },
                        onLongPressStart: {
                            isRecording = true
                            log = "Recording…"
                        },
                        onLongPressMove: { location in
                            binProximity = proximity(of: location, to: binFrame)
                        },
                        onLongPressEnd: { _ in
                            // Decide by isOverBin, so the action always matches the bin highlight.
                            if isOverBin {
                                log = "Voice message cancelled"
                            } else {
                                log = "Voice message sent"
                            }
                            isRecording = false
                            binProximity = 0
                        }
                    )
            }
            .animation(.spring(), value: isRecording)
            .animation(.spring(), value: isOverBin)
        }
        .padding()
    }

    private var isOverBin: Bool {
        binProximity > 0
    }

    /// 1 when the finger is on the bin, falls linearly to 0 at `binHitSlop` away from its frame.
    private func proximity(of location: CGPoint, to frame: CGRect) -> CGFloat {
        let dx = max(frame.minX - location.x, 0, location.x - frame.maxX)
        let dy = max(frame.minY - location.y, 0, location.y - frame.maxY)
        let distance = hypot(dx, dy)
        return max(0, 1 - distance / binHitSlop)
    }
}

#Preview {
    ContentView()
}
