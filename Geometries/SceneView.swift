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

    var prevXRatio: CGFloat = 0.0
    var prevYRatio: CGFloat = 0.0

    @IBAction func swipeAction(sender: NSPanGestureRecognizer) {

        if let view = sender.view {

            let xyMovement = sender.translationInView(view)

            let xRatio = prevXRatio + xyMovement.x / view.frame.size.width
            let yRatio = prevYRatio + xyMovement.y / view.frame.size.height

            if let totalscene = self.scene,
                let orbitNode = totalscene.rootNode.childNodeWithName("orbit", recursively: true) {

                orbitNode.eulerAngles.x =  ( π ) * yRatio       // screen height is π (±90°) rotation
                orbitNode.eulerAngles.y = -(2*π) * xRatio       // screen width is 2π (360°) rotation

            }

            if (sender.state == .Ended) {
                prevXRatio = xRatio % 1
                prevYRatio = yRatio % 1
            }

        }

    }

//    #else
//
// /*
//        ArcBall is imaginary sphere filling the window (ie radius = 300, for now)
//  */
//    @IBAction func swipeAction(sender: NSPanGestureRecognizer) {
//
//        var xyStart:CGPoint
//        var xyMoves:CGPoint
//        var firstMotion = true
//
//        if let view = sender.view {
//
//            if sender.state == .Began {
//
//                xyStart = sender.translationInView(view)
//                Swift.print("Start: \(xyStart)")
//
//            }
//
//            if sender.state == .Changed {
//
//                xyMoves = sender.translationInView(view)
//                Swift.print("Moves: \(xyMoves)")
//
//            }
//            
//            if sender.state == .Ended {
//
//            }
//
//        }
//        
//    }
//
//    #endif

    @IBAction func clickAction(sender: NSClickGestureRecognizer) {

        if let scene = self.scene,
            let orbitNode = scene.rootNode.childNodeWithName("orbit", recursively: true) {

            orbitNode.eulerAngles.x = 0
            orbitNode.eulerAngles.y = 0
            orbitNode.eulerAngles.z = 0

            prevXRatio = 0.0
            prevYRatio = 0.0

        }

    }

    @IBAction func scaleAction(sender: NSMagnificationGestureRecognizer) {

//      Swift.print("     SceneView: scaleAction - viewPoint \(sender.magnification)")
        
    }

}