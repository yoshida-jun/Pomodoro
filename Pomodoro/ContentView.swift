//
//  ContentView.swift
//  Pomodoro
//
//  Created by jun on 2026/03/12.
//

import SwiftUI

enum TimerMode {
    case work, shortBreak, longBreak

    var duration: Int {
        switch self {
        case .work: return 25 * 60
        case .shortBreak: return 5 * 60
        case .longBreak: return 15 * 60
        }
    }

    var label: String {
        switch self {
        case .work: return "作業"
        case .shortBreak: return "短い休憩"
        case .longBreak: return "長い休憩"
        }
    }

    var color: Color {
        switch self {
        case .work: return .red
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }
}

struct ContentView: View {
    @State private var mode: TimerMode = .work
    @State private var secondsLeft: Int = TimerMode.work.duration
    @State private var isRunning = false
    @State private var completedPomodoros = 0
    @State private var timer: Timer? = nil

    var progress: Double {
        1.0 - Double(secondsLeft) / Double(mode.duration)
    }

    var timeString: String {
        let m = secondsLeft / 60
        let s = secondsLeft % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        VStack(spacing: 32) {
            // モード選択
            Picker("モード", selection: $mode) {
                Text("作業").tag(TimerMode.work)
                Text("短い休憩").tag(TimerMode.shortBreak)
                Text("長い休憩").tag(TimerMode.longBreak)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .onChange(of: mode) { newMode in
                reset(to: newMode)
            }

            // タイマー円
            ZStack {
                Circle()
                    .stroke(mode.color.opacity(0.2), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(mode.color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
                Text(timeString)
                    .font(.system(size: 64, weight: .thin, design: .monospaced))
            }
            .frame(width: 260, height: 260)
            .padding()

            // ポモドーロ数
            HStack(spacing: 8) {
                ForEach(0..<4) { i in
                    Image(systemName: i < completedPomodoros % 4 ? "circle.fill" : "circle")
                        .foregroundColor(.red)
                }
            }

            // コントロール
            HStack(spacing: 40) {
                Button(action: { reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                }
                .foregroundColor(.secondary)

                Button(action: toggle) {
                    Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(mode.color)
                }

                Button(action: skip) {
                    Image(systemName: "forward.end")
                        .font(.title2)
                }
                .foregroundColor(.secondary)
            }

            Text("\(completedPomodoros) ポモドーロ完了")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    func toggle() {
        if isRunning {
            timer?.invalidate()
            timer = nil
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if secondsLeft > 0 {
                    secondsLeft -= 1
                } else {
                    complete()
                }
            }
        }
        isRunning.toggle()
    }

    func reset(to newMode: TimerMode? = nil) {
        timer?.invalidate()
        timer = nil
        isRunning = false
        let target = newMode ?? mode
        secondsLeft = target.duration
    }

    func skip() {
        complete()
    }

    func complete() {
        timer?.invalidate()
        timer = nil
        isRunning = false

        if mode == .work {
            completedPomodoros += 1
            mode = completedPomodoros % 4 == 0 ? .longBreak : .shortBreak
        } else {
            mode = .work
        }
        secondsLeft = mode.duration
    }
}

#Preview {
    ContentView()
}
