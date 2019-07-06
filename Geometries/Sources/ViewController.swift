/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ViewController.swift                                                                  Geometries ║
  ║ Created by Gavin Eadie on Sep25/15 ... Copyright 2015-17 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable identifier_name

import SceneKit
import SatelliteKit

let  AnnArborLatitude = +42.2755
let AnnArborLongitude = -83.7521
let  AnnArborAltitude =   0.1       // Kms
let  AnnArborLocation = Vector(AnnArborLatitude, AnnArborLongitude, AnnArborAltitude)

class ViewController: NSViewController, SCNSceneRendererDelegate {

    var sceneNode = SCNNode()               // set in "viewDidLoad()" after scene constructed ..
    var frameNode = SCNNode()

    lazy fileprivate var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone(abbreviation: "EDT")
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    @IBOutlet weak var sceneView: SceneView!

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ "viewDidLoad" (macOS 10.10+), called once,                                                       │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func viewDidLoad() {
        super.viewDidLoad()

        if Debug.views { print("     OrbitViewController| viewDidLoad()") }
        if Debug.clock { FakeClock.shared.reset() }

        let scene = SCNScene()
        scene.background.contents = "TychoSkymap"
//        scene.background.contents = ["xpos2048", "xneg2048",
//                                     "ypos2048", "yneg2048",
//                                     "zpos2048", "zneg2048"]
//        scene.background.contents = ["Tile+X", "Tile-X", "Tile+Y", "Tile-Y", "Tile+Z", "Tile-Z"]

        sceneView.scene = scene
        sceneView.backgroundColor = #colorLiteral(red: 0.0, green: 0.0, blue: 0.5, alpha: 1)
        sceneView.overlaySKScene = constructSpriteView()

        if Debug.scene { dumpNode(sceneView.scene!.rootNode) }

        sceneNode = (sceneView.scene?.rootNode)!
        sceneNode.name = "scene"
        if Debug.scene { dumpNode(sceneNode) }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ .. make the inertial frame and contents                                                          ┆
  ┆                                   "frame" ( "solar" , "earth" ( "globe" , "grids" , "coast" ))   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        frameNode = makeFrame()
        if Debug.scene { dumpNode(frameNode) }
        sceneNode <<< frameNode

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ .. and attach "viewr" (with a "camra" node) to "scene" ..                                        ┆
  ┆                                                                 "scene" ( "viewr" ( "camra" ))   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let viewpointNode = makeViewpoint()
        sceneNode <<< viewpointNode

        let cameraConstraint = SCNLookAtConstraint(target: frameNode)
        cameraConstraint.isGimbalLockEnabled = true
        viewpointNode.childNodes[0].constraints = [cameraConstraint]

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆  .. sets some properties on the window's NSView (SceneView) including an overlayed SpriteKit     ┆
  ┆     placard which will display data and take hits.                                               ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆  .. start the model driving timer                                                                ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        _ = SceneDynamics(sceneNode: sceneNode)
}

    override func viewWillAppear() {
        super.viewWillAppear()
        if Debug.views { print("     OrbitViewController| viewWillAppear()") }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ .. once every seconds: update the time placard                                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
//        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "OneSecond"),
//                                               object: nil, queue: nil, using: {_ in
//                if self.satelliteTime != nil {
//                    DispatchQueue.main.async {
//                        self.satelliteTime.text = self.dateFormatter.string(from: FakeClock.shared.date())
//                    }
//                }
//        })

	}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ "viewDidAppear" (10.10+), called once,                                                           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func viewDidAppear() {
        super.viewDidAppear()
        if Debug.views { print("     OrbitViewController| viewDidAppear()") }
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ UIKit actions ..                                                                                 │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
//    @IBAction func tapCenterObs(_ sender: UIButton) {
//        if Debug.views { print("     OrbitViewController| tapCenterObs()") }
//    }
//
//    @IBAction func tapCenterISS(_ sender: UIButton) {
//        if Debug.views { print("     OrbitViewController| tapCenterISS()") }
//    }

}

public func dumpNode(_ node: SCNNode) {
    print(node.debugDescription)
    for child in node.childNodes {
        dumpNode(child)
    }
}
