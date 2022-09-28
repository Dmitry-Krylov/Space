//
//  GameScene.swift
//  Space
//
//  Created by Елена Крылова on 24.04.2022.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield:SKEmitterNode! //анимация обложка
    var player:SKSpriteNode!    //игрок
    var scoreLabel:SKLabelNode! //надпись на экране
    var score:Int = 0 { //чтоб обновлялась переменная прописываем
        didSet { //
            scoreLabel.text = "Счет: \(score)"
        }
    }
    var gameTimer:Timer!
    var aliens = ["alien", "alien1", "alien2"]
    
    let alienCategory:UInt32 = 0x1 << 1
    //создаем переменную с уникальными зеначениями
    let bulletCategory:UInt32 = 0x1 << 0
    //создаем переменную с уникальными зеначениями
    
    let motionManager = CMMotionManager()
    //постоянная акселерометра менеджера
    var xAccelerate:CGFloat = 0
    //переменная для акселерометра по Х
    
    override func didMove(to view: SKView) {
        starfield = SKEmitterNode(fileNamed: "Starfield")
        //присваиваем значение анимации при помощи класса SKEmitterNode
        starfield.position = CGPoint(x: 0, y: 900)
        //указываем позицию через класс CGPoint
        starfield.advanceSimulationTime(120)
        //отсрочка анимации на 10 секунд
        
        self .addChild(starfield)
        //добавляем объект на экран
        
        starfield.zPosition = -1
        //установим Z позицию что всегда была позади
        
        player = SKSpriteNode(imageNamed: "Lev")
        player.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: 150)
        player.setScale(0.5)
        
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        //прописываем гравитацию она равна нулю
        self.physicsWorld.contactDelegate = self
        //помогает отслеживать соприкосновения в нашей игре. надо унаследовать у класса SKScene и SKPhysicsContactDelegate
        
        scoreLabel = SKLabelNode(text: "Счет: 0")
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: 100, y: UIScreen.main.bounds.height - 70)
        score = 0
        
        self.addChild(scoreLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        // типовой код для работы с акселерометром, где можно регулировать скорость перемещения
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometrData = data {
                let acceleration = accelerometrData.acceleration
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25
            }
        }
    }
    //скорость игрока
    override func didSimulatePhysics() {
        player.position.x += xAccelerate * 50
        
        //ограничиваем игрока по рамкам
        if player.position.x < 0 {
            player.position = CGPoint(x : UIScreen.main.bounds.width - player.size.width, y : player.position.y)
        } else if player.position.x > UIScreen.main.bounds.width {
            player.position = CGPoint(x : 20, y : player.position.y)
        }
    }
    //Создаем функцию прикосновений didBegin когда наши объекты сталкиваются (патрон и враг)
    func didBegin(_ contact: SKPhysicsContact) {
        var alienBody: SKPhysicsBody
        var bulletBody: SKPhysicsBody
        
        //Далее проводим проверку через переменную contact
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bulletBody = contact.bodyA
            alienBody = contact.bodyB
        } else {
            bulletBody = contact.bodyB
            alienBody = contact.bodyA
        }
        
        if (alienBody.categoryBitMask & alienCategory) != 0 && (bulletBody.categoryBitMask & bulletCategory) != 0 {
            collisionElements(bulletNode: bulletBody.node as! SKSpriteNode, alienNode: alienBody.node as! SKSpriteNode)
        }
    }
    //Дополнительная функция будет принимать патрон а объект и проигрываем анимацию
    func collisionElements(bulletNode: SKSpriteNode, alienNode: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Vzriv")
        //добавляем фаил анимации
        explosion?.position = alienNode.position
        //добавляем позиции анимации
        self.addChild(explosion!)
        //добавляем саму анимацию
        
        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        //добавляем музыку для анимации
        
        bulletNode.removeFromParent()
        alienNode.removeFromParent()
        //далее удаляем для объекта патрок и объект
        
        self.run(SKAction.wait(forDuration: 2)) {
        //Удаляем анимацию позже
            explosion?.removeFromParent()
        }
        
        score += 5
    }
    
    @objc func addAlien() {
            aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]
        //берем случайный элеменет элиан-элиан1-элиан2
        
            let alien = SKSpriteNode(imageNamed: aliens[0])
        //создаем сам объект на экране
        let randomPos = GKRandomDistribution(lowestValue: 20, highestValue: Int(UIScreen.main.bounds.size.width - 10))
        //случайная позиция для объектов, диапазон случайных чисел на экране
            let pos = CGFloat(randomPos.nextInt())
        //целое число конвентируем в CGFloat для того чтоб задать позицию alien
        
        alien.position = CGPoint(x: pos, y: UIScreen.main.bounds.size.height + alien.size.height)
        //устанавливаем позицию
            alien.setScale(2)
        //Увеличить картинка в 2 раза
            alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        //прикрепляем физику объекту alien размер врага
            alien.physicsBody?.isDynamic = true
        //обект динамический
            
            alien.physicsBody?.categoryBitMask = alienCategory
            alien.physicsBody?.contactTestBitMask = bulletCategory
            alien.physicsBody?.collisionBitMask = 0
        //отслеживать саприкосновение объекто при помощи масок
            alien.setScale(0.5)
        //Размер объектов врагов
        
            self.addChild(alien)
        
            let animDuration:TimeInterval = 6
        //скорость анимации
            
            var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: pos, y: 0 - alien.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        //Удаляем после выхода за пределы
        alien.run(SKAction.sequence(actions))
        //для того чтоб проигрывать анимацию нужен дополнительны массив, записывают действия
        }
        
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }// при нажатии на экран буднет запускаться вункция выстрела
    
    func fireBullet () {
        self.run(SKAction.playSoundFileNamed("bullet.mp3", waitForCompletion: false))
        //подгружаем звук выстрела из мп3
        let bullet = SKSpriteNode(imageNamed: "torpedo")
        bullet.position = player.position
        //позиция выстрела равна позиции игрока
        bullet.position.y += 50
        //позиция эфекта на 5 пикселей выше
        bullet.position.x -= 5
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        //прикрепляем физику объекту alien размер врага
        bullet.physicsBody?.isDynamic = true
        //обект динамический
        bullet.setScale(2)
        //Уменьшить размер картинки
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = alienCategory
        bullet.physicsBody?.collisionBitMask = 0
        //отслеживать саприкосновение объекто при помощи масок
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        //саприкосновение с объектом
        
            self.addChild(bullet)
        
        let animDuration:TimeInterval = 0.2
        //скорость анимации
            
            var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: UIScreen.main.bounds.size.height + bullet.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        bullet.run(SKAction.sequence(actions))
        //для того чтоб проигрывать анимацию нужен дополнительны массив, записывают действия
    }
    }
    

    

func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }



