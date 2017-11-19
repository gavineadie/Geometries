/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ MathUtility.swift                                                                         SatKit ║
  ║ Created by Gavin Eadie on Nov17/15 ... Copyright 2009-17 Ramsay Consulting. All rights reserved. ║
  ║──────────────────────────────────────────────────────────────────────────────────────────────────║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

// swiftlint:disable vertical_whitespace
// swiftlint:disable identifier_name

//NOTE interesting: https://gist.github.com/kelvin13/03d1fd5da024f058b6fd38fdbce665a4

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ C O N S T A N T S                                                                                ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

public let ⅓ = 1.0 / 3.0
public let ⅔ = 2.0 / 3.0

public let  rad2deg: Double = 180.0/π

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ O P E R A T O R S                                                                                ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

prefix operator √

prefix func √ <T: FloatingPoint>(float: T) -> T {
    if let ff = float as? Double { return (sqrt(ff) as? T)! }
    if let ff = float as? Float { return (sqrtf(ff) as? T)! }
    preconditionFailure()
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ almostEqual (test for equality to one ULP) .. 10.0 ~~ 10.000000000000001                         ┃
  ┃                      unit of least precision (ULP) is the spacing between floating-point numbers ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func almostEqual(_ a: Double, _ b: Double) -> Bool {
    return a == b ||
           a == nextafter(b, +.greatestFiniteMagnitude) ||
           a == nextafter(b, -.greatestFiniteMagnitude)
}

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ V E C T O R S                                                                                    ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

public struct Vector {

    public var x: Double
    public var y: Double
    public var z: Double

    public init() {
        self.x = 0.0
        self.y = 0.0
        self.z = 0.0
    }

    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    public static prefix func - (v: Vector) -> Vector {
        return Vector(-v.x, -v.y, -v.z)
    }

    public static func + (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }

    public static func - (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }

}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ magnitude                                                                           [3-D Vector] ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func magnitude(_ vector: Vector) -> Double {
    return √(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ normalize to unit vector [zero length Vector aborts]                                             ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func normalize(_ vector: Vector) -> Vector {
    let mag = magnitude(vector)
    guard mag > 0 else { preconditionFailure("normalize: empty vector") }
    return Vector(vector.x / mag, vector.y / mag, vector.z / mag)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ dot product                                                                                      ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
infix operator •

public func dotProduct(_ vector1: Vector, _ vector2: Vector) -> Double {
    return (vector1.x*vector2.x + vector1.y*vector2.y + vector1.z*vector2.z)
}

func • (_ vector1: Vector, _ vector2: Vector) -> Double {
    return (vector1.x*vector2.x + vector1.y*vector2.y + vector1.z*vector2.z)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ angle between (degrees)                                                                          ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func separation(_ vector1: Vector, _ vector2: Vector) -> Double {
    return(acos((vector1 • vector2) / (magnitude(vector1)*magnitude(vector2))) * rad2deg)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ cross product                                                                                    ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
infix operator ⨯

public func crossProduct(_ vector1: Vector, _ vector2: Vector) -> Vector {
    return Vector(vector1.y*vector2.z - vector1.z*vector2.y,
                  vector1.z*vector2.x - vector1.x*vector2.z,
                  vector1.x*vector2.y - vector1.y*vector2.x)
}

func ⨯ (_ vector1: Vector, _ vector2: Vector) -> Vector {
    return Vector(vector1.y*vector2.z - vector1.z*vector2.y,
                  vector1.z*vector2.x - vector1.x*vector2.z,
                  vector1.x*vector2.y - vector1.y*vector2.x)
}

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ T R I G O N O M E T R Y                                                                          ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ normalizeAngle returns angle in a 2π wide interval around a center ..     0: -π...+π; 2π: 0...2π ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func normalizeAngle(_ angle: Double, _ center: Double) -> Double {
    return angle - (2.0*π) * floor((angle + π - center) / (2.0*π))
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ atan2pi returns angles in range (0-2π radians)                           PS: atan2() -> +π to -π ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func atan2pi (_ x: Double, _ y: Double) -> Double {
    var     result = 0.0

    if (x != 0.0) ||
       (y != 0.0) { result = fmod2pi(atan2(x, y)) }

    return result
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ acos2pi returns angles in range (0-π for x/y>0; π-2π if x/y<0)             PS: acos() -> 0 to +π ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func acos2pi(_ x: Double, _ y: Double) -> Double {
    var result = 0.0

    if y > 0.0 { result =     acos(x/y) }
    if y < 0.0 { result = π + acos(x/y) }

    return result
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ fmod2pi(radians) -- limits 'radians' to 0-2π                                                     ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func fmod2pi(_ radians: Double) -> Double {
    var     result = fmod(radians, 2.0*π)

    if result < 0.0 { result += 2.0*π }

    return result
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ limit180(degrees) -- limits 'degrees' to -180..+180                                              ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func limit180 (_ value: Double) -> Double {
    var value = value
    while value > +180.0 { value -= 360.0 }
    while value < -180.0 { value += 360.0 }
    return value
}




/*
 https://gist.github.com/kelvin13/03d1fd5da024f058b6fd38fdbce665a4
 */

// swiftlint:disable colon
// swiftlint:disable type_name

enum Math<F> where F:FloatingPoint {
    typealias V2 = (x:F, y:F)
    typealias V3 = (x:F, y:F, z:F)

    @inline(__always)
    static func add(_ v1:V3, _ v2:V3) -> V3 { return (v1.x + v2.x, v1.y + v2.y, v1.z + v2.z) }

    @inline(__always)
    static func sub(_ v1:V3, _ v2:V3) -> V3 { return (v1.x - v2.x, v1.y - v2.y, v1.z - v2.z) }

    @inline(__always)
    static func neg(_ v:V3) -> V3 { return (-v.x, -v.y, -v.z) }

    @inline(__always)
    static func scale(_ v:V3, by c:F) -> V3 { return (v.x * c, v.y * c, v.z * c) }

    @inline(__always)
    static func dot(_ v1:V3, _ v2:V3) -> F { return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z }

    @inline(__always)
    static func cross(_ v1:V3, _ v2:V3) -> V3 { return (v1.y*v2.z - v2.y*v1.z,
                                                        v1.z*v2.x - v2.z*v1.x,
                                                        v1.x*v2.y - v2.x*v1.y) }

    @inline(__always)
    static func magnitude(_ v:V3) -> F { return Math.dot(v, v).squareRoot() }

    @inline(__always)
    static func normalize(_ v:V3) -> V3 {
//      let factor:F = 1 / Math.dot(v, v).squareRoot()
        return Math.scale(v, by: magnitude(v))
    }

}

extension Math where F == Double {
    @inline(__always)
    static func cast_float(_ v:V3) -> Math<Float>.V3 {
        return (Float(v.x), Float(v.y), Float(v.z))
    }
}
