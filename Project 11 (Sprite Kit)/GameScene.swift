//
//  GameScene.swift
//  Project 11 (Sprite Kit)
//
//  Created by Edil Ashimov on 4/25/20.
//  Copyright © 2020 Edil Ashimov. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate  {
    
    var scoreLabel: SKLabelNode!
    var numberOfBallsLabel: SKLabelNode!
    var editLabel: SKLabelNode!
    var allBalls = [String]()
    var allBoxes = [SKNode]()
    
    var numberOfBalls = 5 {
        didSet {
            numberOfBallsLabel.text = "\(numberOfBalls) Balls left"
        }
    }
    
    var editingMode = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        allBalls = ["ballBlue", "ballCyan","ballGreen","ballGrey","ballPurple","ballRed","ballYellow",]
        
        self.physicsWorld.contactDelegate = self
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        numberOfBallsLabel = SKLabelNode(fontNamed: "Chalkduster")
        numberOfBallsLabel.text = "5 Balls Left"
        numberOfBallsLabel.horizontalAlignmentMode = .right
        numberOfBallsLabel.position = CGPoint(x: 800, y: 700)
        addChild(numberOfBallsLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        createBouncer(at: CGPoint(x: 0, y: 0))
        createBouncer(at: CGPoint(x: 256, y: 0))
        createBouncer(at: CGPoint(x: 512, y: 0))
        createBouncer(at: CGPoint(x: 768, y: 0))
        createBouncer(at: CGPoint(x: 1024, y: 0))
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            let objects = nodes(at: location)
            
            if objects.contains(editLabel) {
                editingMode.toggle()
            } else {
                if editingMode {
                    let size = CGSize(width: Int.random(in: 0...128), height: 16)
                    let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                    box.zRotation = CGFloat.random(in: 0...3)
                    box.position = location
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    box.name = "box"
                    allBoxes.append(box)
                    addChild(box)
                    
                } else {
                    if numberOfBalls != 0 {
                        let ballRed = SKSpriteNode(imageNamed: allBalls.randomElement()!)
                        ballRed.physicsBody = SKPhysicsBody(circleOfRadius: ballRed.size.width/2)
                        ballRed.position = CGPoint(x: location.x, y: location.y + 50)
                        ballRed.physicsBody?.restitution = 0.4
                        ballRed.name = "ball"
                        ballRed.physicsBody?.contactTestBitMask = ballRed.physicsBody!.collisionBitMask
                        addChild(ballRed)
                        numberOfBalls -= 1
                    } else {
                        restart()
                    }
                }
            }
        }
        
    }
    
    
    
    
    func createBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width/2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool)  {
        var slotbase:SKSpriteNode
        var slotGlow:SKSpriteNode
        
        if isGood {
            slotbase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotbase.name = "good"
        } else {
            slotbase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotbase.name = "bad"
            
        }
        slotGlow.position = position
        slotGlow.zPosition = -1
        slotbase.position = position
        
        slotbase.physicsBody = SKPhysicsBody(rectangleOf: slotbase.size)
        slotbase.physicsBody?.isDynamic = false
        addChild(slotGlow)
        addChild(slotbase)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collisionBettween(ball: SKNode, object: SKNode) {
        
        if object.name == "box" {
            object.removeFromParent()
        }
        if object.name == "good" {
            score += 1
            destroy(ball: ball, miss: false)
        } else if object.name == "bad" {
            score -= 1
            destroy(ball: ball, miss: true)
        }
    }
    
    func destroy(ball: SKNode, miss: Bool) {
        if !miss {
            if let fireParticles = SKEmitterNode(fileNamed: "Hit") {
                fireParticles.position = ball.position
                addChild(fireParticles)
                numberOfBalls += 1
            }   else if miss {
                if let fireParticles = SKEmitterNode(fileNamed: "Miss") {
                    fireParticles.position = ball.position
                    addChild(fireParticles)
                }
            }
        }
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let bodyA = contact.bodyA.node else { return }
        guard let bodyB = contact.bodyB.node else { return }
        
        if bodyA.name == "ball" {
            collisionBettween(ball: bodyA, object: bodyB)
            
        } else if bodyB.name == "ball" {
            collisionBettween(ball: bodyB, object: bodyA)
            
        }
    }
    
    func restart() {
        score = 0
        numberOfBalls = 5
        for box in allBoxes {
            removeChildren(in: [box])
        }
    }
    
}
