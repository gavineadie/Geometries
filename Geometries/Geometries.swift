//
//  Geometries.swift
//  Geometries
//
//  Created by Gavin Eadie on 9/25/15.
//  Copyright © 2015 Gavin Eadie. All rights reserved.
//

import SceneKit

extension SCNGeometry {

    class func CoastMesh() -> SCNGeometry {
        let mainBundle = NSBundle.mainBundle()
        let resourcePath = mainBundle.pathForResource("coast", ofType: "vector")
        let dataContent = NSData.init(contentsOfFile: resourcePath!)
        let vectorCount = (dataContent?.length)! / 12           // count of point pairs
        print("CoastMesh(vectorCount: \(vectorCount))")
        
        let vertexSource = SCNGeometrySource(data: dataContent!,
            semantic: SCNGeometrySourceSemanticVertex, vectorCount: vectorCount,
            floatComponents: true, componentsPerVector: 3, bytesPerComponent: sizeof(Float32),
            dataOffset: 0, dataStride: 12)

        let element = SCNGeometryElement(data: nil, primitiveType: .Line,
            primitiveCount: vectorCount, bytesPerIndex: sizeof(Int))
        
        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
    
    class func GridsMesh() -> SCNGeometry {
        let mainBundle = NSBundle.mainBundle()
        let resourcePath = mainBundle.pathForResource("grids", ofType: "vector")
        let dataContent = NSData.init(contentsOfFile: resourcePath!)
        let vectorCount = (dataContent?.length)! / 12           // count of point pairs
        print("GlobeMesh(vectorCount: \(vectorCount))")
        
        let vertexSource = SCNGeometrySource(data: dataContent!,
            semantic: SCNGeometrySourceSemanticVertex, vectorCount: vectorCount,
            floatComponents: true, componentsPerVector: 3, bytesPerComponent: sizeof(Float32),
            dataOffset: 0, dataStride: 12)

        let normalSource = SCNGeometrySource(data: dataContent!,
            semantic: SCNGeometrySourceSemanticNormal, vectorCount: vectorCount,
            floatComponents: true, componentsPerVector: 3, bytesPerComponent: sizeof(Float32),
            dataOffset: 0, dataStride: 12)
        
        let element = SCNGeometryElement(data: nil, primitiveType: .Point,
            primitiveCount: vectorCount, bytesPerIndex: sizeof(Int))
        
        return SCNGeometry(sources: [vertexSource, normalSource], elements: [element])
    }

}