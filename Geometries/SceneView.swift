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

    var startPoint = CGPointMake(0, 0)

    var latAngle = 0.0
    var lonAngle = 0.0

    @IBAction func swipeAction(sender: NSPanGestureRecognizer) {

        let viewPoint = sender.locationInView(self)     // Get the location in the view

        switch sender.state {

        case .Began:

            startPoint = viewPoint
            return

        case .Changed:

            let latAngle = (startPoint.y - viewPoint.y) / 3.0
            let lonAngle = (startPoint.x - viewPoint.x) / 3.0

            if let scene = self.scene,
               let camraNode = scene.rootNode.childNodeWithName("camra", recursively: true) {

                camraNode.position = SCNVector3Make(120_000, lonAngle * 1000, latAngle * 1000)

            }

            return

        case .Ended:

        //  startPoint = CGPointMake(0, 0)
            return

        default: return

        }
    }

    @IBAction func clickAction(sender: NSClickGestureRecognizer) {

        let viewPoint = sender.locationInView(self)     // Get the location in the view

        Swift.print("     SceneView: clickAction - viewPoint \(viewPoint)")

    }

    @IBAction func scaleAction(sender: NSMagnificationGestureRecognizer) {

        let viewPoint = sender.locationInView(self)     // Get the location in the view

        Swift.print("     SceneView: scaleAction - viewPoint \(viewPoint)")
        
    }

}