/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ DateUtility.swift                                                                         SatKit ║
  ║ Created by Gavin Eadie on 5/29/17.            Copyright © 2017 Gavin Eadie. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

extension Date {

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ convert decimal days since the TLE reference time (1950) to a Date                               │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    init(daysSince1950: Double) {
        self = Date(timeInterval: daysSince1950 * TimeConstants.day2sec,
                    since: TimeConstants.tleEpochReferenceDate!)            // seconds since 1950
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ convert a Date to a JD ..                                                                        │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public var julianDate: Double { return JD.appleZero +
                                    timeIntervalSinceReferenceDate * TimeConstants.sec2day }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ convert a Date to Julian days since 1900 ..                                                      │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public var daysSince1900: Double { return julianDate - JD.epoch1900 }

}
