import SwiftUI
import AVFoundation

struct ExerciseVisualView: View {
    let visual: ExerciseVisual
    let position: Position
    let isActive: Bool

    var body: some View {
        ZStack {
            switch visual {
            case .video(let asset):
                if let asset, let url = videoURL(named: asset) {
                    LoopVideoView(url: url, showsBackdrop: true)
                } else {
                    PlaceholderAvatarView(position: position, motionKey: motionKey(for: visual), isActive: isActive)
                }
            case .model3D(let asset):
                if let asset, let url = Bundle.main.url(forResource: asset, withExtension: "usdz") {
                    Model3DView(url: url)
                } else {
                    PlaceholderAvatarView(position: position, motionKey: motionKey(for: visual), isActive: isActive)
                }
            case .avatar(let pose):
                PlaceholderAvatarView(
                    position: position,
                    motionKey: MotionKey(rawValue: pose) ?? .neutral,
                    isActive: isActive
                )
            }
        }
    }

    private func videoURL(named asset: String) -> URL? {
        return Bundle.main.url(forResource: asset, withExtension: "mp4")
    }

    private func motionKey(for visual: ExerciseVisual) -> MotionKey {
        guard case .avatar(let pose) = visual else { return .neutral }
        return MotionKey(rawValue: pose) ?? .neutral
    }
}

struct LoopVideoView: UIViewControllerRepresentable {
    let url: URL
    var showsBackdrop: Bool = false

    func makeUIViewController(context: Context) -> LoopVideoController {
        let controller = LoopVideoController(url: url, showsBackdrop: showsBackdrop)
        return controller
    }

    func updateUIViewController(_ uiViewController: LoopVideoController, context: Context) {}
}

final class LoopVideoController: UIViewController {
    private let mainPlayer: AVQueuePlayer
    private let mainLooper: AVPlayerLooper
    private let mainLayer: AVPlayerLayer
    private let backdropPlayer: AVQueuePlayer?
    private let backdropLayer: AVPlayerLayer?
    private let blurView: UIVisualEffectView?

    init(url: URL, showsBackdrop: Bool) {
        let mainItem = AVPlayerItem(url: url)
        mainPlayer = AVQueuePlayer()
        mainLooper = AVPlayerLooper(player: mainPlayer, templateItem: mainItem)
        mainLayer = AVPlayerLayer(player: mainPlayer)
        mainLayer.videoGravity = .resizeAspect
        mainLayer.backgroundColor = UIColor.clear.cgColor

        if showsBackdrop {
            let backdropItem = AVPlayerItem(url: url)
            backdropPlayer = AVQueuePlayer()
            _ = AVPlayerLooper(player: backdropPlayer!, templateItem: backdropItem)
            backdropLayer = AVPlayerLayer(player: backdropPlayer)
            backdropLayer?.videoGravity = .resizeAspectFill
            blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
        } else {
            backdropPlayer = nil
            backdropLayer = nil
            blurView = nil
        }

        super.init(nibName: nil, bundle: nil)
        mainPlayer.play()
        backdropPlayer?.play()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let backdropLayer {
            view.layer.addSublayer(backdropLayer)
        }
        if let blurView {
            view.addSubview(blurView)
        }
        view.layer.addSublayer(mainLayer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backdropLayer?.frame = view.bounds
        blurView?.frame = view.bounds
        mainLayer.frame = view.bounds
    }
}

struct Model3DView: View {
    let url: URL
    var body: some View {
        Text("3D: \(url.lastPathComponent)")
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

enum MotionKey: String {
    case neutral
    case chinTuck
    case decompression
    case hipFlexor
    case pelvicTilt
    case gluteSqueeze
}