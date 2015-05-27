//
//  GameScene.swift
//  spaceninja
//
//  Created by Yanbo Chen on 5/26/15.
//  Copyright (c) 2015 Yanbo. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
  
    
    var ship = SKSpriteNode()
    var actionMoveUp = SKAction()
    var actionMoveDown = SKAction()
    var lastMissileAdded : NSTimeInterval = 0.0
    
    let shipCategory = 0x1 << 1
    let obstacleCategory = 0x1 << 2
    
    let backgroundVelocity : CGFloat = 3.0
    let missileVelocity : CGFloat = 5.0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = SKColor.whiteColor()
        self.initializingScrollingBackground()
        
        self.addMissile()
        self.addShip()
        
        // Making self delegate of physics world
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
    }
    
    func addShip() {
        // Initializing spaceship node
        ship = SKSpriteNode(imageNamed: "Spaceship")
        ship.setScale(0.2)
        
        // Adding SpriteKit physics body for collision detection
        ship.physicsBody = SKPhysicsBody(rectangleOfSize: ship.size)
        ship.physicsBody?.categoryBitMask = UInt32(shipCategory)
        ship.physicsBody?.dynamic = true
        ship.physicsBody?.contactTestBitMask = UInt32(obstacleCategory)
        ship.physicsBody?.collisionBitMask = 0
        ship.name = "ship"
        ship.position = CGPointMake(120, 160)
        
        self.addChild(ship)
        
        actionMoveUp = SKAction.moveByX(0, y: 30, duration: 0.2)
        actionMoveDown = SKAction.moveByX(0, y: -30, duration: 0.2)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            var touchLocation = touch.locationInNode(self)
            var previousLocation = touch.previousLocationInNode(self)
            
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

    
    func initializingScrollingBackground() {
        for var index = 0; index < 2; ++index {
            let bg = SKSpriteNode(imageNamed: "Space")
            bg.setScale(1.2)
            bg.position = CGPoint(x: 0, y: index * Int(bg.size.height))
            bg.anchorPoint = CGPointZero
            bg.name = "background"
            self.addChild(bg)
        }
    }
    func moveBackground() {
        self.enumerateChildNodesWithName("background", usingBlock: { (node, stop) -> Void in
            if let bg = node as? SKSpriteNode {
                bg.position = CGPoint(x: bg.position.x, y: bg.position.y  - self.backgroundVelocity)
                
                // Checks if bg node is completely scrolled off the screen, if yes, then puts it at the end of the other node.
                if bg.position.y <= -bg.size.height {
                    bg.position = CGPointMake(bg.position.x , bg.position.y + bg.size.height * 2)
                }
            }
        })
    }
    
    func addMissile() {
        // Initializing spaceship node
        var missile = SKSpriteNode(imageNamed: "Missile")
        missile.setScale(0.15)
        
        // Adding SpriteKit physics body for collision detection
        missile.physicsBody = SKPhysicsBody(rectangleOfSize: missile.size)
        missile.physicsBody?.categoryBitMask = UInt32(obstacleCategory)
        missile.physicsBody?.dynamic = true
        missile.physicsBody?.contactTestBitMask = UInt32(shipCategory)
        missile.physicsBody?.collisionBitMask = 0
        missile.physicsBody?.usesPreciseCollisionDetection = true
        missile.name = "missile"
        
        // Selecting random y position for missile
        var random : CGFloat = CGFloat(arc4random_uniform(350))
        missile.position = CGPointMake(random, self.frame.size.height + 20)
        self.addChild(missile)
    }
    
    func moveObstacle() {
        self.enumerateChildNodesWithName("missile", usingBlock: { (node, stop) -> Void in
            if let obstacle = node as? SKSpriteNode {
                obstacle.position = CGPoint(x: obstacle.position.x , y: obstacle.position.y - self.missileVelocity)
                if obstacle.position.y < 0 {
                    obstacle.removeFromParent()
                }
            }
        })
    }
    
    func addLaser(){
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & UInt32(shipCategory)) != 0 && (secondBody.categoryBitMask & UInt32(obstacleCategory)) != 0 {
            ship.removeFromParent()
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let scene = GameOverScene(size: self.size)
            self.view?.presentScene(scene, transition: reveal)
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if currentTime - self.lastMissileAdded > 1 {
            self.lastMissileAdded = currentTime + 1
            self.addMissile()
        }
        
        self.moveBackground()
        self.moveObstacle()
    }

}
