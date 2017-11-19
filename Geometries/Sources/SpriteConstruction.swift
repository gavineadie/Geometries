/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SpriteConstruction.swift                                                              Geometries ║
  ║ Created by Gavin Eadie on Jul21/17  ..  Copyright © 2017 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import SpriteKit
//import SatKit

func constructSpriteView() -> OverlayScene {

    let overlay = OverlayScene(size: CGSize(width: 600, height: 600))

    let baseNode = SKNode()
    baseNode.name = "BASE"
    overlay.addChild(baseNode)

    let cred = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
    cred.fontSize = 12.0
    cred.position = CGPoint(x: 300, y: 580)
    cred.name = "CRED"
    cred.text = "SatKit.version"
    baseNode.addChild(cred)

    let rectNodeA = SKSpriteNode(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), size: CGSize(width: 80, height: 80))
    rectNodeA.position = CGPoint(x: 50, y: 50)
    rectNodeA.name = "BotL"
    overlay.addChild(rectNodeA)

    let rectNodeB = SKSpriteNode(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), size: CGSize(width: 80, height: 80))
    rectNodeB.position = CGPoint(x: 550, y: 50)
    rectNodeB.name = "BotR"
    overlay.addChild(rectNodeB)

    let rectNodeC = SKSpriteNode(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), size: CGSize(width: 80, height: 80))
    rectNodeC.position = CGPoint(x: 50, y: 550)
    rectNodeC.name = "TopL"
    overlay.addChild(rectNodeC)

    let rectNodeD = SKSpriteNode(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), size: CGSize(width: 80, height: 80))
    rectNodeD.position = CGPoint(x: 550, y: 550)
    rectNodeD.name = "TopR"
    overlay.addChild(rectNodeD)

    let word = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
    word.position = CGPoint(x: 300, y: 10)
    word.name = "WORD"
    word.text = "Geometries"
    baseNode.addChild(word)

    return overlay
}
