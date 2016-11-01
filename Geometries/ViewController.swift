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

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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

        guard let totalView = self.view as? SceneView else { return }

        totalView.scene = SCNScene()
        totalView.backgroundColor = NSColor.blue
        totalView.autoenablesDefaultLighting = true
        totalView.showsStatistics = true

        print("totalView: \(totalView)")

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ this timer refreshes the view every second                                                       ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        _ = schedule(repeatInterval: 1.0) { timer in

            totalView.needsDisplay = true
            
        }

        if let overlay = OverlayScene(fileNamed:"OverlayScene") { totalView.overlaySKScene = overlay }

        guard let totalNode = totalView.scene?.rootNode,
              let frameScene = SCNScene(named: "com.ramsaycons.geometries.scn"),
              let frameNode = frameScene.rootNode.childNode(withName: "frame",
                                                            recursively: true),
              let earthNode = frameScene.rootNode.childNode(withName: "earth",
                                                            recursively: true) else { return }

        // rotate frame to time of day
        let siderealTime = ZeroMeanSiderealTimeDegrees(julianDate: JulianDaysNow())

        var eulerAngles = earthNode.eulerAngles
        eulerAngles.z += CGFloat(siderealTime * 1000.0 /* *deg2rad */)
        earthNode.eulerAngles = eulerAngles

        totalNode.name = "total"

        totalNode.addChildNode(frameNode)              // "total << "frame"

        addViewCamera(totalNode)

        addSolarLight(frameNode)

        addMarkerSpot(frameNode, color: NSColor.magenta, at:(6.378135e3 * 1.05,0.0,0.0))
        addMarkerSpot(frameNode, color: NSColor.green, at:(0.0,6.378135e3 * 1.05,0.0))
        addMarkerSpot(frameNode, color: NSColor.yellow, at:(0.0,0.0,6.378135e3 * 1.05))

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

    let sunVector = solarCel(julianDate: JulianDaysNow())
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

public let  π₀:Double = 3.141_592_653_589_793_238_462_643_383_279_502_884_197_169_399_375_105_820_975
public let  deg2rad:Double = π₀/180.0
public let  sec2day:Double = 1.0 / (24.0 * 60.0 * 60.0)
public let  day2sec:Double = (24.0 * 60.0 * 60.0)


let JD_2000 = 2451545.0
let JD_CORE = 2451910.5

public func JulianDaysNow() -> Double {
    return JD_CORE + CFAbsoluteTimeGetCurrent() * sec2day
}

public func solarCel (julianDate:Double) -> (Double, Double, Double) {
    let     daysSinceJD2000 = julianDate - JD_2000

    let     solarMeanAnom = (357.529 + 0.98560028 * daysSinceJD2000) * deg2rad

    let     aberration1 = 1.915 * sin(1.0 * solarMeanAnom)
    let     aberration2 = 0.020 * sin(2.0 * solarMeanAnom)

    let     solarEclpLong = ((280.459 + 0.98564736 * daysSinceJD2000) + aberration1 + aberration2) * deg2rad

    let     eclipticInclin = (23.439 - 0.00000036 * daysSinceJD2000) * deg2rad

    return (cos(solarEclpLong),
            sin(solarEclpLong) * cos(eclipticInclin),
            sin(solarEclpLong) * sin(eclipticInclin))
}

let     JulianCentury = 36525.0
let     eRotation = 1.00273790934                               // Earth rotations/sidereal day


public func ZeroMeanSiderealTimeDegrees(julianDate:Double) -> Double {
    let     fractionalDay = fmod(julianDate + 0.5, 1.0)         // fractional part of JD + half a day
    let     adjustedJD = julianDate - fractionalDay
    let     timespanCenturies = (adjustedJD - JD_2000) / JulianCentury
    var     GreenwichSiderealSeconds = 24110.54841 +            // Greenwich Mean Sidereal Time (secs)
        timespanCenturies * (8640184.812866 +
            timespanCenturies * (0.093104 -
                timespanCenturies * 0.0000062))
    GreenwichSiderealSeconds = fmod(GreenwichSiderealSeconds + fractionalDay * eRotation * day2sec, day2sec)

    return (360.0 * GreenwichSiderealSeconds * sec2day)
}

func schedule(repeatInterval interval: TimeInterval,
              closure: @escaping ((Timer?) -> Void)) -> Timer! {

    let fireDate = interval + CFAbsoluteTimeGetCurrent()

    let runTimer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, closure)

    CFRunLoopAddTimer(CFRunLoopGetCurrent(), runTimer, CFRunLoopMode.commonModes)

    return runTimer
}

/*

 //        let action = SCNAction.rotateByAngle(π*2, aroundAxis: SCNVector3(x: 0, y: 0.3, z: 1), duration: 5.0)
 //        let earthNode = totalView.scene!.rootNode.childNodeWithName("earth", recursively: true)
 //        earthNode!.runAction(action)

 }

 //    @IBAction func spinAction(sender: NSButton) {
 //
 //        print("spinAction")
 //
 //        let sceneView = self.view as! SCNView
 //        let scene = sceneView.scene
 //
 //        if let earthNode = scene!.rootNode.childNodeWithName("earth", recursively: true) {
 //
 //            let action = SCNAction.rotateByAngle(π*2.0, aroundAxis: SCNVector3(x: 0, y: 0.3, z: 1), duration: 10.0)
 //            earthNode.runAction(action)
 //
 //        }
 //        else {
 //            print("node 'earth' not found in model")
 //        }
 //
 //    }
 
 */
