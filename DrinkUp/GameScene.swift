//
//  GameScene.swift
//  DrinkUp
//
//  Created by Fabian Canas on 10/29/14.
//  Copyright (c) 2014 Fabian Canas. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    lazy var motionManager: CMMotionManager? = CMMotionManager()
    
    var touch: UITouch?
    var label: SKLabelNode?
    
    func makeBlob() -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: "spot")
        return node
    }
    
    var killNode: SKNode?
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        label = SKLabelNode(fontNamed:"Futura")
        label?.text = "Coffee?";
        label?.fontSize = 65;
        label?.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        scaleMode = SKSceneScaleMode.AspectFit
        
        var collisionLoop = self.frame
        collisionLoop.size.height += 40
        collisionLoop.origin.y += 20
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: collisionLoop)
        physicsBody?.collisionBitMask = 0x2
        
        var originPoint = collisionLoop.origin
        originPoint.y = collisionLoop.maxY
        var oppositePoint = originPoint
        oppositePoint.x += collisionLoop.width
        
        let top = SKPhysicsBody(edgeFromPoint: originPoint, toPoint: oppositePoint)
        top.contactTestBitMask = 0x1
        top.categoryBitMask = 0x1
        killNode = SKNode()
        killNode?.physicsBody = top
        
        physicsWorld.contactDelegate = self
        
        addChild(killNode!)
        
        motionManager?.deviceMotionUpdateInterval = 1.0/40.0
        motionManager?.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (motion: CMDeviceMotion!, error: NSError!) -> Void in
            self.physicsWorld.gravity = CGVectorMake(CGFloat(motion.gravity.x * 9.8), CGFloat(motion.gravity.y * 9.8))
            self.label?.zRotation = CGFloat(atan2(motion.gravity.y, motion.gravity.x) + Double(3.1415926 / 2.0))
        })
        
        addChild(label!)
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
        
        physicsBody.collisionBitMask = 0x2
        physicsBody.restitution = 0.0
        physicsBody.friction = 0.0
        physicsBody.linearDamping = 0.005
        physicsBody.density = 0.05
        physicsBody.allowsRotation = false
        physicsBody.contactTestBitMask = 0x1
        physicsBody.categoryBitMask = 0x7
        
        sprite.physicsBody = physicsBody
        self.addChild(sprite)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let spriteA = contact.bodyA.node as? SKSpriteNode
        let spriteB = contact.bodyB.node as? SKSpriteNode
        
        // We need one and only one node to be a sprite
        if (spriteA != nil && spriteB != nil) {
            return
        }
        
        if contact.bodyA.node == killNode || contact.bodyB.node == killNode {
            spriteA?.removeFromParent()
            spriteB?.removeFromParent()
        }
    }
}
