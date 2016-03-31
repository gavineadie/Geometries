//
//  SceneView.swift
//  Geometries
//
//  Created by Gavin Eadie on 2/27/16.
//  Copyright © 2016 Gavin Eadie. All rights reserved.
//

import Cocoa
import SceneKit

class SceneView : SCNView {

    var prevXRatio: CGFloat = 0
    var prevYRatio: CGFloat = 0

    @IBAction func swipeAction(sender: NSPanGestureRecognizer) {

        if let view = sender.view {

            let xyMovement = sender.translationInView(view)

            let xRatio = prevXRatio + xyMovement.x / view.frame.size.width
            let yRatio = prevYRatio + xyMovement.y / view.frame.size.height

            Swift.print("     SceneView: swipeAction - xyMovement \(xyMovement); xRatio \(xRatio), yRatio \(yRatio)")

            if let scene = self.scene,
                let orbitNode = scene.rootNode.childNodeWithName("orbit", recursively: true) {

                orbitNode.eulerAngles.y = (-2 * π) * xRatio
                orbitNode.eulerAngles.z = (  -π  ) * yRatio

            }

            if (sender.state == .Ended) {
                prevXRatio = xRatio % 1
                prevYRatio = yRatio % 1
            }

        }

    }

    @IBAction func clickAction(sender: NSClickGestureRecognizer) {

        if let scene = self.scene,
            let orbitNode = scene.rootNode.childNodeWithName("orbit", recursively: true) {

            orbitNode.eulerAngles.y = 0
            orbitNode.eulerAngles.z = 0

        }

    }

    @IBAction func scaleAction(sender: NSMagnificationGestureRecognizer) {

        let viewPoint = sender.locationInView(self)     // Get the location in the view

        Swift.print("     SceneView: scaleAction - viewPoint \(viewPoint)")
        
    }

}