//
//  GameScene.swift
//  Ginger Cat
//
//  Created by Rich Townsend on 20/07/2015.
//  Copyright (c) 2015 FlyingTabasco. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var cat = SKSpriteNode()
    var sun = SKSpriteNode()
    var contact = SKSpriteNode()
    var skyColor = SKColor()
    var spawn = SKAction()
    var lastCrowAdded : NSTimeInterval = 0.0
    var treeTexture1 = SKTexture()
    var birdTexture1 = SKTexture()
    var trees = SKNode()
    var birds = SKNode()
    var moveAndRemoveTrees = SKAction()
    var moveAndRemoveBirds = SKAction()
    var moving = SKNode()
    var canRestart = false
    let catCategory: UInt32 = 1 << 0
    let scoreCategory: UInt32 = 1 << 3
    let contact2Category: UInt32 = 1 << 2
    let worldCategory: UInt32 = 1 << 1
    let treeCategory: UInt32 = 1 << 1
    let crowCategory: UInt32 = 1 << 2
    
    var ableToJump = true
    
    var scoreLabelNode = SKLabelNode()
    var resetLabelNode = SKLabelNode()
    var score = NSInteger()
    var highScoreLabelNode = SKLabelNode()
    var highScore = NSInteger()

    
    var viewController: GameViewController!
    var secondViewController: GameOverViewController!
    
    override func didMoveToView(view: SKView) {
         
        self.addChild(moving)
        moving.addChild(trees)
        moving.addChild(birds)

        let frame = CGRectMake(255, 0, 515, self.frame.size.height)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
    
        self.physicsWorld.gravity = CGVectorMake(0, -6)
        self.physicsWorld.contactDelegate = self
        
        treeTexture1 = SKTexture(imageNamed: "tree")
        treeTexture1.filteringMode = SKTextureFilteringMode.Nearest
        
        var distanceToMove = CGFloat(self.frame.size.width + 0.1);
        var moveTrees = SKAction.moveByX(-distanceToMove, y:0, duration:NSTimeInterval(0.006 * distanceToMove));
        var removeTrees = SKAction.removeFromParent();
        moveAndRemoveTrees = SKAction.sequence([moveTrees, removeTrees]);
        
        var spawn = SKAction.runBlock({() in self.spawnTrees()})
        var delay = SKAction.waitForDuration(NSTimeInterval(1.0))
        var spawnThenDelay = SKAction.sequence([spawn, delay])
        var spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
        
        birdTexture1 = SKTexture(imageNamed: "crow")
        birdTexture1.filteringMode = SKTextureFilteringMode.Nearest
        
        var distanceToMoveBird = CGFloat(self.frame.size.width + 2 * birdTexture1.size().width);
        var moveBirds = SKAction.moveByX(-distanceToMove, y:0, duration:NSTimeInterval(0.0040 * distanceToMoveBird));
        var removeBirds = SKAction.removeFromParent();
        moveAndRemoveBirds = SKAction.sequence([moveBirds, removeBirds]);
        
        var spawnBirds = SKAction.runBlock({() in self.spawnBird()})
        var delayBirds = SKAction.waitForDuration(NSTimeInterval(4.0))
        var spawnThenDelayBirds = SKAction.sequence([spawnBirds, delayBirds])
        var spawnThenDelayForeverBirds = SKAction.repeatActionForever(spawnThenDelayBirds)
        self.runAction(spawnThenDelayForeverBirds)
        
        skyColor = SKColor(red:113.0/255.0, green:197.0/255.0, blue:207.0/255.0, alpha:1.0)
        self.backgroundColor = skyColor
        
        var gamelaunchTimerView:TimerView = TimerView.loadingCountDownTimerViewInView(self.view!)
        gamelaunchTimerView.startTimer()
        
        var sunTexture1 = SKTexture(imageNamed: "sun")
        sunTexture1.filteringMode = SKTextureFilteringMode.Nearest
        var sunTexture2 = SKTexture(imageNamed: "sun")
        sunTexture2.filteringMode = SKTextureFilteringMode.Nearest
        
        var animSun = SKAction.animateWithTextures([sunTexture1, sunTexture2], timePerFrame: 0.2)
        var runSun = SKAction.repeatActionForever(animSun)
        
        sun = SKSpriteNode(texture: sunTexture1)
        sun.position = CGPoint(x: self.frame.size.width / 1.65, y: self.frame.size.height / 1.2 )
        sun.runAction(runSun)
        
        self.addChild(sun)
 
        var catTexture1 = SKTexture(imageNamed: "Cat1")
        catTexture1.filteringMode = SKTextureFilteringMode.Nearest
        var catTexture2 = SKTexture(imageNamed: "Cat2")
        catTexture2.filteringMode = SKTextureFilteringMode.Nearest
        
        var anim = SKAction.animateWithTextures([catTexture1, catTexture2], timePerFrame: 0.2)
        var run = SKAction.repeatActionForever(anim)
        
        cat = SKSpriteNode(texture: catTexture1)
        cat.position = CGPoint(x: self.frame.size.width / 2.2, y: self.frame.size.height / 5.1 )
        cat.runAction(run, withKey: "runningAction")
        
        cat.physicsBody = SKPhysicsBody(circleOfRadius: cat.size.height / 2.0)
        cat.physicsBody!.dynamic = true
        cat.physicsBody!.allowsRotation = false
        cat.physicsBody?.categoryBitMask = catCategory
        cat.physicsBody?.collisionBitMask = crowCategory | worldCategory
        cat.physicsBody?.contactTestBitMask = crowCategory | contact2Category
        cat.physicsBody!.restitution = -10
        
        moving.addChild(cat)

        
        var contact = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(1, 800))
        contact.position = CGPoint(x: self.frame.size.width / 3.3, y: self.frame.size.height / 2.0 )
        contact.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(1, 800))
        contact.physicsBody!.dynamic = false
        contact.physicsBody!.allowsRotation = false
        contact.physicsBody?.categoryBitMask = scoreCategory
        contact.physicsBody?.contactTestBitMask = crowCategory
        contact.physicsBody?.collisionBitMask = 0
        
        self.addChild(contact)
        
        var contact2 = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(1, 450))
        contact2.position = CGPoint(x: self.frame.size.width / 4.0, y: self.frame.size.height / 2.0 )
        contact2.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(1, 450))
        contact2.physicsBody!.dynamic = false
        contact2.physicsBody!.allowsRotation = false
        contact2.physicsBody?.categoryBitMask = contact2Category
        contact2.physicsBody?.contactTestBitMask = catCategory
        
        
        self.addChild(contact2)
        
        var dummy = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(400, 1))
        dummy.position = CGPoint(x: self.frame.size.width / 2.5, y: self.frame.size.height / 5.2 )
        dummy.color = SKColor.blueColor()
        dummy.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(400, 1))
        dummy.physicsBody!.dynamic = false
        dummy.physicsBody!.allowsRotation = false
        dummy.physicsBody?.categoryBitMask = worldCategory
        dummy.physicsBody?.collisionBitMask = 0
        
        moving.addChild(dummy)
        
        
        resetLabelNode.fontName = "Helvetica-Bold"
        resetLabelNode.position = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0 )
        resetLabelNode.hidden = true
        resetLabelNode.fontSize = 40
        resetLabelNode.alpha = 0.7
        resetLabelNode.fontColor = SKColor.redColor()
        resetLabelNode.zPosition = -30
        resetLabelNode.text = "Tap to re-start"
        self.addChild(resetLabelNode)
        
        score = 0
        scoreLabelNode.fontName = "Helvetica-Bold"
        scoreLabelNode.position = CGPoint(x: self.frame.size.width / 2.6, y: self.frame.size.height / 1.2 )
        scoreLabelNode.fontSize = 40
        scoreLabelNode.alpha = 0.7
        scoreLabelNode.fontColor = SKColor.redColor()
        scoreLabelNode.zPosition = -30
        scoreLabelNode.text = "Score \(score)"
        self.addChild(scoreLabelNode)
        

        
        highScoreLabelNode.fontName = "Helvetica-Bold"
        highScoreLabelNode.position = CGPoint(x: self.frame.size.width / 2.48, y: self.frame.size.height / 1.3 )
        highScoreLabelNode.fontSize = 30
        highScoreLabelNode.alpha = 0.7
        highScoreLabelNode.zPosition = -30
        highScoreLabelNode.text = "Highscore \(score)"
        
        var highScoreDefault = NSUserDefaults.standardUserDefaults()
        if (highScoreDefault.valueForKey("Highscore") != nil){
            highScore = highScoreDefault.valueForKey("Highscore") as! NSInteger!
            highScoreLabelNode.text = NSString(format: "Highscore : %i", highScore) as String
        }
        self.addChild(highScoreLabelNode)
        
        
        
        
        var groundTexture = SKTexture(imageNamed: "Ground")
        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
        var moveGroundSprite = SKAction.moveByX(-groundTexture.size().width, y: 0, duration: NSTimeInterval(0.006 * groundTexture.size().width))
        var resetGroundSprite = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0.0)
        var moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
        
        for var i:CGFloat = 0; i < 2 + self.frame.size.width / ( groundTexture.size().width); ++i {
            var sprite = SKSpriteNode(texture: groundTexture)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2)
            sprite.runAction(moveGroundSpritesForever)
            moving.addChild(sprite)
            
        }
        
        
        
        var skylineTexture = SKTexture(imageNamed: "Skyline")
        skylineTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        var moveSkylineSprite = SKAction.moveByX(-skylineTexture.size().width, y: 0, duration: NSTimeInterval(0.1 * skylineTexture.size().width))
        var resetSkylineSprite = SKAction.moveByX(skylineTexture.size().width, y: 0, duration: 0.0)
        var moveSkylineSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveSkylineSprite,resetSkylineSprite]))
        
        
        
        for var i:CGFloat = 0; i < 2 + self.frame.size.width / ( skylineTexture.size().width); ++i {
            var sprite = SKSpriteNode(texture: skylineTexture)
            sprite.zPosition = -20;
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2 + groundTexture.size().height)
            sprite.runAction(moveSkylineSpritesForever)
            moving.addChild(sprite)
        }
        
        
      
    }
    

    func spawnBird() {
        var birdP = SKNode()
        birdP.position = CGPointMake( self.frame.size.width + birdTexture1.size().width * 2, 0 );
        var height = UInt32( self.frame.size.height / 1 )
        var height_max = UInt32( 500 )
        var height_min = UInt32( 300 )
        var y = arc4random_uniform(height_max - height_min + 1) + height_min;
        var bird1 = SKSpriteNode(texture: birdTexture1)
        bird1.position = CGPointMake(0.0, CGFloat(y))
        bird1.physicsBody = SKPhysicsBody(rectangleOfSize: bird1.size)
        bird1.physicsBody?.dynamic = false
        bird1.physicsBody?.categoryBitMask = crowCategory
        bird1.physicsBody?.collisionBitMask = catCategory | scoreCategory
        bird1.physicsBody?.contactTestBitMask = scoreCategory
        birdP.addChild(bird1)
        
        birdP.runAction(moveAndRemoveBirds)
        
        birds.addChild(birdP)
        
    }

    
    
    func spawnTrees() {
        var treeP = SKNode()
        treeP.position = CGPointMake( self.frame.size.width + treeTexture1.size().width * 2, 0 );
        treeP.zPosition = -10;
        
        var height = UInt32( self.frame.size.height / 4 )
        var y = arc4random() % height;
        
        var tree1 = SKSpriteNode(texture: treeTexture1)
        tree1.position = CGPointMake(0.0, CGFloat(y))
        tree1.physicsBody = SKPhysicsBody(rectangleOfSize: tree1.size)
        tree1.physicsBody?.dynamic = false
        tree1.physicsBody?.categoryBitMask = treeCategory;
        tree1.physicsBody?.collisionBitMask = 0
        tree1.physicsBody?.contactTestBitMask = 0
        treeP.addChild(tree1)
        
        
        
        treeP.runAction(moveAndRemoveTrees)
        
     //   trees.addChild(treeP)
        
    }
    
//    func addCrow() {
//
//        
//        
//        var crow = SKSpriteNode(imageNamed: "crow")
//        crow.physicsBody = SKPhysicsBody(circleOfRadius: crow.size.height / 2.0)
//        crow.physicsBody?.dynamic = true
//        crow.physicsBody?.categoryBitMask = crowCategory
//        crow.physicsBody?.contactTestBitMask = catCategory
//        crow.physicsBody?.collisionBitMask = catCategory | worldCategory
//        crow.physicsBody?.velocity = CGVector(dx: -700, dy: 100)
////        crow.physicsBody?.angularVelocity = -0
////        crow.physicsBody?.linearDamping = 2
////        crow.physicsBody?.applyAngularImpulse(200)
//        crow.physicsBody?.angularDamping = 0
////        crow.name = "crow"
////        var random : CGFloat = CGFloat(arc4random_uniform(300))
//        crow.position = CGPoint(x: self.frame.size.width / 1.4, y: self.frame.size.height / 2.0 )
//       
//        
//        var wait = SKAction.waitForDuration(7.5)
//        var runs = SKAction.runBlock {
//                crow.runAction(self.moveAndRemoveCrows)
//                self.crows.addChild(crow)
//        }
// //       crows.runAction(SKAction.sequence([wait, runs]))
//        
//        
//    }
    
    func resetScene() {
        

        
        birds.removeAllChildren()
        trees.removeAllChildren()
        moving.speed = 1
        score = 0;
        scoreLabelNode.text = "Score \(score)"
        
        cat.position = CGPoint(x: self.frame.size.width / 2.2, y: self.frame.size.height / 5.1 )
        cat.physicsBody?.velocity = CGVectorMake(0, 0)
        cat.physicsBody?.collisionBitMask = crowCategory | worldCategory;
        cat.zRotation = 0.0;
        
        return countdown()
        
    }
    
    override func  touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */

        if ableToJump == true {
        if (moving.speed > 0){
            
            cat.physicsBody!.velocity = CGVectorMake(0, 0)
            cat.physicsBody!.applyImpulse(CGVectorMake(0, 30))

                    } else if (canRestart) {
            resetLabelNode.hidden = true
            self.resetScene()
            }
        }
    }
    
    
    func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if( value > max ) {
            return max;
        } else if( value < min ) {
            return min;
        } else {
            return value;
        }
        
}

    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if (moving.speed > 0){
           cat.zRotation = self.clamp( -1, max: 0.2, value: cat.physicsBody!.velocity.dy * ( cat.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001 ) );cat.zRotation = self.clamp( -1, max: 0.2, value: cat.physicsBody!.velocity.dy * ( cat.physicsBody!.velocity.dy < 0 ? 0.001 : 0.001 ) );
        
        }
        
        
        if currentTime - self.lastCrowAdded > 1 && moving.speed > 0     {
            
        }
        
        if (score > highScore) {
            highScore = score
            highScoreLabelNode.text = NSString(format: "Highscore : %i", highScore) as String
            
            var highscoreDefault = NSUserDefaults.standardUserDefaults()
            highscoreDefault.setValue(highScore, forKey: "Highscore")
            highscoreDefault.synchronize()
        }
        
        if cat.physicsBody?.velocity.dy == 0 {
            ableToJump = true
            cat.speed = 1
            
            
            
        }
        else {
            ableToJump = false
            cat.speed = 0
            var catTexture1 = SKTexture(imageNamed: "Cat1")
        }
        
    }
    

    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if( moving.speed > 0 ) {
            
  //          if((contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory){
                
                if contact.bodyA.categoryBitMask == crowCategory && contact.bodyB.categoryBitMask == scoreCategory {
                    
                
                score++
                scoreLabelNode.text = "Score \(score)"
            }else {
                
                moving.speed = 0;
                
                self.removeActionForKey("flash")
                var turnBackgroundRed = SKAction.runBlock({() in self.setBackgroundColorRed()})
                var wait = SKAction.waitForDuration(0.05)
                var turnBackgroundWhite = SKAction.runBlock({() in self.setBackgroundColorWhite()})
                var turnBackgroundSky = SKAction.runBlock({() in self.setBackgroundColorSky()})
                var sequenceOfActions = SKAction.sequence([turnBackgroundRed,wait,turnBackgroundWhite,wait, turnBackgroundSky])
                var repeatSequence = SKAction.repeatAction(sequenceOfActions, count: 4)
                cat.physicsBody?.collisionBitMask = worldCategory
                var rotateCat = SKAction.rotateByAngle(0.01, duration: 0.003)
                var canRestartAction = SKAction.runBlock({() in self.letItRestart()})
                var groupOfActions = SKAction.group([repeatSequence, canRestartAction])
                self.runAction(groupOfActions, withKey: "flash")
                resetLabelNode.hidden = false
                return segue()
                
            }
 
        }
    
    }
    
    func countdown() {
        var gamelaunchTimerView:TimerView = TimerView.loadingCountDownTimerViewInView(self.view!)
        gamelaunchTimerView.startTimer()
        
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "GameOver")
        {
            let destVC = (segue.destinationViewController as? GameOverViewController)!
        
        }
    }
    
    func segue(){
        self.viewController.performSegueWithIdentifier("GameOver", sender: self)
        
    }

  
        func killCatSpeed() {
            cat.speed = 0
        }
    
    
        func letItRestart() {
            canRestart = true
        }
    
    func setBackgroundColorRed() {
        self.backgroundColor = UIColor.redColor()
    }
    
    func setBackgroundColorWhite() {
        self.backgroundColor = UIColor.whiteColor()
    }
    
    func setBackgroundColorSky() {
        self.backgroundColor = SKColor(red:113.0/255.0, green:197.0/255.0, blue:207.0/255.0, alpha:1.0)
    }
    
}


