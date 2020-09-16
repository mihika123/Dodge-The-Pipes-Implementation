//
//  GameScene.swift
//  Dodge the Pipes
//
//  Created by Mihikaa Goenka on 9/12/19.
//  Copyright © 2019 Mihikaa Goenka. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let birdTimeFrame = 0.1
    let maxMovement: CGFloat = 3
    let backgroundAnimatedInSeconds: TimeInterval = 7
    
    var bird: SKSpriteNode = SKSpriteNode()
    var background: SKSpriteNode = SKSpriteNode()
    var scoreLabel: SKLabelNode = SKLabelNode()
    var score: Int = 0
    
    //state initializers
    var gameIsOver: Bool = false
    var gameIsOverLabel: SKLabelNode = SKLabelNode()
    
    var timer: Timer = Timer()
    
    enum ObjectType: UInt32{
        case bird = 1
        case object = 2
        case gap = 4
    }
    
    //    private var label : SKLabelNode?
    //    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) -> Void {
        self.physicsWorld.contactDelegate = self
        initializeGameScene()
    }
    
    func initializeGameScene() -> Void {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.createPillars), userInfo: nil, repeats: true)
        createBackground()
        createBird()
        createPillars()
    }
    
    func setScoreStyle(){
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = 80
        scoreLabel.text = "0"
    }
    
    func setMessageScoreStyle(){
        gameIsOverLabel.fontName = "Helvetica-Bold"
        gameIsOverLabel.fontSize = 50
    }
    
    func createBird() -> Void {
        let bird1 = SKTexture(imageNamed: "bird1")
        let bird2 = SKTexture(imageNamed: "bird2")
        
        let animation = SKAction.animate(with: [bird1,bird2], timePerFrame: birdTimeFrame)
        let birdMovement = SKAction.repeatForever(animation)
        
        bird = SKSpriteNode(texture: bird1)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bird.run(birdMovement)
        
        //Code executed for collisions
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird1.size().height / 2)
        bird.physicsBody!.isDynamic = false
        bird.physicsBody!.contactTestBitMask = ObjectType.object.rawValue
        bird.physicsBody!.categoryBitMask = ObjectType.bird.rawValue
        bird.physicsBody!.collisionBitMask = ObjectType.bird.rawValue
        
        self.addChild(bird)
        createGround()
        self.setScoreStyle()
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 100)
        self.addChild(scoreLabel)
    }
    
    func createBackground() -> Void {
        let backgroundTexture = SKTexture(imageNamed: "background")
        let moveBackgroundAnimation = SKAction.move(by: CGVector(dx: -backgroundTexture.size().width, dy: 0), duration: backgroundAnimatedInSeconds)
        let shiftBackgroundAnimation = SKAction.move(by: CGVector(dx: backgroundTexture.size().width, dy: 0), duration: 0)
        let backgroundAnimation = SKAction.sequence([moveBackgroundAnimation, shiftBackgroundAnimation])
        let moveBackgroundForever = SKAction.repeatForever(backgroundAnimation)
        
        var i: CGFloat = 0
        while i < maxMovement{
            background = SKSpriteNode(texture: backgroundTexture)
            background.position = CGPoint(x: backgroundTexture.size().width * i, y: self.frame.midY)
            background.size.height = self.frame.height
            background.run(moveBackgroundForever)
            
            self.addChild(background)
            
            i=i+1
            background.zPosition = -2
        }
    }
    
    @objc func createPillars() -> Void{
        let gapHeight = bird.size.height * 4
        let movePillars = SKAction.move(by: CGVector(dx: -2*self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        let deletePillars = SKAction.removeFromParent()
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        let moveAndDeletePillars = SKAction.sequence([movePillars, deletePillars])
        
        let pillarOffset = CGFloat(movementAmount) - self.frame.height / 4
        
        makePillar1(moveAndDeletePillars, gapHeight, pillarOffset)
        makePillar2(moveAndDeletePillars, gapHeight, pillarOffset)
        makeGap(moveAndDeletePillars, gapHeight, pillarOffset)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameIsOver == false{
            if (contact.bodyA.categoryBitMask == ObjectType.gap.rawValue || contact.bodyB.categoryBitMask == ObjectType.gap.rawValue){
                score += 1
                scoreLabel.text = String(score)
            }
            else{
                resetGame()
                setMessageScoreStyle()
                gameIsOverLabel.text = "GAME OVER"
                gameIsOverLabel.position = CGPoint(x: self.frame.midY, y: self.frame.midY)
                self.addChild(gameIsOverLabel)
            }
        }
    }
    
    func setPillarLocation(_ pillar: SKSpriteNode){
        pillar.zPosition = -1
    }
    
    func makePillar1(_ moveAndDeletePillars: SKAction, _ gapHeight: CGFloat, _ pillarOffset: CGFloat){
        let pillar1Texture = SKTexture(imageNamed: "pillar1")
        let pillar1 = SKSpriteNode(texture: pillar1Texture)
        pillar1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pillar1Texture.size().height / 2 + gapHeight / 2 + pillarOffset)
        pillar1.run(moveAndDeletePillars)
        pillar1.physicsBody = SKPhysicsBody(rectangleOf: pillar1Texture.size())
        pillar1.physicsBody!.isDynamic = false
        
        pillar1.physicsBody!.contactTestBitMask = ObjectType.object.rawValue
        pillar1.physicsBody!.categoryBitMask = ObjectType.object.rawValue
        pillar1.physicsBody!.collisionBitMask = ObjectType.object.rawValue
        setPillarLocation(pillar1)
        self.addChild(pillar1)
    }
    
    func makePillar2(_ moveAndDeletePillars: SKAction, _ gapHeight: CGFloat, _ pillarOffset: CGFloat){
        let pillar2Texture = SKTexture(imageNamed: "pillar2")
        let pillar2 = SKSpriteNode(texture: pillar2Texture)
        pillar2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pillar2Texture.size().height / 2 - gapHeight / 2.0 + pillarOffset)
        pillar2.run(moveAndDeletePillars)
        pillar2.physicsBody = SKPhysicsBody(rectangleOf: pillar2Texture.size())
        pillar2.physicsBody!.isDynamic = false
        
        pillar2.physicsBody!.contactTestBitMask = ObjectType.object.rawValue
        pillar2.physicsBody!.categoryBitMask = ObjectType.object.rawValue
        pillar2.physicsBody!.collisionBitMask = ObjectType.object.rawValue
        setPillarLocation(pillar2)
        self.addChild(pillar2)
    }
    
    func makeGap(_ moveAndDeletePillars: SKAction, _ gapHeight: CGFloat, _ pillarOffset: CGFloat){
        let pillarTexture = SKTexture(imageNamed: "pillar1")
        
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pillarOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pillarTexture.size().width, height: gapHeight))
        
        gap.physicsBody!.isDynamic = false
        gap.run(moveAndDeletePillars)
        
        gap.physicsBody!.contactTestBitMask = ObjectType.bird.rawValue
        gap.physicsBody!.categoryBitMask = ObjectType.gap.rawValue
        gap.physicsBody!.collisionBitMask = ObjectType.gap.rawValue
        
        self.addChild(gap)
    }
    
    func createGround(){
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width
            , height: 1))
        ground.physicsBody!.isDynamic = false
        ground.physicsBody!.contactTestBitMask = ObjectType.object.rawValue
        ground.physicsBody!.categoryBitMask = ObjectType.object.rawValue
        ground.physicsBody!.collisionBitMask = ObjectType.object.rawValue
        
        self.addChild(ground)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameIsOver == false{
            bird.physicsBody!.isDynamic = true
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
        } else{
            beginGame()
            removeAllChildren()
            initializeGameScene()
        }
    }
    
    func beginGame(){
        gameIsOver = false
        score = 0
        self.speed = 1
    }
    
    func resetGame(){
        self.speed = 0
        gameIsOver = true
        timer.invalidate()
    }
}



