//
//  ViewController.swift
//  SolAR System

//  Created by Luciano Amoroso on 12/05/19.
//  Copyright © 2019 Luciano Amoroso. All rights reserved.
//


//import

import UIKit
import SceneKit
import ARKit

//inizialitation for label -> information button
public var infor = "Our planetary system is located in an outer spiral arm of the Milky Way galaxy. Our solar system consists of our star, the Sun, and everything bound to it by gravity — the planets Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus and Neptune, dwarf planets such as Pluto, dozens of moons and millions of asteroids, comets and meteoroids. Beyond our own solar system, we have discovered thousands of planetary systems orbiting other stars in the Milky Way."

public var norm = true;

//enumaration for planet

enum PlanetName: String {
    case mercury = "Mercury"
    case venus = "Venus"
    case earth = "Earth"
    case mars = "Mars"
    case jupiter = "Jupiter"
    case saturn = "Saturn"
    case uranus = "Uranus"
    case neptune = "Neptune"
    case pluto = "Pluto"
}

class ViewController: UIViewController, ARSCNViewDelegate {

    //declaration
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var marsbtn: UIButton!
    @IBOutlet weak var earthbtn: UIButton!
    @IBOutlet weak var solarSystembtn: UIButton!
    @IBOutlet weak var btnAsk: UIButton!
    
    var info = ""
    var sunNode: SCNNode!
    var sunHaloNode: SCNNode!
    var selectedNode: SCNNode!
    var focusNode: SCNNode!
    var zDepth: Float!
    
//Store The Rotation Of The CurrentNode
var currentAngleY: Float = 0.0

//Variable initialization by rotation
var isRotating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        sceneView.delegate = self
        
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        
        //declaration for scene
        let scene = SCNScene()
        
        sceneView.scene = scene
        
        self.createSun()
        
        //panGesture and rotateGesture
       let panGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaleObject(gesture:)))
        self.view.addGestureRecognizer(panGesture)

       let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateNode(_:)))
       self.view.addGestureRecognizer(rotateGesture)

    }
    
    
    
    func createPlanets() {
        // Mecury
        self.createPlanet(planetName: PlanetName.mercury, radius: 0.02, position: SCNVector3Make(0.4, 0, 0), contents: #imageLiteral(resourceName: "mercury"), rotationDuration: 25, orbitRadius: 0.4)
        
        // Venus
        self.createPlanet(planetName: PlanetName.venus, radius: 0.04, position: SCNVector3Make(0.6, 0, 0), contents:#imageLiteral(resourceName: "venus"), rotationDuration: 40, orbitRadius: 0.6)
        
        // Earth
        self.createPlanet(planetName: PlanetName.earth, radius: 0.05, position: SCNVector3Make(0.8, 0, 0), contents: #imageLiteral(resourceName: "earth"), rotationDuration: 30, orbitRadius: 0.8)
        
        // Mars
        self.createPlanet(planetName: PlanetName.mars, radius: 0.03, position: SCNVector3Make(1.0, 0, 0), contents: #imageLiteral(resourceName: "mars"), rotationDuration: 35, orbitRadius: 1.0)
        
        // Jupiter
        self.createPlanet(planetName: PlanetName.jupiter, radius: 0.15, position: SCNVector3Make(1.4, 0, 0), contents: #imageLiteral(resourceName: "jupiter"), rotationDuration: 90, orbitRadius: 1.4)
        
        // Saturn
        self.createPlanet(planetName: PlanetName.saturn, radius: 0.12, position: SCNVector3Make(1.68, 0, 0), contents: #imageLiteral(resourceName: "saturn"), rotationDuration: 80, orbitRadius: 1.68)
        
        // Uranus
        self.createPlanet(planetName: PlanetName.uranus, radius: 0.09, position: SCNVector3Make(1.95, 0, 0), contents: #imageLiteral(resourceName: "uranus"), rotationDuration: 55, orbitRadius: 1.95)
        
        // Neptune
        self.createPlanet(planetName: PlanetName.neptune, radius: 0.08, position: SCNVector3Make(2.14, 0, 0), contents: #imageLiteral(resourceName: "neptune"), rotationDuration: 50, orbitRadius: 2.14)
        
        // Plutone
        self.createPlanet(planetName: PlanetName.pluto, radius: 0.04, position: SCNVector3Make(2.319, 0, 0), contents: #imageLiteral(resourceName: "pluto"), rotationDuration: 100, orbitRadius: 2.319)
        
    }
    
    func createPlanet(planetName: PlanetName, radius: CGFloat, position: SCNVector3, contents: UIImage, rotationDuration: CFTimeInterval, orbitRadius: CGFloat) {
        
        let planet = SCNNode()
        planet.geometry = SCNSphere(radius: radius)
        planet.position = planetName == .saturn ? SCNVector3Make(0, 0, 0) : position
        planet.geometry?.firstMaterial?.diffuse.contents = contents
        planet.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
        planet.geometry?.firstMaterial?.shininess = 0.1
        planet.geometry?.firstMaterial?.specular.intensity = 0.5
        planet.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // Add planet around sun
        let planetRotationNode = SCNNode()
        if planetName == .saturn {
            let saturnGroup = SCNNode()
            saturnGroup.position = position
            saturnGroup.addChildNode(planet)
            saturnGroup.addChildNode(self.addRingToPlanet(contents: #imageLiteral(resourceName: "saturn_ring")))
            planetRotationNode.addChildNode(saturnGroup)
        } else {
            planetRotationNode.addChildNode(planet)
        }
        
        // Animation
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.duration = rotationDuration
        animation.toValue = NSValue.init(scnVector4: SCNVector4Make(0, 1, 0, Float.pi * 2))
        animation.repeatCount = Float.greatestFiniteMagnitude
        planetRotationNode.addAnimation(animation, forKey: "\(planetName.rawValue) rotation around sun")
        self.sunNode.addChildNode(planetRotationNode)
        
        // Orbit
        let planetOrbit = SCNNode()
        planetOrbit.geometry = SCNTorus(ringRadius: orbitRadius, pipeRadius: 0.001)
        planetOrbit.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        planetOrbit.geometry?.firstMaterial?.diffuse.mipFilter = .linear
        planetOrbit.rotation = SCNVector4Make(0, 1, 0, Float.pi / 2)
        self.sunNode.addChildNode(planetOrbit)
        
    }
    
    //function for rotation planet
    
    func giraPlanet (){
        let animation = CABasicAnimation(keyPath: "rotation")
              animation.duration = 10.0
              animation.toValue = NSValue.init(scnVector4: SCNVector4Make(0, 0, 1, Float.pi * 2))
              animation.repeatCount = Float.greatestFiniteMagnitude
              sunNode.addAnimation(animation, forKey: "planetName.mercury")
              self.sunNode.addChildNode(sunNode)
    }
    
    func addRingToPlanet(contents: UIImage) -> SCNNode {
        let planetRing = SCNNode()
        planetRing.opacity = 0.4
        planetRing.geometry = SCNCylinder(radius: 0.3, height: 0.001)
        planetRing.eulerAngles = SCNVector3Make(-45, 0, 0)
        planetRing.geometry?.firstMaterial?.diffuse.contents = contents
        planetRing.geometry?.firstMaterial?.diffuse.mipFilter = .linear
        planetRing.geometry?.firstMaterial?.lightingModel = .constant
        return planetRing
    }
    
    //function to assign marte to node
    func createMars() {
        let camera = sceneView.pointOfView!
        self.sunNode = SCNNode()

         let position = SCNVector3(x: 0, y: 0, z: -2)
                         self.sunNode = SCNNode()
        self.sunNode.position = camera.convertPosition(position, to: nil)

                               self.sunNode.geometry = SCNSphere(radius: 0.25)
//                               self.sunNode.position = SCNVector3Make(0, -0.1, -3)
                               self.sceneView.scene.rootNode.addChildNode(self.sunNode)
                               
                               self.sunNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "venus")
            //                   self.sunNode.geometry?.firstMaterial?.multiply.contents = #imageLiteral(resourceName: "earth")
            //                   self.sunNode.geometry?.firstMaterial?.multiply.intensity = 0.5
                               self.sunNode.geometry?.firstMaterial?.lightingModel = .constant
                               
                               self.sunNode.geometry?.firstMaterial?.multiply.wrapS = .repeat
                               self.sunNode.geometry?.firstMaterial?.multiply.wrapT = .repeat
                               self.sunNode.geometry?.firstMaterial?.diffuse.wrapS = .repeat
                               self.sunNode.geometry?.firstMaterial?.diffuse.wrapT = .repeat
                               
                               self.sunNode.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
        
        norm = true;
    }
    func createEarth() {
        let camera = sceneView.pointOfView!
        self.sunNode = SCNNode()

        let position = SCNVector3(x: 0, y: 0, z: -2)
        self.sunNode.position = camera.convertPosition(position, to: nil)

                           self.sunNode.geometry = SCNSphere(radius: 0.25)
//                           self.sunNode.position = SCNVector3Make(0, -0.1, -3)
                           self.sceneView.scene.rootNode.addChildNode(self.sunNode)
                           
                           self.sunNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "earth")
                           self.sunNode.geometry?.firstMaterial?.lightingModel = .constant
                           
                           self.sunNode.geometry?.firstMaterial?.multiply.wrapS = .repeat
                           self.sunNode.geometry?.firstMaterial?.multiply.wrapT = .repeat
                           self.sunNode.geometry?.firstMaterial?.diffuse.wrapS = .repeat
                           self.sunNode.geometry?.firstMaterial?.diffuse.wrapT = .repeat
                           
                           self.sunNode.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
        
        norm = false;
    }
    func createSun() {
        
        //node and camera
        self.sunNode = SCNNode()
        let camera = sceneView.pointOfView!
               let position = SCNVector3(x: 0, y: 0, z: -2)
               self.sunNode = SCNNode()
               self.sunNode.position = camera.convertPosition(position, to: nil)
        self.sunNode.geometry = SCNSphere(radius: 0.25)
        self.sceneView.scene.rootNode.addChildNode(self.sunNode)
        
        self.sunNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "sun")
        self.sunNode.geometry?.firstMaterial?.multiply.contents = #imageLiteral(resourceName: "sun")
        self.sunNode.geometry?.firstMaterial?.multiply.intensity = 0.5
        self.sunNode.geometry?.firstMaterial?.lightingModel = .constant
        
        self.sunNode.geometry?.firstMaterial?.multiply.wrapS = .repeat
        self.sunNode.geometry?.firstMaterial?.multiply.wrapT = .repeat
        self.sunNode.geometry?.firstMaterial?.diffuse.wrapS = .repeat
        self.sunNode.geometry?.firstMaterial?.diffuse.wrapT = .repeat
        
        self.sunNode.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
        
        // Sun halo effect
        self.sunHaloNode = SCNNode()
        self.sunHaloNode.geometry = SCNPlane(width: 2.5, height: 2.5)
//        self.sunHaloNode.rotation = SCNVector4Make(1, 0, 0, Float.pi / 180)
        self.sunHaloNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "sun-halo")
        self.sunHaloNode.geometry?.firstMaterial?.lightingModel = .constant
        self.sunHaloNode.geometry?.firstMaterial?.writesToDepthBuffer = false
        self.sunHaloNode.opacity = 0.2
        self.sunNode.addChildNode(sunHaloNode)
        
        norm = true;
    }
    
    //light for node
   
    func addLight() {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.color = UIColor.black
        lightNode.light?.type = .omni
        self.sunNode.addChildNode(lightNode)
        
        lightNode.light?.attenuationStartDistance = 0
        lightNode.light?.attenuationEndDistance = 21
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        lightNode.light?.color = UIColor.white
        self.sunHaloNode.opacity = 0.9
        SCNTransaction.commit()
    }
    
    //animatiomn for node
    func sunAnimation() {
        
        var animation = CABasicAnimation(keyPath: "contentsTransform")
        animation.duration = 10.0
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.fromValue = NSValue.init(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(3, 3, 3)))
        animation.toValue = NSValue.init(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(5, 5, 5)))
        self.sunNode.geometry?.firstMaterial?.diffuse.addAnimation(animation, forKey: "sun_texture")
        
        animation = CABasicAnimation(keyPath: "contentsTranform")
        animation.duration = 30.0
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.fromValue = NSValue.init(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(3, 3, 3)))
        animation.toValue = NSValue.init(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(5, 5, 5)))
       self.sunNode.geometry?.firstMaterial?.multiply.addAnimation(animation, forKey: "sun_texture1")

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if let hit = sceneView.hitTest(touch.location(in: sceneView), options: nil).first {
          selectedNode = hit.node
          
          zDepth = sceneView.projectPoint(selectedNode.position).z
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      guard selectedNode != nil else { return }
      let touch = touches.first!
      let touchPoint = touch.location(in: sceneView)
      selectedNode.position = sceneView.unprojectPoint(
        SCNVector3(x: Float(touchPoint.x),
                   y: Float(touchPoint.y),
                   z: zDepth))    }
    

 @objc func moveNode(_ gesture: UIPanGestureRecognizer) {

     if !isRotating{

     //Get The Current Touch Point
     let currentTouchPoint = gesture.location(in: self.sceneView)

     // Get The Next Feature Point Etc
        guard let hitTest = self.sceneView.hitTest(currentTouchPoint, types: .existingPlane).first else { return }

     // Convert To World Coordinates
     let worldTransform = hitTest.worldTransform

    //     See the new position
    let newPosition = SCNVector3(worldTransform.columns.3.x, worldTransform.columns.3.y, worldTransform.columns.3.z)

     // Apply To The Node
     sunNode.simdPosition = float3(newPosition.x, newPosition.y, newPosition.z)

     }
 }
    
    /// Rotates An SCNNode Around It's YAxis
    ///
    /// - Parameter gesture: UIRotationGestureRecognizer
    @objc func rotateNode(_ gesture: UIRotationGestureRecognizer){

        //1. Get The Current Rotation From The Gesture
        let rotation = Float(gesture.rotation)

        //2. If The Gesture State Has Changed Set The Nodes EulerAngles.y
        if gesture.state == .changed{
            isRotating = true
            sunNode.eulerAngles.y = currentAngleY + rotation
        }

        //3. If The Gesture Has Ended Store The Last Angle Of The Cube
        if(gesture.state == .ended) {
            currentAngleY = sunNode.eulerAngles.y
            isRotating = false
        }
    }
    
    //rotation bUTTON
    @IBAction func actionAsk(_ sender: Any) {
        
           self.sunNode.rotation = SCNVector4Make(1, 0, 0, Float.pi / 180)
        
        if (norm == true) {
          self.sunAnimation()
            }
        else {
        self.giraPlanet()
        }
       }
  
    @IBAction func screenBtn(_ sender: Any) {
        
          var image :UIImage?
        
        //save image
          image = sceneView.snapshot()
                
        guard let img = image else { return }
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                      
        //feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let shutterView = UIView(frame: sceneView.frame)
        shutterView.backgroundColor = UIColor.black
        view.addSubview(shutterView)
        UIView.animate(withDuration: 0.3, animations: {
            shutterView.alpha = 0
        }, completion: { (_) in
            shutterView.removeFromSuperview()
        })
        
        //alert for save picture
        
        let alert = UIAlertController(title: "Your image has been saved!", message: "You can find your saved image in your gallery.", preferredStyle: .alert)
                               alert.addAction(UIAlertAction(title: "Yes, i got it!", style: .default, handler: nil))
                   self.present(alert, animated: true)
    }
    
    //Solar System Button
    @IBAction func viewSolarSystemBtn(_ sender: Any) {
      self.sceneView.scene.rootNode.enumerateChildNodes { (existingNode, _) in
               existingNode.removeFromParentNode()
           }
           self.createSun()
           self.createPlanets()
        infor = "Our planetary system is located in an outer spiral arm of the Milky Way galaxy. Our solar system consists of our star, the Sun, and everything bound to it by gravity — the planets Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus and Neptune, dwarf planets such as Pluto, dozens of moons and millions of asteroids, comets and meteoroids. Beyond our own solar system, we have discovered thousands of planetary systems orbiting other stars in the Milky Way."
    }
    
    //Earth Button
    @IBAction func viewEarthBtn(_ sender: Any) {
        
     self.sceneView.scene.rootNode.enumerateChildNodes { (existingNode, _) in
            existingNode.removeFromParentNode()
        }
        
        self.createEarth()
        
        infor = "Earth, our home, is the third planet from the sun. It's the only planet known to have an atmosphere containing free oxygen, oceans of water on its surface and, of course, life. Earth has a diameter of roughly 8,000 miles (13,000 kilometers) and is round because gravity pulls matter into a ball. But, it's not perfectly round. Earth is really an oblate spheroid, because its spin causes it to be squashed at its poles and swollen at the equator."
            
       }
       
    
    //Mars Button
    @IBAction func viewMarsBtn(_ sender: Any) {
        
        self.sceneView.scene.rootNode.enumerateChildNodes { (existingNode, _) in
               existingNode.removeFromParentNode()
           }
           
           self.createMars()
        
        infor = "Mars is the fourth planet from the Sun and is the second smallest planet in the solar system. Named after the Roman god of war, Mars is also often described as the “Red Planet” due to its reddish appearance. Mars is a terrestrial planet with a thin atmosphere composed primarily of carbon dioxide."
        
    }
    
    //function for scale with PinchGesture
    
    @objc func scaleObject(gesture: UIPinchGestureRecognizer) {

        guard let sunNode = sunNode else { return }
        if gesture.state == .changed {

            let pinchScaleX: CGFloat = gesture.scale * CGFloat((sunNode.scale.x))
            let pinchScaleY: CGFloat = gesture.scale * CGFloat((sunNode.scale.y))
            let pinchScaleZ: CGFloat = gesture.scale * CGFloat((sunNode.scale.z))
            sunNode.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
            gesture.scale = 1

        }
        if gesture.state == .ended { }

    }
    
}
