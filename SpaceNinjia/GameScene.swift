

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var label = SKLabelNode()
    
    var ship = SKSpriteNode()
    
    var gameStart = true
    var startTime : CGFloat = 0.0
    var gameTime : CGFloat = 0.0
    
    var bgSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bgMusic", ofType: "wav")!)
    var hitSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("hit", ofType: "wav")!)
    var audioPlayer1 = AVAudioPlayer()
    var audioPlayer2 = AVAudioPlayer()

    
    var TopLaserThriger = SKSpriteNode()
    var laser = SKSpriteNode()
    var actionMoveUp = SKAction()
    var actionMoveDown = SKAction()
    //var laser = SKSpriteNode()
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
        
        audioPlayer1 = AVAudioPlayer(contentsOfURL: bgSound, error: nil)
        audioPlayer2 = AVAudioPlayer(contentsOfURL: hitSound, error: nil)
        audioPlayer1.prepareToPlay()
        audioPlayer2.prepareToPlay()
        
        self.addLaser()
        self.topLaser()
        self.addMissile()
        self.addShip()
//        self.laserShot()
//        
        // Making self delegate of physics world
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        
        let message = "Score"
        
        //3
        label = SKLabelNode(fontNamed: "Score")
        //label.text = message
        label.fontSize = 20
        label.fontColor = SKColor.whiteColor()
        label.position = CGPointMake(self.size.width - 100, 10)
        self.addChild(label)
    }
    
    func addShip() {
        // Initializing spaceship node
        ship = SKSpriteNode(imageNamed: "Spaceship")
        ship.setScale(0.1)
        
        // Adding SpriteKit physics body for collision detection
        //ship.physicsBody = SKPhysicsBody(rectangleOfSize: ship.size)
        ship.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 20, height: 20))
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
        missile.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 22.65, height: 20))
        missile.physicsBody?.categoryBitMask = UInt32(obstacleCategory)
        missile.physicsBody?.dynamic = true
        missile.physicsBody?.contactTestBitMask = UInt32(shipCategory)
        missile.physicsBody?.collisionBitMask = 0
        missile.physicsBody?.usesPreciseCollisionDetection = true
        missile.name = "missile"
        missile.zPosition = 1.1
        
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
        TopLaserThriger.position = CGPointMake(300, 675)
        TopLaserThriger.zPosition = 1
        self.addChild(TopLaserThriger)
        
    }
    
    func moveTopLaser() {
        
        self.enumerateChildNodesWithName("TopLaserThriger", usingBlock: { (node, stop) -> Void in
            
            if let topLaser = node as? SKSpriteNode {
                
                if topLaser.position.x < 0 {
                    self.direction = true
                }
                if topLaser.position.x > 377{
                    self.direction = false
                }
                
                if self.direction == false{
                    topLaser.position = CGPoint(x: topLaser.position.x - 3 , y: topLaser.position.y)
                }else {
                    topLaser.position = CGPoint(x: topLaser.position.x + 3 , y: topLaser.position.y)
                    
                }
                //print(topLaser.position)
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
        laserThriger2.position = CGPointMake(376, 202 )
        laserThriger3.position = CGPointMake(-2, 500 )
        laserThriger4.position = CGPointMake(376, 502 )
        
        laserThriger1.zPosition = 1
        laserThriger2.zPosition = 1
        laserThriger3.zPosition = 1
        laserThriger4.zPosition = 1
        
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
        laser.name = "lazerShotHorizontal"
        
        
        switch whichShot{
            case 1:
                laser.position = CGPointMake(187, 500)
            default :
                laser.position = CGPointMake(187, 200)
            }
        self.addChild(laser)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            laser.removeFromParent()
        }
        
    }
    
    func topLaserShotting(){
        var laser = SKSpriteNode(imageNamed: "lazerTop")
        laser.zRotation = CGFloat(-M_PI/2)
        laser.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 700, height: 20))
        laser.physicsBody?.categoryBitMask = UInt32(obstacleCategory)
        laser.physicsBody?.dynamic = true
        laser.physicsBody?.contactTestBitMask = UInt32(shipCategory)
        laser.physicsBody?.collisionBitMask = 0
        laser.physicsBody?.usesPreciseCollisionDetection = true
        laser.name = "lazerShot"
        //laser.anchorPoint = CGPointMake(0.5, 0.5)
        self.enumerateChildNodesWithName("TopLaserThriger", usingBlock: { (node, stop) -> Void in
            if let topLaser = node as? SKSpriteNode {
               laser.position = CGPoint(x: topLaser.position.x, y: topLaser.position.y - 300)
            }
            
        })

        self.addChild(laser)
        
    }
    
    func moveLaser() {
        
        self.enumerateChildNodesWithName("lazerShot", usingBlock: { (node, stop) -> Void in
            if let laserTop = node as? SKSpriteNode{
                //print(laserTop.position)
                
                if laserTop.position.x < 0 {
                    self.direction = true
                }
                if laserTop.position.x > 377{
                    self.direction = false
                }
                
                if self.direction == false{
                    laserTop.position = CGPoint(x: laserTop.position.x - 3 , y: laserTop.position.y)
                }else {
                    laserTop.position = CGPoint(x: laserTop.position.x + 3 , y: laserTop.position.y)
                    
                }
                let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                    Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    laserTop.removeFromParent()
                }


                
            }
        })
    }

    
    func didBeginContact(contact: SKPhysicsContact) {
        audioPlayer2.play()
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
            self.topLaserShotting()

        }
        
        if gameStart{
            startTime = CGFloat(currentTime)
            gameStart = false
        }
        
        gameTime = CGFloat(currentTime) - startTime
        
        //print("\(startTime)")
        
        self.label.text = "Score: \(Int(gameTime))"
        //self.topLaserShotting()
        self.moveLaser()
        self.moveTopLaser()
        self.moveBackground()
        self.moveObstacle()
        
        audioPlayer1.play()
    }

}
