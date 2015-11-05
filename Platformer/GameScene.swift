//
//  GameScene.swift
//  Platformer
//
//  Created by cisnerosa on 10/23/15.
//  Copyright (c) 2015 cisnerosa. All rights reserved.
//
import SpriteKit

class GameScene: SKScene {
    var tileMap = JSTileMap(named: "testMap.tmx")
    let cameraNode = SKCameraNode()
    
    
    let playerNode = SKSpriteNode(imageNamed: "playerRight.png")
    let DPadNode = SKSpriteNode(imageNamed: "Dpad.png")
    let jumpNode = SKSpriteNode(imageNamed: "jumpButton.png")
    var direction = "resting"
    var xVelocity = 0
    var dPadTracker = [UITouch:SKNode]()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.position = CGPoint(x: 0, y: 0) //Change the scenes anchor point to the bottom left and position it correctly
        
        
        setupMap()
        
        cameraNode.position = CGPoint(x: 330, y: 180)
        self.camera = cameraNode
        cameraNode.xScale = 1
        cameraNode.yScale = 1
        
        //setup rest of scene
        playerNode.position = CGPoint(x: 416, y: 250)
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerNode.size.width/2.0)
        playerNode.physicsBody!.dynamic = true
        playerNode.physicsBody!.allowsRotation = false
        playerNode.xScale = 0.5
        playerNode.yScale = 0.5
        
        DPadNode.xScale = 1.5
        DPadNode.yScale = 1.5
        DPadNode.position = CGPoint(x: ((cameraNode.frame.size.width)-DPadNode.size.width) + 10, y: ((cameraNode.frame.size.height)-DPadNode.size.height) + 20)
        DPadNode.name = "DPad"
        
        jumpNode.xScale = 0.5
        jumpNode.yScale = 0.5
        jumpNode.position = CGPoint(x: 200, y: -50)
        jumpNode.name = "jumpButton"
        
        
        
        self.addChild(cameraNode)
        
        
        self.addChild(playerNode)
        cameraNode.addChild(DPadNode)
        cameraNode.addChild(jumpNode)
        
        
       
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(cameraNode)
            let node = cameraNode.nodeAtPoint(location)
            if node.name == "DPad"{
                let location = touch.locationInNode(node)
                dPadTracker[touch] = node
                if location.x > 0 {
                    //right
                    xVelocity = 1
                    playerNode.texture = SKTexture(imageNamed: "playerRight.png")
                }
                else {
                    //left
                    xVelocity = -1
                    playerNode.texture = SKTexture(imageNamed: "playerLeft.png")
                }
            }
            else if node.name == "jumpButton" {
                if playerNode.physicsBody!.velocity.dy < 0.08 {
                    playerNode.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 60))
                }
            }
            
                
            
        }
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(cameraNode)
            let node = cameraNode.nodeAtPoint(location)
            if node.name == "DPad" {
                let location = touch.locationInNode(node)
                dPadTracker[touch] = node
                if location.x > 0 {
                    xVelocity = 1
                    playerNode.texture = SKTexture(imageNamed: "playerRight.png")
                }
                else {
                    xVelocity = -1
                    playerNode.texture = SKTexture(imageNamed: "playerLeft.png")
                }
            }
        }
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if dPadTracker[touch] != nil {
                dPadTracker[touch] = nil
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        cameraNode.position = playerNode.position
        if !dPadTracker.isEmpty {
            playerNode.physicsBody!.applyImpulse(CGVector(dx: xVelocity, dy: 0))
        }
       
        
    }
    func setupMap() {
        tileMap.position = CGPoint(x: 0, y: 0)
        addFloor()
        addChild(tileMap)
    }
    func addFloor() {
        for var a = 0; a < Int(tileMap.mapSize.width); a++ { //Go through every point across the tile map
            for var b = 0; b < Int(tileMap.mapSize.height); b++ { //Go through every point up the tile map
                let layerInfo:TMXLayerInfo = tileMap.layers.firstObject as! TMXLayerInfo //Get the first layer (you may want to pick another layer if you don't want to use the first one on the tile map)
                let point = CGPoint(x: a, y: b) //Create a point with a and b
                let gid = layerInfo.layer.tileGidAt(layerInfo.layer.pointForCoord(point)) //The gID is the ID of the tile. They start at 1 up the the amount of tiles in your tile set.
                
                switch gid {
                case 1,2,3,5,8,9,10,12,13:
                    let node = layerInfo.layer.tileAtCoord(point) //I fetched a node at that point created by JSTileMap
                    node.physicsBody = SKPhysicsBody(rectangleOfSize: node.frame.size) //I added a physics body
                    node.physicsBody?.dynamic = false
                    node.name = "tile"
                case 4:
                    //top right
                    //done
                    let node = layerInfo.layer.tileAtCoord(point)
                    
                    let path = CGPathCreateMutable()
                    CGPathMoveToPoint(path, nil, -node.size.width/2.0, node.size.height/2.0)
                    CGPathAddLineToPoint(path, nil, node.size.width/2.0, -node.size.height/2.0)
                    CGPathAddLineToPoint(path, nil, -node.size.width/2.0, -node.size.height/2.0)
                    
                    node.physicsBody = SKPhysicsBody(polygonFromPath: path) //I added a physics body
                    node.physicsBody?.dynamic = false
                    node.name = "tile"
                case 6:
                    //bottom left
                    let node = layerInfo.layer.tileAtCoord(point)
                    
                    
                    let path = CGPathCreateMutable()
                    CGPathMoveToPoint(path, nil, -node.size.width/2.0 , node.size.height/2.0)
                    CGPathAddLineToPoint(path, nil, node.size.width/2.0, node.size.height/2.0)
                    CGPathAddLineToPoint(path, nil, node.size.width/2.0, -node.size.height/2.0)
                    
                    node.physicsBody = SKPhysicsBody(polygonFromPath: path)
                    node.physicsBody?.dynamic = false
                    node.name = "tile"
                case 7:
                    //top left
                    let node = layerInfo.layer.tileAtCoord(point)
                    
                    let path = CGPathCreateMutable()
                    CGPathMoveToPoint(path, nil, -node.size.width/2.0, -node.size.width/2.0)
                    CGPathAddLineToPoint(path, nil,node.size.width/2.0, node.size.height/2.0)
                    CGPathAddLineToPoint(path, nil, node.size.width/2.0, -node.size.height/2.0)
                    
                    node.physicsBody = SKPhysicsBody(polygonFromPath: path)
                    node.physicsBody?.dynamic = false
                    node.name = "tile"
                case 11:
                    //bottom right
                   
                    let node = layerInfo.layer.tileAtCoord(point)
                    
                    let path = CGPathCreateMutable()
                    CGPathMoveToPoint(path, nil, -node.size.width/2.0, node.size.width/2.0)
                    CGPathAddLineToPoint(path, nil,node.size.width/2.0, node.size.height/2.0)
                    CGPathAddLineToPoint(path, nil, -node.size.width/2.0, -node.size.height/2.0)

                    node.physicsBody = SKPhysicsBody(polygonFromPath: path)
                    node.physicsBody?.dynamic = false
                    node.name = "tile"
                default:
                    //empty tile
                    print("empty tile")
                }
            }
        }
    }
}



