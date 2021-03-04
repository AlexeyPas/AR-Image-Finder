//
//  ViewController.swift
//  AR Image Finder
//
//  Created by MacBook Pro on 01.03.2021.
//

import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let videoPlayer: AVPlayer = {
        let url = Bundle.main.url(forResource: "Moscow", withExtension: "mp4", subdirectory: "art.scnassets")!
        return AVPlayer(url: url)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        // Detect images
        configuration.trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!
        configuration.maximumNumberOfTrackedImages = 2
        // Detect plane
        //configuration.planeDetection = [.horizontal]
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // Check that we've got an image anchor
        switch anchor {
        case let planeAnchor as ARPlaneAnchor:
            nodeAdded(node, for: planeAnchor)
        case let imageAnchor as ARImageAnchor:
            nodeAdded(node, for: imageAnchor)
        default:
            print(#line, #function, "Unknoun anchor has been discovered")
        }
    }
    
    func nodeAdded(_ node: SCNNode, for planeAnchor: ARPlaneAnchor){
        print(#line, #function, "Plane \(planeAnchor) added")
    }
    
    func nodeAdded(_ node:SCNNode, for imageAnchor: ARImageAnchor){
        // Get image size
        let image = imageAnchor.referenceImage
        let size = image.physicalSize
        
        // Create plane of the same size
        let width = image.name == "church" ?
            16.3 / 10.17 * size.width :
            16.3 / 9.6071 * size.width
        let height = 1.03 * size.height
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents = image.name == "church" ?
            UIImage(named: "monument") :
            videoPlayer
        if image.name == "yaroslavl" {
            videoPlayer.play()
        }
        
        // Create plane node
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        
        // Move plane node
        planeNode.position.x -= image.name == "church" ? 0.005 : 0
        
        // Run animation
        planeNode.runAction(.sequence([
            .wait(duration: 15),
            .fadeOut(duration: 5),
            .removeFromParentNode(),
            ])
        )
        
        // Add plane node to given node
        node.addChildNode(planeNode)
    }
}
