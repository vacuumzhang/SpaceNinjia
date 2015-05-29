

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
  
    
    var ship = SKSpriteNode()
    var actionMoveUp = SKAction()
    var actionMoveDown = SKAction()
    var laser = SKSpriteNode()
    var lastMissileAdded : NSTimeInterval = 0.0
    var lastLaserShoot : NSTimeInterval = 0.0
    
    let shipCategory = 0x1 << 1
    let obstacleCategory = 0x1 << 2
    var direction = true
    
    let backgroundVelocity : CGFloat = 3.0
    let missileVelocity : CGFloat = 5.0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = SKColor.whiteColor()
        self.initializingScrollingBackground()
        
        self.addLaser()
        self.topLaser()
        self.addMissile()
        self.addShip()
//        self.laserShot()
//        
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
        ship.position = CGPointMake(120, 50)
        
        self.addChild(ship)
        
        actionMoveUp = SKAction.moveByX(0, y: 30, duration: 0.2)
        actionMoveDown = SKAction.moveByX(0, y: -30, duration: 0.2)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            var touchLocation = touch.locationInNode(self)
            var previousLocation = touch.previousLocationInNode(self)
            
            // 4. Calculate new position along x for ship
            var shipX = ship.position.x + (touchLocation.x - previousLocation.x)
            var shipY = ship.position.y + (touchLocation.y - previousLocation.y)
            
            // 5. Limit x so that shpo won't leave screen to left or right
            shipX = max(shipX, ship.size.width/2)
            shipX = min(shipX, size.width - ship.size.width/2)
            
            // 6. Update ship position
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
                    bg.position = CGPointMake(bg.position.x , bg.position.y + bg.size.height * 2 - 1)
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
    
    func topLaser(){
        var TopLaserThriger = SKSpriteNode()
        TopLaserThriger = SKSpriteNode(imageNamed: "laserThriger")
        TopLaserThriger.zRotation = CGFloat(-M_PI/2)
        TopLaserThriger.setScale(0.8)
        TopLaserThriger.name = "TopLaserThriger"
        TopLaserThriger.position = CGPointMake(200, 675)
        self.addChild(TopLaserThriger)
    }
    
    func moveTopLaser(){
        self.enumerateChildNodesWithName("TopLaserThriger", usingBlock: { (node, stop) -> Void in
            if let topLaser = node as? SKSpriteNode {
                if topLaser.position.x < 0 {
                    self.direction = true
                }
                if topLaser.position.x > 377{
                    self.direction = false
                }
                
                if self.direction == false{
                    topLaser.position = CGPoint(x: topLaser.position.x - 4 , y: topLaser.position.y)
                }else {
                    topLaser.position = CGPoint(x: topLaser.position.x + 4 , y: topLaser.position.y)
                }
            }
            
        })
    }
    
    
    func addLaser(){
        var laserThriger1 = SKSpriteNode()
        var laserThriger2 = SKSpriteNode()
        var laserThriger3 = SKSpriteNode()
        var laserThriger4 = SKSpriteNode()
        
        laserThriger1 = SKSpriteNode(imageNamed: "laserThriger")
        laserThriger2 = SKSpriteNode(imageNamed: "laserThriger")
        laserThriger3 = SKSpriteNode(imageNamed: "laserThriger")
        laserThriger4 = SKSpriteNode(imageNamed: "laserThriger")
        
        laserThriger2.zRotation = CGFloat(-M_PI)
        laserThriger4.zRotation = CGFloat(-M_PI)
        
        
        laserThriger1.setScale(0.8)
        laserThriger2.setScale(0.8)
        laserThriger3.setScale(0.8)
        laserThriger4.setScale(0.8)
        
        laserThriger1.name = "laserThriger"
        laserThriger2.name = "laserThriger"
        laserThriger3.name = "laserThriger"
        laserThriger4.name = "laserThriger"
        laserThriger1.position = CGPointMake(-2, 200 )
        laserThriger2.position = CGPointMake(376, 200 )
        laserThriger3.position = CGPointMake(-2, 500 )
        laserThriger4.position = CGPointMake(376, 500 )
        self.addChild(laserThriger1)
        self.addChild(laserThriger2)
        self.addChild(laserThriger3)
        self.addChild(laserThriger4)
    }
//    
//    func laserShot(){
//        var laser = SKSpriteNode(imageNamed: "lazerShot")
//        
//        
//        laser.physicsBody = SKPhysicsBody(rectangleOfSize: laser.size)
//        laser.physicsBody?.categoryBitMask = UInt32(obstacleCategory)
//        laser.physicsBody?.dynamic = true
//        laser.physicsBody?.contactTestBitMask = UInt32(shipCategory)
//        laser.physicsBody?.collisionBitMask = 0
//        laser.physicsBody?.usesPreciseCollisionDetection = true
//        laser.name = "lazerShot"
//        
//        
//        //var random : CGFloat = CGFloat(arc4random_uniform(3))
//        
//        //laser.position = CGPointMake(315, 500)
//        
//        self.addChild(laser)
//        
//
//        
//    }
    
    func shottingLaser(whichShot: Int) {
        var laser = SKSpriteNode(imageNamed: "lazerShot")
        laser.physicsBody = SKPhysicsBody(rectangleOfSize: laser.size)
        laser.physicsBody?.categoryBitMask = UInt32(obstacleCategory)
        laser.physicsBody?.dynamic = true
        laser.physicsBody?.contactTestBitMask = UInt32(shipCategory)
        laser.physicsBody?.collisionBitMask = 0
        laser.physicsBody?.usesPreciseCollisionDetection = true
        laser.name = "lazerShot"
        
        
        switch whichShot{
            case 1:
                laser.position = CGPointMake(315, 500)
            default :
                laser.position = CGPointMake(315, 200)
            }
        self.addChild(laser)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            laser.removeFromParent()
        }
        
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
            //self.shottingLaser(0)
            
        }
        
        if currentTime - self.lastLaserShoot > 1 {
            var x = Int(arc4random_uniform(2))
            self.lastLaserShoot = currentTime + 2
            self.shottingLaser(x)
        }
        

        self.moveTopLaser()
        self.moveBackground()
        self.moveObstacle()
    }

}
