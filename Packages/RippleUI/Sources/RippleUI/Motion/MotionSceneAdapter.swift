import SwiftUI

#if os(iOS) && !targetEnvironment(simulator)
import UIKit

/// Reads the hosting scene, so rotation lock and separate iPad windows are respected.
private struct MotionSceneAdapter: UIViewRepresentable {
    let controller: GravityTiltController

    func makeUIView(context: Context) -> SceneProbe {
        let view = SceneProbe()
        view.controller = controller
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ view: SceneProbe, context: Context) {
        view.controller = controller
        controller.windowScene = view.window?.windowScene
    }

    final class SceneProbe: UIView {
        weak var controller: GravityTiltController?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            controller?.windowScene = window?.windowScene
        }
    }
}
#endif

extension View {
    public func rippleMotionScene(_ controller: GravityTiltController) -> some View {
        #if os(iOS) && !targetEnvironment(simulator)
        background { MotionSceneAdapter(controller: controller).accessibilityHidden(true) }
        #else
        self
        #endif
    }
}
