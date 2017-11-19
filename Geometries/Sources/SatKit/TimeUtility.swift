/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TimeUtility.swift                                                                         SatKit ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Jan07/17 ...    Copyright 2017 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable identifier_name

import Foundation

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ References: The 1992 Astronomical Almanac, page B6.                                              ┃
  ┃             http://celestrak.com/columns/v02n02/ and http://aa.usno.navy.mil/faq/docs/GAST.php   ┃
  ┃                                                                                                  ┃
  ┃   check at: http://www.jgiesen.de/SiderealTimeClock/index.html                                   ┃
  ┃                                                                                                  ┃
  ┃ returns sidereal time in degrees ... (also "GHA Aries")                                          ┃
  ┃                                                                                                  ┃
  ┃ Sidereal time is a system of timekeeping based on the rotation of the Earth with respect to the  ┃
  ┃ fixed stars in the sky. Specifically, it is the measure of the hour angle of the vernal equinox. ┃
  ┃ When the measurements are made with respect to the meridian at Greenwich, the times are referred ┃
  ┃ to as Greenwich mean sidereal time (GMST).                                                       ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

let     julianCentury = 36525.0
let     JD_2000 = 2451545.0                                 // 2000-Jan-01.5 (12h)
let     JD_CORE = 2451910.5                                 // 2001-Jan-01 00h00m00.0s (CFAbsoluteTime zero)
let     eRotation = 1.00273790934                           // Earth rotations/sidereal day

public func zeroMeanSiderealTime(julianDate: Double = -1.0) -> Double {
    let     fractionalDay = fmod(julianDate + 0.5, 1.0)     // fractional part of JD + half a day
    let     adjustedJD = julianDate - fractionalDay
    let     timespanCenturies = (adjustedJD - JD_2000) / julianCentury
    var     GreenwichSiderealSeconds = 24110.54841 +        // Greenwich Mean Sidereal Time (secs)
        timespanCenturies * (8640184.812866 +
            timespanCenturies * (0.093104 -
                timespanCenturies * 0.0000062))
    GreenwichSiderealSeconds = fmod(GreenwichSiderealSeconds + fractionalDay * eRotation * day2sec, day2sec)

    return fmod((360.0 * GreenwichSiderealSeconds * sec2day) + 360.0, 360.0)
}

public func siteMeanSiderealTime(julianDate: Double, siteLongitude: Double) -> Double {
    return fmod(zeroMeanSiderealTime(julianDate: julianDate) + siteLongitude + 360.0, 360.0)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ julianDays & epoch50Days : the time delivered by the HeartBeat (may be 'clock', may be 'model')  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

public func julianDaysNow() -> Double {
    return JD_CORE + CFAbsoluteTimeGetCurrent() * sec2day
}

public func julianDaysWith(biasMins: Double) -> Double {
    return julianDaysNow() + biasMins/1440.0
}
