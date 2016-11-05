//
//  ViewController.swift
//  Geometries
//
//  Created by Gavin Eadie on 9/25/15.
//  Copyright © 2015 Gavin Eadie. All rights reserved.
//

import Cocoa
import SceneKit
import SpriteKit

import SatKit

extension SCNVector3 {
    public init(_ t: (Double, Double, Double)) {
        x = CGFloat(t.0)
        y = CGFloat(t.1)
        z = CGFloat(t.2)
    }
}

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Dimensions (Kms):                                                                                ║
  ║             Earth Radius:   6,378                                                                ║
  ║     Geostationary Radius:  42,164                                                                ║
  ║      Camera Point Radius: 120,000                                                                ║
  ║        Moon Orbit Radius: 385,000                                                                ║
  ║                                                                                                  ║
  ║     •---------•---------•---------•---------•---------•---------•---------•---------•---------•  ║
  ║    120       100       80        60        40        20         0       -20       -40       -60  ║
  ║     0864208642086420864208642086420864208642086420864208642086420864208642086420864208642086420  ║
  ║     C                   N                  |                 |EEEEE|                          F  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

let Rₑ:CGFloat = 6.378135e3                 // equatorial radius (polar radius = 6356.752 Kms)
let π:CGFloat = 3.1415926e0                 // for now

class ViewController: NSViewController, SCNSceneRendererDelegate {

    @IBOutlet weak var totalView: SceneView!

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ "viewDidLoad" (10.10+), called once,                                                             ┃
  ┃  .. sets some properties on the window's NSView (SceneView) including an overlayed SpriteKit     ┃
  ┃     placard (which will display data).                                                           ┃
  ┃  .. gets the rootNode in that SceneView ("total") to which will be attached various other nodes: ┃
  ┃     "frame" is a top node from SceneKit file "com.ramsaycons.geometries.scn"; it represents the  ┃
  ┃         inertial frame and it never transformed; it contains some nodes which will be animated.  ┃
  ┃     "earth" -- will rotate once a day                                                            ┃
  ┃  .. adds the following constructed nodes:                                                        ┃
  ┃     "light" -- the light of the sun -- will rotates once a year                                  ┃
  ┃     "spots" -- various other objects -- markers, satellites, etc                                 ┃
  ┃                                                                                                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController.viewDidLoad()")

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │                                                                                                  │
  │                              +--------------------------------------------------------------+    │
  │                              |                              "com.ramsaycons.geometries.scn" |    │
  │                          +-- |  Node("frame") --------+                                     |    │
  │                          |   |                        |                                     |    │
  │                          |   |                        +-- Node("earth") --+                 |    │
  │ SCNView.scene.rootNode   |   |                        |                   +-- Node("globe") |    │
  │       == Node("total") --+   |                        |                   +-- Node("grids") |    │
  │                          |   |                        |                   +-- Node("coast") |    │
  │                          |   +------------------------|-------------------------------------+    │
  │                          |                            |                                          │
  │                          +-- Node("orbit") --+        +-- Node("spots")                          │
  │                                              |        |                                          │
  │                                              |        +-- Node("light")                          │
  │                                              |                                                   │
  │                                              +-- Node("camra")                                   │
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

        totalView.scene = SCNScene()
        totalView.backgroundColor = NSColor.blue
        totalView.autoenablesDefaultLighting = true
        totalView.showsStatistics = true

        if let overlay = OverlayScene(fileNamed:"OverlayScene") { totalView.overlaySKScene = overlay }

        guard let totalNode = totalView.scene?.rootNode,
              let frameScene = SCNScene(named: "com.ramsaycons.geometries.scn"),
              let frameNode = frameScene.rootNode.childNode(withName: "frame",
                                                            recursively: true),
              let earthNode = frameScene.rootNode.childNode(withName: "earth",
                                                            recursively: true) else { return }
        totalNode.name = "total"
        totalNode.addChildNode(frameNode)              // "total << "frame"

        // rotate earth to time of day
        earthNode.eulerAngles.z += CGFloat(ZeroMeanSiderealTime(JulianDaysNow()) * deg2rad)

        addViewCamera(totalNode)

        addSolarLight(frameNode)

        addMarkerSpot(frameNode, color: NSColor.magenta, at:(eRadiusKms * 1.05,0.0,0.0))
        addMarkerSpot(frameNode, color: NSColor.green, at:(0.0,eRadiusKms * 1.05,0.0))
        addMarkerSpot(frameNode, color: NSColor.yellow, at:(0.0,0.0,eRadiusKms * 1.05))
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        print("ViewController.viewDidAppear()")

        totalView.delegate = self

        if let earthNode = totalView.scene?.rootNode.childNode(withName: "earth", recursively: true) {

            let action = SCNAction.rotate(by: π/60,
                                          around: SCNVector3(x: 0, y: 0, z: 1),
                                          duration: 1.0)
            earthNode.runAction(SCNAction.repeatForever(action))

        }
        else {
            print("node 'earth' not found in model")
        }
    }



/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃  SCNSceneRendererDelegate calls : sixty per second which is far too fast for our needs ..        ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    var frameCount = 0

    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        if let earthNode = totalView.scene?.rootNode.childNode(withName: "earth", recursively: true) {

            if frameCount % 60 == 0 {
                frameCount = 0
                Swift.print("earth node: \(earthNode.rotation)")
            }

            if frameCount % 180 == 0 {
                earthNode.eulerAngles.z = CGFloat(ZeroMeanSiderealTime(JulianDaysNow()) * deg2rad)
            }
            
            frameCount += 1

        }

    }

    public func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {

    }

    public func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        
    }

}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ attach the camera a long way from the center of a (non-rendering node) and pointed at (0, 0, 0)  ┃
  ┃ with a viewpoint initially on x-axis at 120,000Km with north (z-axis) up                         ┃
  ┃                                                      http://stackoverflow.com/questions/25654772 ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
func addViewCamera(_ parentNode:SCNNode) -> Void {

    let orbitNode = SCNNode()                           // non-rendering node, holds the camera
    orbitNode.name = "orbit"

    let camera = SCNCamera()                            // create a camera
    let cameraRange = 120_000.0
    camera.xFov = 800_000.0 / cameraRange
    camera.yFov = 800_000.0 / cameraRange
    camera.automaticallyAdjustsZRange = true

    let cameraNode = SCNNode()
    cameraNode.name = "camra"
    cameraNode.camera = camera
    cameraNode.position = SCNVector3(x: 0, y: 0, z: CGFloat(cameraRange))

    let cameraConstraint = SCNLookAtConstraint(target: parentNode)
    cameraConstraint.isGimbalLockEnabled = true
    cameraNode.constraints = [cameraConstraint]

    orbitNode.addChildNode(cameraNode)                  //            "orbit" << "camra"
    parentNode.addChildNode(orbitNode)                  // "total" << "orbit"
}


/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
func addSolarLight(_ parentNode:SCNNode) -> Void {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ sunlight shines                                                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let sunLight = SCNLight()
    sunLight.type = SCNLight.LightType.directional      // make a directional light

    let lightNode = SCNNode()
    lightNode.name = "light"
    lightNode.light = sunLight

    parentNode.addChildNode(lightNode)                  //           "frame" << "light"

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ sunlight shines                                                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

    let solarNode = SCNNode()                           // position of sun in (x,y,z)

    let sunVector:(Double,Double,Double) = solarCel(julianDate: JulianDaysNow())
    solarNode.position = SCNVector3((-sunVector.0, -sunVector.1, -sunVector.2))

    let solarConstraint = SCNLookAtConstraint(target: solarNode)
    lightNode.constraints = [solarConstraint]           // keep the light coming from the sun

    parentNode.addChildNode(solarNode)
}


/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ a spot on the x-axis (points at vernal equinox)                                                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
func addMarkerSpot(_ parentNode:SCNNode, color:NSColor, at:(Double, Double, Double)) -> Void {
    let spotsGeom = SCNSphere(radius: 100.0)
    spotsGeom.isGeodesic = true
    spotsGeom.segmentCount = 6
    spotsGeom.firstMaterial?.diffuse.contents = color

    let spotsNode = SCNNode(geometry:spotsGeom)
    spotsNode.name = "spots"
    spotsNode.position = SCNVector3(at)

    parentNode.addChildNode(spotsNode)              //           "frame" << "spots"
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ (X, Y, X) --> (rad, inc, azi)                                                                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func cameraCart2Pole(_ x:Double, _ y:Double, _ z:Double) -> (Double, Double, Double) {
    let rad = sqrt(x*x + y*y + z*z)
    return (rad, acos(z/rad), atan2(y, x))
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ (lon, lat, alt) --> (X, Y, X)                                                                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func cameraPole2Cart(_ rad:Double, _ inc:Double, _ azi:Double) -> (Double, Double, Double) {
    return (rad * sin(inc) * cos(azi), rad * sin(inc) * sin(azi), rad * cos(inc))
}
