//
//  OverlayScene.swift
//  Geometries
//
//  Created by Gavin Eadie on 2/25/16.
//  Copyright © 2016 Gavin Eadie. All rights reserved.
//

import SpriteKit

class OverlayScene : SKScene {

    override func didMove(to view: SKView) {

        print("  OverlayScene: didMoveToView \(view)")

    }

    override func update(_ currentTime: TimeInterval) {

    }

    // NSResponder

    override func mouseUp(_ theEvent: NSEvent) {

        print("  OverlayScene: mouseUp event at \(theEvent.locationInWindow)")

        let location = theEvent.location(in: self)
        let node = self.atPoint(location)

        print("  OverlayScene: node hit is \(node)")

        if node.name == "touch" {

            print("  OverlayScene: SKNode 'touch' interactive (click inside)")

        }
        else {

            print("  OverlayScene: SKNode 'touch' interactive (click missed)")

        }

    }

}
