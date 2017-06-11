/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ OverlayScene.swift                                                                    Geometries ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Feb25/15 ... Copyright 2015-17 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable statement_position

import SpriteKit

class OverlayScene: SKScene {

    override func mouseUp(with theEvent: NSEvent) {

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
