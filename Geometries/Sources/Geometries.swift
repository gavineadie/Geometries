/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Geometries.swift                                                                      Geometries ║
  ║ Created by Gavin Eadie on Jun10/17   Copyright © 2017-19 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable variable_name

import SceneKit

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ reads a binary file (x,y,z),(x,y,z), (x,y,z),(x,y,z), .. and makes a SceneKit Geometry ..        ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
func xxxxxMesh(resourceFile: String) -> SCNGeometry? {
    let mainBundle = Bundle.main
    let sceneURL = mainBundle.url(forResource: resourceFile, withExtension: "")

    guard let dataContent = try? Data(contentsOf: sceneURL!) else {
        print("mesh file '\(resourceFile)' missing")
        return nil
    }

    let vertexSource = FloatGeometrySource(dataBuffer: dataContent)

    let element = SCNGeometryElement(data: nil, primitiveType: .line,
                                     primitiveCount: dataContent.count/(vertexStride*2),
                                     bytesPerIndex: MemoryLayout<UInt16>.size)

    return SCNGeometry(sources: [vertexSource], elements: [element])
}

func FloatGeometrySource(dataBuffer: Data) -> SCNGeometrySource {

    return SCNGeometrySource(data: dataBuffer,
                             semantic: SCNGeometrySource.Semantic.vertex,
                             vectorCount: dataBuffer.count/(vertexStride*2),
                             usesFloatComponents: true, componentsPerVector: 3,
                             bytesPerComponent: MemoryLayout<Float>.size,
                             dataOffset: 0, dataStride: vertexStride)

}
