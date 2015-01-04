//
//  GameScene.swift
//  DrinkUp
//
//  Created by Fabian Canas on 10/29/14.
//  Copyright (c) 2014 Fabian Canas. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    
    lazy var motionManager: CMMotionManager? = CMMotionManager()
    
    var touch: UITouch?
    var label: SKLabelNode?
    
    func makeBlob() -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: "spot")
        return node
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        label = SKLabelNode(fontNamed:"Futura")
        label?.text = "Coffee?";
        label?.fontSize = 65;
        label?.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.scaleMode = SKSceneScaleMode.AspectFit
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.collisionBitMask = 0xffff
        
        motionManager?.deviceMotionUpdateInterval = 1.0/40.0
        motionManager?.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (motion: CMDeviceMotion!, error: NSError!) -> Void in
            self.physicsWorld.gravity = CGVectorMake(CGFloat(motion.gravity.x * 9.8), CGFloat(motion.gravity.y * 9.8))
            self.label?.zRotation = CGFloat(atan2(motion.gravity.y, motion.gravity.x) + Double(3.1415926 / 2.0))
        })
        
        self.addChild(label!)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        for touch in touches {
            let nodes = self.nodesAtPoint(touch.locationInNode(self))
            for node in nodes {
                if node as SKNode == label! {
                    
                    
                    label!.text = (label!.text=="Coffee?") ? "Beer?":"Coffee?"
                }
            }
        }
        
        touch = touches.anyObject() as? UITouch
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if touch != nil && touches.containsObject(touch!) {
            touch = nil
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if touch == nil || self.children.count > 300 {
            return
        }
        
        let location = touch!.locationInNode(self)
        let sprite = SKSpriteNode(imageNamed:"spot")
        sprite.xScale = 4
        sprite.yScale = 4
        sprite.blendMode = SKBlendMode.Add
        
        sprite.position = location
        
        let physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/10)
        
        physicsBody.collisionBitMask = 1
        physicsBody.restitution = 0.0
        physicsBody.friction = 0.0
        physicsBody.linearDamping = 0.005
        physicsBody.density = 0.05
        physicsBody.allowsRotation = false
        
        sprite.physicsBody = physicsBody
        self.addChild(sprite)
    }
}
