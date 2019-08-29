/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SceneView.swift                                                                       Geometries ║
  ║ Created by Gavin Eadie on Feb27/15 ... Copyright 2015-19 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Cocoa
import SceneKit

class SceneView: SCNView {

    lazy var orbitNode: SCNNode! = self.scene!.rootNode.childNode(withName: "viewr", recursively: true)
    lazy var camraNode: SCNNode! = self.scene!.rootNode.childNode(withName: "camra", recursively: true)

    var prevXRatio: CGFloat = 0.0
    var prevYRatio: CGFloat = 0.0

    var prevFieldV: CGFloat = 7.5

    @IBAction func swipeAction(_ sender: NSPanGestureRecognizer) {

        if let view = sender.view {

            let xyMovement = sender.translation(in: view)

            let xRatio = prevXRatio + xyMovement.x / view.frame.size.width
            let yRatio = prevYRatio + xyMovement.y / view.frame.size.height

            orbitNode.eulerAngles.x =  ( CGFloat.π ) * yRatio       // screen height is π (±90°) rotation
            orbitNode.eulerAngles.y = -(2*CGFloat.π) * xRatio       // screen width is 2π (360°) rotation

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

        prevFieldV = 7.5

        if #available(iOS 11.0, OSX 10.13, *) {
            camraNode.camera?.fieldOfView = prevFieldV
        } else {
            camraNode.camera?.xFov = Double(prevFieldV)
            camraNode.camera?.yFov = Double(prevFieldV)
        }

    }

    @IBAction func scaleAction(_ sender: NSMagnificationGestureRecognizer) {

        var fieldOfView = prevFieldV - (sender.magnification * 4.0)
        fieldOfView = min(max(fieldOfView, 2.0), 30.0)

        if #available(iOS 11.0, OSX 10.13, *) {
            camraNode.camera?.fieldOfView = fieldOfView
        } else {
            camraNode.camera?.xFov = Double(fieldOfView)
            camraNode.camera?.yFov = Double(fieldOfView)
        }

        prevFieldV = fieldOfView
    }

}
