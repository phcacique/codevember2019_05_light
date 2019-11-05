//
//  GameScene.swift
//  Light
//
//  Created by Pedro Cacique on 05/11/19.
//  Copyright © 2019 Pedro Cacique. All rights reserved.
//

import SpriteKit
import GameplayKit
import SwiftGameOfLife

class GameScene: SKScene {
    
    let threshold:Int = 100
    let border:CGFloat = 50
    var imageMatrix: [[Bool]] = []
    var colors:[[UIColor]] = []
    var grid:Grid = Grid()
    var renderTime: TimeInterval = 0
    let duration: TimeInterval = 0.5
    var isPlaying: Bool = true
    let color: UIColor = UIColor(red: 72/255, green:219/255, blue:251/255, alpha: 1)
    let images:[String] = ["luz", "light", "luce", "lumiere", "cahaya", "urdu", "hebraico"]
    var currentImage:Int = 0
    
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor(red:34/255, green:47/255, blue:62/255, alpha: 1)
        
        restart()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right

        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(tap)
    }
    
    func restart(){
        colors = []
        imageMatrix = []
        
        removeAllActions()
        removeAllChildren()
        
        if let image = UIImage(named: images[currentImage]){
            let rgba = RGBA(image)
            
            
            for x in 0..<rgba.width {
                var temp:[UIColor] = []
                var temp2:[Bool] = []
                for y in 0..<rgba.height {
                    let index = y * rgba.width + x
                    let pixel = rgba.pixels[index]
                    temp.append(UIColor(red: CGFloat(pixel.red)/CGFloat(255), green: CGFloat(pixel.green)/CGFloat(255), blue: CGFloat(pixel.blue)/CGFloat(255), alpha: 1))
                    temp2.append( (pixel.alpha >= threshold) )
                }
                colors.append(temp)
                imageMatrix.append( temp2)
            }
            
            setup()
        }
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
            
        if (sender.direction == .left) {
            currentImage -= 1
            if currentImage < 0{
                currentImage = images.count-1
            }
            restart()
        }
            
        if (sender.direction == .right) {
            currentImage += 1
            if currentImage >= images.count{
                currentImage = 0
            }
            restart()
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        setup()
    }
    
    func setup(){
        grid = Grid(width: imageMatrix.count, height: imageMatrix[0].count, isRandom: false, proportion: 50)
        grid.addRule(CountRule(name: "Solitude", startState: .alive, endState: .dead, count: 2, type: .lessThan))
        grid.addRule(CountRule(name: "Survive2", startState: .alive, endState: .alive, count: 2, type: .equals))
        grid.addRule(CountRule(name: "Survive3", startState: .alive, endState: .alive, count: 3, type: .equals))
        grid.addRule(CountRule(name: "Overpopulation", startState: .alive, endState: .dead, count: 3, type: .greaterThan))
        grid.addRule(CountRule(name: "Birth", startState: .dead, endState: .alive, count: 3, type: .equals))
        
        for i in 0..<imageMatrix.count{
            for j in 0..<imageMatrix[0].count{
                if imageMatrix[i][j] {
                    grid.cells[i][imageMatrix[0].count - j - 1].state = ( Int.random(in: 0...100) < 50 ) ? .alive : .dead
                }
            }
        }
        
        showGen()
        isPlaying = true
    }
    
    func showGen(){
        
        let size:CGFloat = (min(self.frame.width, self.frame.height) -  border) / CGFloat(max(grid.width,grid.height))
        let posX:CGFloat = (self.frame.width  - (CGFloat(grid.width) * size))/2
        let posY:CGFloat = (self.frame.height - (CGFloat(grid.height) * size))/2
        for i in 0..<grid.width {
            for j in 0..<grid.height {
                if imageMatrix[i][imageMatrix[i].count - j - 1] && grid.cells[i][j].state == .alive {
                    let pos = CGPoint(x: posX + CGFloat(i) * size * 1.05, y: posY + CGFloat(j) * size * 1.05)
                    showEntity(pos, size, colors[i][imageMatrix[i].count - j - 1])
                }
            }
        }
    }
    
    func showEntity(_ pos: CGPoint, _ size: CGFloat, _ color:UIColor = .white){
        let node:SKShapeNode = SKShapeNode(circleOfRadius: size/2)
        node.fillColor = color.withAlphaComponent(CGFloat.random(in: 0.3...1))
        node.lineWidth = 0
        node.position = CGPoint(x: pos.x + size, y: pos.y + size)
        node.alpha = 0
        addChild(node)
        
        let d = Double.random(in: duration...4*duration)
        node.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: d*0.1),
            SKAction.group([
                SKAction.fadeAlpha(to: 0, duration: d),
                SKAction.scale(to: CGFloat.random(in: 2...4), duration: d),
                SKAction.move(by: CGVector(dx: CGFloat.random(in: -10...10), dy: CGFloat.random(in: -10...10)), duration: d)
            ]),
            SKAction.removeFromParent()
        ]))
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if isPlaying && currentTime > renderTime {
            grid.applyRules()
            showGen()
            renderTime = currentTime + duration
        }
    }
}
