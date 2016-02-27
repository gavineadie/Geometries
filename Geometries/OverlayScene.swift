//
//  OverlayScene.swift
//  Geometries
//
//  Created by Gavin Eadie on 2/25/16.
//  Copyright © 2016 Gavin Eadie. All rights reserved.
//

import SpriteKit

class OverlayScene : SKScene {

    override init(size: CGSize) {
        super.init(size: size)

        let labelNode = SKLabelNode(text: "SpriteKit Overlay")
        labelNode.name = "label"
        labelNode.fontSize = 36
        labelNode.fontColor = SKColor.greenColor()
        labelNode.horizontalAlignmentMode = .Left
        labelNode.position = CGPointMake(20, 30)

        self.addChild(labelNode)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}