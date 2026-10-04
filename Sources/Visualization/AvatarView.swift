import SwiftUI

struct PlaceholderAvatarView: View {
    let position: Position
    let motionKey: MotionKey
    let isActive: Bool

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let t = phase(at: timeline.date)
            AvatarFigure(
                pose: AvatarPose.compute(motionKey: motionKey, t: t, seeded: t),
                position: position
            )
        }
    }

    private func phase(at date: Date) -> Double {
        let base = date.timeIntervalSinceReferenceDate
        let period = AvatarPose.loopDuration(for: motionKey)
        return base.truncatingRemainder(dividingBy: period) / period
    }
}

struct AvatarPose {
    var head: CGPoint
    var neck: CGPoint
    var shoulder: CGPoint
    var elbow: CGPoint
    var hand: CGPoint
    var hip: CGPoint
    var knee: CGPoint
    var ankle: CGPoint

    static func loopDuration(for key: MotionKey) -> TimeInterval {
        switch key {
        case .chinTuck: return 4.0
        case .decompression: return 5.0
        case .hipFlexor: return 6.0
        case .pelvicTilt: return 5.0
        case .gluteSqueeze: return 4.0
        case .neutral: return 6.0
        }
    }

    static func compute(motionKey: MotionKey, t: Double, seeded: Double) -> AvatarPose {
        switch motionKey {
        case .chinTuck: return chinTuck(t: t)
        case .decompression: return decompression(t: t)
        case .hipFlexor: return hipFlexor(t: t)
        case .pelvicTilt: return pelvicTilt(t: t)
        case .gluteSqueeze: return gluteSqueeze(t: t)
        case .neutral: return standing(a: 0, pelvisTilt: 0, legBack: 0, lift: 0)
        }
    }

    private static func standing(a: Double, pelvisTilt: Double, legBack: Double, lift: Double) -> AvatarPose {
        var p = AvatarPose(
            head: CGPoint(x: 118, y: 52 - lift * 6),
            neck: CGPoint(x: 122, y: 86 - lift * 6),
            shoulder: CGPoint(x: 126, y: 98 - lift * 6),
            elbow: CGPoint(x: 152, y: 122 - lift * 6),
            hand: CGPoint(x: 150, y: 176 - lift * 6),
            hip: CGPoint(x: 124, y: 148),
            knee: CGPoint(x: 122, y: 214),
            ankle: CGPoint(x: 116, y: 268)
        )
        p = p.rotated(by: pelvisTilt, around: p.hip)
        p.head = p.head.offsetY(-a * 3).offsetX(a * 8)
        p.neck = p.neck.offsetY(-a * 3).offsetX(a * 6)
        p.shoulder = p.shoulder.offsetY(-a * 3)
        if legBack != 0 {
            p.knee = p.knee.offsetX(legBack * 14)
            p.ankle = p.ankle.offsetX(legBack * 26)
        }
        return p
    }

    private static func chinTuck(t: Double) -> AvatarPose {
        let a = (sin(2 * Double.pi * t) + 1) / 2
        return standing(a: a, pelvisTilt: 0, legBack: 0, lift: 0)
    }

    private static func decompression(t: Double) -> AvatarPose {
        let hold = Swift.min(t * 4, 1)
        let release = Swift.max(0, (t - 0.75) * 4)
        let a = hold - release * 0.6
        return standing(a: 0, pelvisTilt: 0, legBack: 0, lift: a)
    }

    private static func hipFlexor(t: Double) -> AvatarPose {
        let phase = t * 2 * Double.pi
        let pelvis = 10 * sin(phase) * -1
        let leg = (sin(phase) + 0.4) / 1.4
        return standing(a: 0, pelvisTilt: pelvis, legBack: leg, lift: 0)
    }

    private static func pelvicTilt(t: Double) -> AvatarPose {
        var p = AvatarPose(
            head: CGPoint(x: 124, y: 112),
            neck: CGPoint(x: 128, y: 142),
            shoulder: CGPoint(x: 130, y: 152),
            elbow: CGPoint(x: 160, y: 158),
            hand: CGPoint(x: 168, y: 186),
            hip: CGPoint(x: 128, y: 196),
            knee: CGPoint(x: 172, y: 206),
            ankle: CGPoint(x: 172, y: 268)
        )
        let tilt = 12 * sin(2 * Double.pi * t)
        return p.rotated(by: tilt, around: p.hip)
    }

    private static func gluteSqueeze(t: Double) -> AvatarPose {
        let a = (sin(2 * Double.pi * t) + 1) / 2
        return standing(a: 0, pelvisTilt: -6 * a, legBack: 0, lift: 0)
    }
}

private extension AvatarPose {
    func rotated(by degrees: Double, around pivot: CGPoint) -> AvatarPose {
        let rad = degrees * .pi / 180
        func rot(_ p: CGPoint) -> CGPoint {
            let dx = p.x - pivot.x
            let dy = p.y - pivot.y
            let x = dx * cos(rad) - dy * sin(rad) + pivot.x
            let y = dx * sin(rad) + dy * cos(rad) + pivot.y
            return CGPoint(x: x, y: y)
        }
        return AvatarPose(
            head: rot(head), neck: rot(neck), shoulder: rot(shoulder),
            elbow: rot(elbow), hand: rot(hand), hip: hip,
            knee: rot(knee), ankle: rot(ankle)
        )
    }
}

private extension CGPoint {
    func offsetX(_ dx: CGFloat) -> CGPoint { CGPoint(x: x + dx, y: y) }
    func offsetY(_ dy: CGFloat) -> CGPoint { CGPoint(x: x, y: y + dy) }
}

struct AvatarFigure: View {
    let pose: AvatarPose
    let position: Position

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width / 240, geo.size.height / 300)
            Canvas { context, _ in
                draw(&context)
            }
            .scaleEffect(s)
            .frame(width: 240, height: 300)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(24)
    }

    private func draw(_ context: inout GraphicsContext) {
        let color = Color.accentColor
        let groundY: CGFloat = 278

        var floor = Path()
        floor.move(to: CGPoint(x: 40, y: groundY))
        floor.addLine(to: CGPoint(x: 200, y: groundY))
        context.stroke(floor, with: .color(color.opacity(0.25)), lineWidth: 1)

        func bone(from: CGPoint, to: CGPoint, width: CGFloat = 11) {
            var p = Path()
            p.move(to: from)
            p.addLine(to: to)
            context.stroke(p, with: .color(color.opacity(0.9)), style: StrokeStyle(lineWidth: width, lineCap: .round))
        }

        func joint(_ p: CGPoint, r: CGFloat = 6) {
            context.fill(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)), with: .color(color))
        }

        bone(from: pose.ankle, to: pose.knee)
        bone(from: pose.knee, to: pose.hip)
        bone(from: pose.hip, to: pose.shoulder)
        bone(from: pose.shoulder, to: pose.neck)
        bone(from: pose.shoulder, to: pose.elbow, width: 9)
        bone(from: pose.elbow, to: pose.hand, width: 8)

        context.fill(
            Path(ellipseIn: CGRect(x: pose.head.x - 16, y: pose.head.y - 18, width: 32, height: 34)),
            with: .color(color)
        )

        joint(pose.neck, r: 5)
        joint(pose.shoulder, r: 7)
        joint(pose.hip, r: 8)
        joint(pose.knee, r: 6)
        joint(pose.ankle, r: 5)
        joint(pose.elbow, r: 5)
        joint(pose.hand, r: 5)
    }
}