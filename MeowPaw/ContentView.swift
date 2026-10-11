import SwiftUI

enum Palette {
    static let cream = Color(red: 0.99, green: 0.965, blue: 0.925)
    static let ink = Color(red: 0.29, green: 0.21, blue: 0.19)
    static let muted = Color(red: 0.45, green: 0.34, blue: 0.30)
    static let paws = [Color(red: 0.91, green: 0.59, blue: 0.60), Color(red: 0.88, green: 0.66, blue: 0.43), Color(red: 0.60, green: 0.72, blue: 0.61), Color(red: 0.72, green: 0.64, blue: 0.80)]
}

struct ContentView: View {
    @State private var playback = PlaybackController()
    @State private var showAbout = false
    @State private var labels = PawLabels()
    @State private var editing: PawSound?
    @Environment(\.scenePhase) private var phase
    @Environment(\.dynamicTypeSize) private var textSize
    var body: some View {
        GeometryReader { geometry in
            let compact = geometry.size.height < 700
            ScrollView {
                VStack(spacing: compact ? 12 : 22) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("喵喵喵").font(.largeTitle.weight(.bold)).accessibilityAddTraits(.isHeader)
                            Text("把心意，放在小爪里").font(.subheadline).foregroundStyle(Palette.muted)
                        }
                        Spacer()
                        Button { showAbout = true; playback.stop() } label: {
                            Image(systemName: "info.circle").font(.title3).frame(width: 44, height: 44)
                        }.accessibilityLabel("关于喵喵喵与音源").accessibilityIdentifier("about")
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "hand.tap")
                        Text("轻点听喵叫 · 再点停止 · 长按改文字")
                    }.font(.footnote).foregroundStyle(Palette.muted)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: textSize.isAccessibilitySize ? 2 : 3), spacing: compact ? 10 : 14) {
                        ForEach(PawSound.all) { sound in
                            PawButton(sound: sound, label: labels.label(for: sound), edit: { playback.stop(); editing = sound }, active: playback.activeID == sound.id, ready: playback.soundsReady, compact: compact, height: min(154, max(76, (geometry.size.height - (compact ? 270 : 340)) / 4))) { playback.tap(sound) }
                        }
                    }
                    VStack(spacing: 6) {
                        Text(playback.message ?? (playback.activeID == nil ? "挑一只小爪，送一句心意" : "喵～ 再点当前小爪可停止"))
                            .font(.footnote).foregroundStyle(Palette.muted).accessibilityIdentifier("playback-status")
                        if !compact { Text("今天也想和你亲近一点").font(.caption).foregroundStyle(Palette.muted) }
                    }
                    .frame(maxWidth: .infinity)
                }.padding(.horizontal, compact ? 16 : 22).padding(.top, compact ? 12 : 20).padding(.bottom, compact ? 16 : 24)
            }.scrollIndicators(.hidden)
        }
        .background(Palette.cream.ignoresSafeArea())
        .foregroundStyle(Palette.ink).tint(Palette.ink)
        .preferredColorScheme(.light)
        .sensoryFeedback(.selection, trigger: playback.tapCount)
        .onChange(of: phase) { if phase != .active { playback.stop() } }
        .onChange(of: playback.message) {
            if let message = playback.message { AccessibilityNotification.Announcement(message).post() }
        }
        .sheet(isPresented: $showAbout) { AboutView() }
        .sheet(item: $editing) { sound in
            LabelEditor(text: labels.label(for: sound)) { labels.save($0, for: sound) }
        }
    }
}

struct PawButton: View {
    let sound: PawSound
    let label: String
    let edit: () -> Void
    let active: Bool
    let ready: Bool
    let compact: Bool
    let height: CGFloat
    let action: () -> Void
    @State private var lastLongPress = Date.distantPast
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var textSize
    var body: some View {
        Button {
            if Date().timeIntervalSince(lastLongPress) > 0.8 { action() }
        } label: {
            VStack(spacing: compact ? 6 : 10) {
                ZStack {
                    PawPrint().fill(Palette.paws[sound.id / 3])
                    if active { Image(systemName: "stop.fill").font(.title3).foregroundStyle(Palette.ink).offset(y: 15) }
                }.frame(width: compact ? 55 : 76, height: compact ? 52 : 72).accessibilityHidden(true)
                Text(label).font(.headline).multilineTextAlignment(.center)
                    .lineLimit(textSize.isAccessibilitySize ? 3 : 2).minimumScaleFactor(0.65)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: textSize.isAccessibilitySize ? 150 : height)
            .padding(.vertical, 6)
            .background(active ? .white : .white.opacity(0.58), in: .rect(cornerRadius: 26))
            .overlay { RoundedRectangle(cornerRadius: 26).strokeBorder(active ? Palette.ink : Palette.paws[sound.id / 3].opacity(0.25), lineWidth: active ? 2 : 1) }
            .contentShape(.rect)
        }
        .buttonStyle(PawPressStyle(reduceMotion: reduceMotion))
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded { _ in
            lastLongPress = Date(); edit()
        })
        .accessibilityLabel(label)
        .accessibilityValue(active ? "正在播放" : "已停止")
        .accessibilityHint(active ? "再次轻点停止，长按编辑文字" : (ready ? "轻点播放猫叫，长按编辑文字" : "声音暂不可用，长按编辑文字"))
        .accessibilityInputLabels([label])
        .accessibilityAction(named: "编辑文字", edit)
        .accessibilityIdentifier("paw-\(sound.id)")
    }
}

struct PawPrint: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.addEllipse(in: CGRect(x: w * 0.02, y: h * 0.20, width: w * 0.21, height: h * 0.29))
        p.addEllipse(in: CGRect(x: w * 0.25, y: 0, width: w * 0.22, height: h * 0.32))
        p.addEllipse(in: CGRect(x: w * 0.53, y: 0, width: w * 0.22, height: h * 0.32))
        p.addEllipse(in: CGRect(x: w * 0.77, y: h * 0.20, width: w * 0.21, height: h * 0.29))
        p.move(to: CGPoint(x: w * 0.5, y: h * 0.37))
        p.addCurve(to: CGPoint(x: w * 0.16, y: h * 0.79), control1: CGPoint(x: w * 0.34, y: h * 0.35), control2: CGPoint(x: w * 0.14, y: h * 0.62))
        p.addCurve(to: CGPoint(x: w * 0.5, y: h * 0.94), control1: CGPoint(x: w * 0.19, y: h * 1.05), control2: CGPoint(x: w * 0.39, y: h * 0.96))
        p.addCurve(to: CGPoint(x: w * 0.84, y: h * 0.79), control1: CGPoint(x: w * 0.61, y: h * 0.96), control2: CGPoint(x: w * 0.81, y: h * 1.05))
        p.addCurve(to: CGPoint(x: w * 0.5, y: h * 0.37), control1: CGPoint(x: w * 0.86, y: h * 0.62), control2: CGPoint(x: w * 0.66, y: h * 0.35))
        p.closeSubpath()
        return p
    }
}

struct PawPressStyle: ButtonStyle {
    let reduceMotion: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed && !reduceMotion ? 0.94 : 1)
            .opacity(configuration.isPressed ? 0.75 : 1)
            .animation(reduceMotion ? nil : .spring(response: 0.22, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

@MainActor @Observable final class PawLabels {
    private var values: [String: String]
    private let defaults: UserDefaults
    private static let key = "customPawLabels.v1"
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        values = defaults.dictionary(forKey: Self.key) as? [String: String] ?? [:]
    }
    func label(for sound: PawSound) -> String { values[String(sound.id)] ?? sound.label }
    func save(_ text: String, for sound: PawSound) {
        let clean = String(text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(60))
        guard !clean.isEmpty else { return }
        values[String(sound.id)] = clean
        defaults.set(values, forKey: Self.key)
    }
}

struct LabelEditor: View {
    @State var text: String
    let save: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Form {
                Section("给这只小爪一句话") {
                    TextField("输入你想说的话", text: $text, axis: .vertical)
                        .lineLimit(2...4).accessibilityIdentifier("label-input")
                        .onChange(of: text) { if text.count > 60 { text = String(text.prefix(60)) } }
                    Button("清空文字") { text = "" }.accessibilityIdentifier("clear-label")
                    Text("只修改文字，猫叫声保持原样。最多 60 个字。")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("编辑文字").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }.accessibilityIdentifier("cancel-label")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save(text); dismiss() }
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .accessibilityIdentifier("save-label")
                }
            }
        }.tint(Palette.ink)
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("一点小心意") {
                    Text("喵喵喵是一款猫声娱乐小玩具。按钮文字是你的心意，不是猫语翻译，也不代表猫能理解这些词。")
                    Text("真实录音离线播放，无录音、登录或网络请求。尊重猫咪的反应，轻声玩一会儿就好。")
                }
                Section("音源与录制场景") {
                    Text("12 段来自不同真实录音：短喵、颤音、轻啾、呼噜。排除独处场景；按钮是主人对猫说的话，录制情境只作素材参考。")
                    Text("9 条 Freesound CC0 录音；3 条 CatMeows 等饭录音（米兰大学 Ludovico 等团队，限非商业）。出处、致谢与剪辑记录见源码 Research。")
                    Text("素材未经独立听审，请结合自家猫的反应选择。")
                }
                Section("声音习惯") { Text("默认较轻音量，不自动循环。静音模式下保持安静；离开 App 即停止播放。") }
            }.navigationTitle("关于喵喵喵").toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() }.accessibilityIdentifier("close-about") }
            }
        }.tint(Palette.ink)
    }
}
