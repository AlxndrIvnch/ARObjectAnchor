//
//  ViewController.swift
//  ARtest
//
//  Created by alexander.ivanchenko on 23.02.2023.
//

import UIKit
import RealityKit
import ARKit

class ARVC: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!
    
//    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        arView.debugOptions = [.showFeaturePoints, .showWorldOrigin, .showAnchorGeometry, .showStatistics, .showSceneUnderstanding, .showPhysics]
        
        let appleJuiceReferenceImage = ARReferenceImage(UIImage(named: "appleJuice")!.cgImage!, orientation: .up, physicalWidth: 0.07)
        let morshinskayaReferenceImage = ARReferenceImage(UIImage(named: "morshinskaya")!.cgImage!, orientation: .up, physicalWidth: 0.09)
        
        let referenceImages = Set([appleJuiceReferenceImage, morshinskayaReferenceImage])
        
//        let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main)!
        
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        
        arView.session.delegate = self
        arView.session.run(configuration)
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
           for anchor in anchors {
               if let imageAnchor = anchor as? ARImageAnchor {
                   DispatchQueue.main.async { [weak self] in
                       print("found anchor")
                       let imageAnchorEntity = AnchorEntity(anchor: imageAnchor)
                       
                       let view = InfoView(frame: .init(origin: .zero, size: .init(width: 100, height: 200)))
                       view.backgroundColor = .white.withAlphaComponent(0.9)
                       let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
                       let image = renderer.image { ctx in
                           view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
                       }
                       
                       let texture = MaterialParameters.Texture(try! .generate(from: image.cgImage!, options: .init(semantic: nil)))
                       var material = UnlitMaterial()
                       material.color = .init(tint: .white.withAlphaComponent(0.9999), texture: texture)
               
                       let mesh: MeshResource = .generatePlane(width: 0.1, height: 0.2)
                       let entity = ModelEntity(mesh: mesh, materials: [material])
                       
                       entity.setOrientation(.init(angle: GLKMathDegreesToRadians(-90), axis: .init(x: 1, y: 0, z: 0)), relativeTo: imageAnchorEntity)
                       
                       let imageWidth = Float(imageAnchor.referenceImage.physicalSize.width)
                       entity.setPosition(.init(x: (imageWidth / 2) + 0.05 + 0.01, y: 0, z: 0), relativeTo: imageAnchorEntity)
                       
                       imageAnchorEntity.addChild(entity)
                       self?.arView.scene.addAnchor(imageAnchorEntity)
                   }
               }
           }
       }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension ARVC {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        
    }
}
