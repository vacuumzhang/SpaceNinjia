//
//  GameViewController.swift
//  spaceninja
//
//  Created by Yanbo Chen on 5/26/15.
//  Copyright (c) 2015 Yanbo. All rights reserved.
//

import UIKit
import SpriteKit
class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameStartScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }


}
