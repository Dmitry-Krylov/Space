//
//  MainMenu.swift
//  Space
//
//  Created by Елена Крылова on 03.05.2022.
//

import SpriteKit

class MainMenu: SKScene {

    var starfield: SKEmitterNode!
    
    var newGameButtonNode: SKSpriteNode!
    var levelButtonNode: SKSpriteNode!
    var labelLevelButtonNode: SKLabelNode!
    //добавили все переменные
    
    override func didMove(to view: SKView) {
        
        starfield = self.childNode(withName: "starfield_anim") as! SKEmitterNode
        starfield.advanceSimulationTime(20)
        //добавляем анимацию, преобразуем элемент с экрана SKEmitterNode  и отсрочкой в 20 секунд
        
    
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
        //Присваиваем значение для newGameButtonNode, и работает через SKSpriteNode
        newGameButtonNode.texture = SKTexture(imageNamed: "newgame")
        //добавляем изображение кнопки
    
        levelButtonNode = (self.childNode(withName: "levelButton") as! SKSpriteNode)
        //Присваиваем значение для levelButtonNode, и работает через SKSpriteNode
        levelButtonNode.texture = SKTexture(imageNamed: "level")
        //добавляем изображение кнопки
        
        labelLevelButtonNode = self.childNode(withName: "labelLevelButton") as! SKLabelNode
        //Присваиваем значение для labelLevelButtonNode, и работает через SKLabelNode
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameButton" {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: UIScreen.main.bounds.self.size)
                self.view?.presentScene(gameScene, transition: transition)
            }
        }
    }
    
}
