/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ViewController.swift                                                                  Geometries ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Sep25/15 ... Copyright 2015-17 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable large_tuple
// swiftlint:disable variable_name
// swiftlint:disable statement_position

import SceneKit
import SatKit

let  AnnArborLatitude = +42.2755
let AnnArborLongitude = -83.7521
let  AnnArborAltitude =   0.1

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ Dimensions (Kms):                                                                                ┃
  ┃             Earth Radius:   6,378                                                                ┃
  ┃     Geostationary Radius:  42,164                                                                ┃
  ┃      Camera Point Radius: 120,000                                                                ┃
  ┃        Moon Orbit Radius: 385,000                                                                ┃
  ┃                                                                                                  ┃
  ┃     •---------•---------•---------•---------•---------•---------•---------•---------•---------•  ┃
  ┃    120       100       80        60        40        20         0       -20       -40       -60  ┃
  ┃     0864208642086420864208642086420864208642086420864208642086420864208642086420864208642086420  ┃
  ┃     C                   N                  |                 |EEEEE|                          F  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

let Rₑ: CGFloat = 6.378135e3                 // equatorial radius (polar radius = 6356.752 Kms)
let π: CGFloat = 3.1415926e0                 // for now

class ViewController: NSViewController, SCNSceneRendererDelegate {

    @IBOutlet weak var totalView: SceneView!

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ "viewDidLoad" (10.10+), called once,                                                             │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController.viewDidLoad()")

        construct(scene: totalView)
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ "viewDidAppear" (10.10+), called once,                                                           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func viewDidAppear() {
        super.viewDidAppear()
        print("ViewController.viewDidAppear()")

        totalView.delegate = self
        totalView.isPlaying = true
    }

// MARK: - Rendering callback delegate ..

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃  SCNSceneRendererDelegate calls : sixty per second which is far too fast for our needs ..        ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

    var frameCount = 0
    var satelliteIterator = satellites.makeIterator()

    open func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        guard let earthNode = totalView.scene?.rootNode.childNode(withName: "earth",
                                                                  recursively: true) else { return }

//        if frameCount % 5 == 2 {                // twelve times a second, off the beat
//
//            if let frameNode = totalView.scene?.rootNode.childNode(withName: "frame",
//                                                                   recursively: true) {
//                if let (_, nextSatellite) = satelliteIterator.next() {
//                    addSatellite(frameNode, sat:nextSatellite)
//                }
//                else {
//                    satelliteIterator = satellites.makeIterator()
//                }
//
//            }
//
//        }

        if frameCount % 60 == 0 {               // once a second

            if let frameNode = totalView.scene?.rootNode.childNode(withName: "frame",
                                                                   recursively: true) {

                if let satellite = satellites["25544"] {
                    addSatellite(frameNode, sat:satellite)
                }

            }

        }

        if frameCount % 300 == 0 {              // every five seconds
            earthNode.eulerAngles.z = CGFloat(ZeroMeanSiderealTime(julianDaysNow()) * deg2rad)
        }

        if frameCount % 3600 == 0 {             // once a minute
            if let solarNode = totalView.scene?.rootNode.childNode(withName: "solar",
                                                                   recursively: true) {

                let sunVector = solarCel(julianDays: julianDaysNow())
                solarNode.position = SCNVector3((-sunVector.x, -sunVector.y, -sunVector.z))
            }

            frameCount = 0
        }

        frameCount += 1

    }

    open func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {

    }

    open func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {

    }

}
