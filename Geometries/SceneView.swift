/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SceneView.swift                                                                       Geometries ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Feb27/15 ... Copyright 2015-17 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Cocoa
import SceneKit

class SceneView: SCNView {

    lazy var orbitNode: SCNNode! = self.scene!.rootNode.childNode(withName: "orbit", recursively: true)
    lazy var camraNode: SCNNode! = self.scene!.rootNode.childNode(withName: "camra", recursively: true)

    var prevXRatio: CGFloat = 0.0
    var prevYRatio: CGFloat = 0.0

    @IBAction func swipeAction(_ sender: NSPanGestureRecognizer) {

        if let view = sender.view {

            let xyMovement = sender.translation(in: view)

            let xRatio = prevXRatio + xyMovement.x / view.frame.size.width
            let yRatio = prevYRatio + xyMovement.y / view.frame.size.height

            orbitNode.eulerAngles.x =  ( π ) * yRatio       // screen height is π (±90°) rotation
            orbitNode.eulerAngles.y = -(2*π) * xRatio       // screen width is 2π (360°) rotation

            if sender.state == .ended {
                prevXRatio = xRatio.truncatingRemainder(dividingBy: 1)
                prevYRatio = yRatio.truncatingRemainder(dividingBy: 1)
            }

        }

    }

    @IBAction func clickAction(_ sender: NSClickGestureRecognizer) {

        orbitNode.eulerAngles.x = 0
        orbitNode.eulerAngles.y = 0
        orbitNode.eulerAngles.z = 0

        prevXRatio = 0.0
        prevYRatio = 0.0

    }

    @IBAction func scaleAction(_ sender: NSMagnificationGestureRecognizer) {

        Swift.print("     SceneView: scaleAction - viewPoint \(sender.magnification)")

        camraNode.position.z *= (sender.magnification + 1.0)

    }

}
