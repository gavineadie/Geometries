/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Platform.swift                                                                          DemosKit ║
  ║ Created by Gavin Eadie on Dec08/18 .. Copyright 2018-19 Ramsay Consulting.  All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

#if os(iOS) || os(tvOS) || os(watchOS)

    import UIKit

    typealias Application = UIApplication
    typealias ApplicationDelegate = UIApplicationDelegate

    typealias View = UIView
    typealias Image = UIImage

    typealias Font = UIFont
    typealias Color = UIColor
    typealias BezierPath = UIBezierPath

    extension BezierPath { public func line(to point: CGPoint) { addLine(to: point) } }

#else

    import Cocoa

    typealias Application = NSApplication
    typealias ApplicationDelegate = NSApplicationDelegate

    typealias View = NSView
    typealias Image = NSImage

    typealias Font = NSFont
    typealias Color = NSColor
    typealias BezierPath = NSBezierPath

#endif
