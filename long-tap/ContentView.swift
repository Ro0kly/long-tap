//
//  ContentView.swift
//  long-tap
//
//  Created by Rookly on 10.09.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var isRecording = false
    @State private var isOverBin = false
    @State private var binFrame: CGRect = .zero
    @State private var log = "Hold the mic to record"

    var body: some View {
        VStack(spacing: 24) {
            Text(log)
            HStack {
                Image(systemName: "trash")
                    .font(.title2)
                    .foregroundColor(isOverBin ? .white : .red)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(isOverBin ? Color.red : Color.red.opacity(0.15)))
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
                            isOverBin = binFrame.contains(location)
                        },
                        onLongPressEnd: { location in
                            if let location, binFrame.contains(location) {
                                log = "Voice message cancelled"
                            } else {
                                log = "Voice message sent"
                            }
                            isRecording = false
                            isOverBin = false
                        }
                    )
            }
            .animation(.spring(), value: isRecording)
            .animation(.spring(), value: isOverBin)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
