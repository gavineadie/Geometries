//
//  OverlayScene.swift
//  Geometries
//
//  Created by Gavin Eadie on 2/25/16.
//  Copyright © 2016 Gavin Eadie. All rights reserved.
//

import SpriteKit

class OverlayScene : SKScene {

    override func didMoveToView(view: SKView) {

        print("  OverlayScene: didMoveToView \(view)")

    }

    override func update(currentTime: NSTimeInterval) {

        print("  OverlayScene: currentTime \(currentTime)")

    }

    // NSResponder

    override func mouseUp(theEvent: NSEvent) {

        print("  OverlayScene: mouseUp event at \(theEvent.locationInWindow)")

        let location = theEvent.locationInNode(self)
        let node = self.nodeAtPoint(location)

        print("  OverlayScene: node hit is \(node)")

        if node.name == "touch" {

            print("  OverlayScene: SKNode 'touch' interactive (click inside)")

        }
        else {

            print("  OverlayScene: SKNode 'touch' interactive (click missed)")

        }

    }

}