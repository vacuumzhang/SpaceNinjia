
import UIKit
import SpriteKit

class GameStartScene: SKScene {
    override init(size: CGSize) {
        super.init(size: size)
        
        //1
        self.backgroundColor = SKColor.whiteColor()
        
        //2
        let message = "Game Start"
        
        //3
        var label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(label)
        
        //4
        let startMessage = "Game Start"
        var startButton = SKLabelNode(fontNamed: "Chalkduster")
        startButton.text = startMessage
        startButton.fontColor = SKColor.blackColor()
        startButton.position = CGPointMake(self.size.width/2, 50)
        startButton.name = "Start"
        self.addChild(startButton)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location) //1
            if node.name == "Start" { //2
                let reveal : SKTransition = SKTransition.flipHorizontalWithDuration(0.5)
                let scene = GameScene(size: self.view!.bounds.size)
                scene.scaleMode = .AspectFill
                self.view?.presentScene(scene, transition: reveal)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

   
}
