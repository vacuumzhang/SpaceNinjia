//
//  GameScene.swift
//  SpaceNinjia
//
//  Created by Ruiyon.Z on 5/26/15.
//  Copyright (c) 2015 Ruiyong Zhang. All rights reserved.
//

import SpriteKit

let SpaceShipName = "Spaceship"
let BgName = "bg"
var isFingerOnPaddle = false


class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = SKColor.whiteColor()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches.first as! UITouch
        var touchLocation = touch.locationInNode(self)
        isFingerOnPaddle = true
//        if let body = physicsWorld.bodyAtPoint(touchLocation) {
//            if body.node!.name == SpaceShipName {
//                println("Began touch on ship")
//                isFingerOnPaddle = true
//            }
//            if body.node!.name == BgName {
//                println("Began touch on bg")
//                isFingerOnPaddle = true
//            }
//            
//            
//        }
        
    }
    
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        // 1. Check whether user touched the paddle
        if isFingerOnPaddle {
            // 2. Get touch location
            var touch = touches.first as! UITouch
            var touchLocation = touch.locationInNode(self)
            var previousLocation = touch.previousLocationInNode(self)
            
            // 3. Get node for paddle
            var ship = childNodeWithName(SpaceShipName) as! SKSpriteNode
            
            // 4. Calculate new position along x for paddle
            var shipX = ship.position.x + (touchLocation.x - previousLocation.x)
            var shipY = ship.position.y + (touchLocation.y - previousLocation.y)
            
            // 5. Limit x so that paddle won't leave screen to left or right
            shipX = max(shipX, ship.size.width/2)
            shipX = min(shipX, size.width - ship.size.width/2)
            
            // 6. Update paddle position
            ship.position = CGPointMake(shipX, shipY)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        isFingerOnPaddle = false
    }
    
    
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        /* Called when a touch begins */
//        
//        for touch in (touches as! Set<UITouch>) {
//            let location = touch.locationInNode(self)
//            
//            let sprite = SKSpriteNode(imageNamed:"Spaceship")
//            
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//            
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//            
//            sprite.runAction(SKAction.repeatActionForever(action))
//            
//            self.addChild(sprite)
//        }
//    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
