//
//  ViewController2.swift
//  LineTheNumber
//
//  Created by David on 16/1/21.
//  Copyright (c) 2016年 David. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController2: UIViewController {
    lazy var documentsPath: String = {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths.first! 
        }()

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //Outlets
    @IBOutlet var countdownView: UIProgressView!
    @IBOutlet var hintLabel: UILabel!
    @IBOutlet var scoreBoard: UILabel!
    @IBOutlet var restartButton: UIButton!
    @IBOutlet var pauseView: UIView!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var yelloAdjustButton: UIView!
    @IBOutlet var blueAdjustButton: UIView!
    @IBOutlet var resumeButton: UIButton!
    @IBOutlet var musicControl: UIButton!
    
    var BGM:AVAudioPlayer!
    var btnSFX:AVAudioPlayer!
    var pauseSFX:AVAudioPlayer!
    
    var numOfX = 0
    var numOfY = 0
    
    var wall:[[UIButton!]] = []
    
    //游戏参数
    var gaming = false
    var level = 0
    var score = 0
    var indexAry:[Int] = []
    var numAry:[Int] = []
    var indexAryAdd = 0
    var numAryAdd = 0
    var numOfCorrect = 0
    var numOfError = 0
    var soundOn = true
    
    //维护参数
    var mntn = false
    var mntnS = 0
    var mntnI = 0
    
    var showTutor = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numOfX = 9
        numOfY = 9
        
        var marginX:CGFloat = 1
        var marginY:CGFloat = 1
        
        var blankBoard:CGFloat = 100.0
        
        var width = (view.bounds.width-marginX)/CGFloat(numOfX)-marginX
        var height = (view.bounds.width-marginX)/CGFloat(numOfY)-marginY
        for i in 0..<numOfY{
            wall.append([])
            for j in 0..<numOfX{
                var brick = UIButton(frame: CGRectMake(marginX*CGFloat(j+1)+width*CGFloat(j), blankBoard+marginY*CGFloat(i)+height*CGFloat(i), width, height))
                wall[i].append(brick)
                wall[i][j].backgroundColor = UIColor(red: 176.0/255.0, green: 208.0/255.0, blue: 1, alpha: 1)
                wall[i][j].alpha = 0
                wall[i][j].enabled = false
                wall[i][j].setTitleColor(UIColor.whiteColor(), forState: UIControlState.Disabled)
                wall[i][j].titleLabel?.font = UIFont(name: "Menlo", size: width/2.5)
                wall[i][j].addTarget(self, action: #selector(ViewController2.btnClick(_:)), forControlEvents: UIControlEvents.TouchDown)
                wall[i][j].tag = i*10+j
                view.addSubview(wall[i][j])
            }
        }
        
        hintLabel.text = "准备"
        scoreBoard.text = ""
        NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: #selector(ViewController2.gameCounter(_:)), userInfo: nil, repeats: true)
        countdownView.alpha = 0
        restartButton.alpha = 0
        restartButton.layer.zPosition = 199
        pauseView.alpha = 0
        //pauseView.layer.zPosition = 200
        view.bringSubviewToFront(pauseView)
        pauseButton.alpha = 0
        blueAdjustButton.alpha = 0
        yelloAdjustButton.alpha = 0
        
        //显示教程
        let setting = "\(documentsPath)/setting.plist"
        var sd:NSDictionary = NSDictionary(contentsOfFile: setting)!
        if sd.objectForKey("showTutor") as! Bool{
            showTutor = true
        }
        
        
        //音效
        btnSFX = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("btnClick", ofType: "wav")!), fileTypeHint: nil)
        pauseSFX = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("menuSelect", ofType: "wav")!), fileTypeHint: nil)
        if !(sd.objectForKey("BGM") as! Bool){
            btnSFX.volume = 0
            pauseSFX.volume = 0
            BGM.volume = 0
            soundOn = false
        }
        
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for i in 0..<numOfY{
            for j in i..<numOfX{
                
                UIView.animateWithDuration(0.05, delay: NSTimeInterval(Double(i)*0.1), options: [], animations: {
                        self.wall[i][j].alpha = 1
                        self.wall[j][i].alpha = 1
                    
                    }, completion: nil)
                UIView.animateWithDuration(0.05, delay: NSTimeInterval(0.5 + Double(i)*0.1), options: [], animations: {
                        self.wall[i][j].backgroundColor = UIColor.blackColor()
                        self.wall[j][i].backgroundColor = UIColor.blackColor()
                    }, completion: nil)
            }
        }
        
    }
    
    //times
    var appearTime = 2000
    var disappearTime = -1
    var levelTime = -1
    var pauseBreaking = -1
    
    //计时器
    func gameCounter(sender:NSTimer){
        appearTime--
        disappearTime--
        levelTime--
        pauseBreaking--
        
        if appearTime == 0{
            appear()
        }
        if disappearTime == 0{
            disappear()
        }
        if gaming{
            countdownView.progress += 0.0002
        }
        if levelTime > 0 && levelTime <= 2500{
            countdownView.trackTintColor = UIColor(red: 1, green: 80.0/255.0, blue: 70.0/255.0, alpha: 1)
        }
        if levelTime == 0{
            for i in 0..<numOfY{
                for j in i..<numOfX{
                    wall[i][j].enabled = false
                    wall[j][i].enabled = false
                    UIView.animateWithDuration(0.05, delay: NSTimeInterval(Double(i)*0.1), options: [], animations: {
                        self.wall[i][j].backgroundColor = UIColor(red: 1, green: 80.0/255.0, blue: 70.0/255.0, alpha: 1)
                        self.wall[j][i].backgroundColor = UIColor(red: 1, green: 80.0/255.0, blue: 70.0/255.0, alpha: 1)
                        
                        }, completion: nil)
                    
                    
                }
            }
            gaming = false
            
            
            if numOfError == 2{
                hintLabel.text = "机会: 3/3"
                scoreBoard.alpha = 0
                UIView.animateWithDuration(0.5, animations: {
                    self.scoreBoard.textColor = UIColor(red: 176.0/255.0, green: 208.0/255.0, blue: 1, alpha: 1)
                    
                    self.scoreBoard.alpha = 1
                    self.restartButton.alpha = 0.8
                    self.pauseButton.alpha = 0
                })
                scoreBoard.text = "得分: \(score)"
                
                
            }else{
                pauseBreaking = 1000
                numOfError++
                scoreBoard.alpha = 0
                UIView.animateWithDuration(0.5, animations: {
                    self.scoreBoard.textColor = UIColor(red: 1, green: 80.0/255.0, blue: 70.0/255.0, alpha: 1)
                    self.scoreBoard.alpha = 1
                    self.pauseButton.alpha = 0
                })
                scoreBoard.text = "机会: \(numOfError)/3"
            }
        }
        if pauseBreaking == 0{
            pauseBreak()
        }
    }
    func appear(){
        indexAry = []
        numAry = []
        indexAryAdd = 0
        numAryAdd = 0
        numOfCorrect = 0
        
        hintLabel.text = "准备"
        if showTutor{
            hintLabel.text = "教程！"
            scoreBoard.text = "瞬时间内要记住数字！"
        }
        if level%5 == 0 && level != 0{
            hintLabel.text = "Level Up!"
        }
        for i in 0..<level/5+3{
            
            var randX = Int(arc4random()%UInt32(numOfX))
            var randY = Int(arc4random()%UInt32(numOfY))
            var indexRand = randX*10+randY
            
            //要创建不重复的数组，要整个数组遍历比较
            //数字出现的位置不能太靠近了
            if indexAryAdd != 0{
                for i in 1...indexAryAdd{
                   while detectRight(indexRand, a: indexAry[i-1]){
                        randX = Int(arc4random()%UInt32(numOfX))
                        randY = Int(arc4random()%UInt32(numOfY))
                        indexRand = randX*10+randY
                    }
                }
                
            }
            indexAryAdd++
            
            var numRand = Int(arc4random()%90)+10
            if numAryAdd != 0{
                for i in 1...numAryAdd{
                    while numRand == numAry[i-1]{
                        numRand = Int(arc4random()%90)+10
                    }
                }
                
            }
            numAryAdd++
            
            indexAry.append(indexRand)
            numAry.append(numRand)
            wall[randX][randY].setTitle("\(numRand)", forState: UIControlState.Disabled)
            
            //维护模式
            if mntn{
                wall[randX][randY].setTitle("\(numRand)", forState: UIControlState.Normal)
                wall[randX][randY].setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            }
            
            
        }
        //数组排一下序
        for i in 0..<indexAry.count-1{
            for j in 0..<indexAry.count-1{
                
                if numAry[j] > numAry[j+1]{
                    var tempi = indexAry[j]
                    indexAry[j] = indexAry[j+1]
                    indexAry[j+1] = tempi
                    var tempn = numAry[j]
                    numAry[j] = numAry[j+1]
                    numAry[j+1] = tempn
                }
                
            }
        }
        disappearTime = 1500+(level/10)*1000
        
    }
    
    func disappear(){
        hintLabel.text = "Line The Number!"
        if showTutor{
            hintLabel.text = "教程！"
            scoreBoard.text = "在黑暗中从小到大找数字！"
        }
        for i in wall{
            for j in i{
                j.enabled = true
                j.setTitleColor(UIColor.blackColor(), forState: UIControlState.Disabled)
            }
        }
        if showTutor{
            UIView.animateWithDuration(0.3, animations: {
                self.wall[self.indexAry[0]/10][self.indexAry[0]%10].backgroundColor = UIColor(red: 176.0/255.0, green: 208.0/255.0, blue: 1, alpha: 1)
            })
            
        }
        levelTime = 5000+(level/10)*1000
        
        
        countdownView.progress = 0

        UIView.animateWithDuration(0.5, animations: {
            self.countdownView.alpha = 1
            self.countdownView.trackTintColor = UIColor(red: 176.0/255.0, green: 208.0/255.0, blue: 1, alpha: 1)
            self.pauseButton.alpha = 1
        })
        gaming = true
        print(indexAry)
        print(numAry)
    }
    func detectRight(i:Int,a:Int) ->Bool{
        /*
            ┏━━━━┳━━━━┳━━━━┓
            ┃i-11┃i-10┃i-9 ┃
            ┣━━━━╋━━━━╋━━━━┫
            ┃i-1 ┃ i  ┃i+1 ┃
            ┣━━━━╋━━━━╋━━━━┫
            ┃i+9 ┃i+10┃i+11┃
            ┗━━━━┻━━━━┻━━━━┛
        */
        
        if a==i{
            return true
        }else{
            switch i{
                //四个角落
            case 0:
                if a-1==i||a-10==i||a-11==i{
                    return true
                }
            case 8:
                if a+1==i||a-10==i||a-9==i{
                    return true
                }
            case 80:
                if a-1==i||a+10==i||a+9==i{
                    return true
                }
            case 88:
                if a+1==i||a+10==i||a+11==i{
                    return true
                }
            default://不是角落
                if (i>=1&&i<=8){
                    //上边缘
                    if a-1==i||a+1==i||a-10==i||a-9==i||a-11==i{
                        return true
                    }
                }else{
                    if(i%10==0&&i/10>=1&&i/10<=8){
                        //左边缘
                        if a-10==i||a+10==i||a-1==i||a+9==i||a-11==i{
                            return true
                        }
                    }else{
                        if(i%10==8&&i/10>=1&&i/10<=8){
                            //右边缘
                            if a-10==i||a+10==i||a+1==i||a-9==i||a+11==i{
                                return true
                            }
                        }else{
                            if(i/10==8&&i%10>=1&&i%10<=8){
                                //下边缘
                                if a-1==i||a+1==i||a+10==i||a+9==i||a+11==i{
                                    return true
                                }
                            }else{
                                //普通的，又不是角落又不是边缘
                                if a-1==i||a+1==i||a+10==i||a-10==i||a+9==i||a-9==i||a+11==i||a-11==i{
                                    return true
                                }
                            }
                        }
                    }
                }
            }//switch结束
        }//检测盲点结束
        return false
        
    }
    @IBAction func btnClick(sender: UIButton) {
        if gaming{
            btnSFX.play()
            var indexClick = sender.tag
            print(indexClick)
            if detectRight(indexAry[numOfCorrect],a:indexClick) {
                wall[indexAry[numOfCorrect]/10][indexAry[numOfCorrect]%10].backgroundColor = UIColor(red: 176.0/255.0, green: 208.0/255.0, blue: 1, alpha: 1)
                wall[indexAry[numOfCorrect]/10][indexAry[numOfCorrect]%10].enabled = false
                numOfCorrect++
                if showTutor{
                    if numOfCorrect < indexAry.count{
                        UIView.animateWithDuration(0.3, animations: {
                            self.wall[self.indexAry[self.numOfCorrect]/10][self.indexAry[self.numOfCorrect]%10].backgroundColor = UIColor(red: 176.0/255.0, green: 208.0/255.0, blue: 1, alpha: 1)
                        })
                    }
                    
                }
                
                hintLabel.text = "\(numOfCorrect)/\(indexAry.count)"
                
                if numOfCorrect == indexAry.count{
                    var i = Int(arc4random()%3)
                    switch(i){
                    case 0:
                        hintLabel.text = "很好! ^_^"
                    case 1:
                        hintLabel.text = "不错!"
                    case 2:
                        hintLabel.text = "厉害!"
                    default:
                        break
                    }
                    
                    if levelTime >= 4000{
                        hintLabel.text = "极速!"
                    }
                    if showTutor{
                        showTutor = false
                        let setting = "\(documentsPath)/setting.plist"
                        var sd:NSMutableDictionary = NSMutableDictionary(contentsOfFile: setting)!
                        sd.setValue(showTutor, forKey: "showTutor")
                        sd.writeToFile(setting, atomically: true)
                        hintLabel.text = "接受挑战吧骚年!"
                    }
                    score++
                    scoreBoard.alpha = 0
                    UIView.animateWithDuration(0.5, animations: {
                        self.scoreBoard.textColor = UIColor(red: 176.0/255.0, green: 208.0/255.0, blue: 1, alpha: 1)
                        self.scoreBoard.alpha = 1
                        self.pauseButton.alpha = 0
                    })
                    scoreBoard.text = "得分: \(score)"
                    for i in 0..<indexAry.count{
                        UIView.animateWithDuration(0.05, delay: NSTimeInterval(0.5 + Double(i)*0.1), options: [], animations: {
                            self.wall[self.indexAry[i]/10][self.indexAry[i]%10].backgroundColor = UIColor.blackColor()
                            
                        }, completion: nil)
                    }

                    
                    for i in wall{
                        for j in i{
                            j.enabled = false
                        }
                    }

                    pauseBreaking = 1000
                    levelTime = -1
                    gaming = false
                }
            }else{
                if mntnS == 4{
                    if mntnI == 0 && indexClick == 0{
                        mntnI++
                    }
                    if mntnI == 1 && indexClick == 88{
                        mntnI++
                    }
                }
                hintLabel.text = "错了!"
                if numOfCorrect == indexAry.count-1{
                    hintLabel.text = "差一点!"
                }
                
                
                for i in 0..<numOfY{
                    for j in 0..<numOfX{
                        wall[i][j].enabled = false
                        wall[j][i].enabled = false
                        UIView.animateWithDuration(0.05, delay: NSTimeInterval(Double(i)*0.1), options: [], animations: {
                            self.wall[i][j].backgroundColor = UIColor(red: 1, green: 80.0/255.0, blue: 70.0/255.0, alpha: 1)
                            self.wall[j][i].backgroundColor = UIColor(red: 1, green: 80.0/255.0, blue: 70.0/255.0, alpha: 1)
                            
                            }, completion: nil)
                    }
                }
                levelTime = -1
                
                gaming = false
                if numOfError == 2{
                    hintLabel.text = "完了: 3/3"
                    scoreBoard.alpha = 0
                    UIView.animateWithDuration(0.5, animations: {
                        self.scoreBoard.textColor = UIColor(red: 176.0/255.0, green: 208.0/255.0, blue: 1, alpha: 1)
                        self.scoreBoard.alpha = 1
                        self.restartButton.alpha = 0.8
                        self.pauseButton.alpha = 0
                    })
                    scoreBoard.text = "得分: \(score)"
                    
                }else{
                    pauseBreaking = 1000
                    numOfError++
                    scoreBoard.alpha = 0
                    UIView.animateWithDuration(0.5, animations: {
                        self.scoreBoard.textColor = UIColor(red: 1, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1)
                        self.scoreBoard.alpha = 1
                        self.pauseButton.alpha = 0
                    })
                    scoreBoard.text = "机会: \(numOfError)/3"
                }

            }
        }
        
    }
    
    func pauseBreak(){
        level++
        hintLabel.text = "准备"
        if level%5 == 0 && level != 0{
            hintLabel.text = "Level Up!"
        }
        UIView.animateWithDuration(1, animations: {
            self.countdownView.alpha = 0
        })
        for i in 0..<numOfY{
            for j in i..<numOfX{
                wall[i][j].enabled = false
                wall[j][i].enabled = false
                
                UIView.animateWithDuration(0.05, delay: NSTimeInterval(0.5 + Double(i)*0.1), options: [], animations: {
                    self.wall[i][j].setTitle("", forState: UIControlState.Disabled)
                    self.wall[i][j].setTitleColor(UIColor.whiteColor(), forState: UIControlState.Disabled)
                    self.wall[j][i].setTitle("", forState: UIControlState.Disabled)
                    self.wall[j][i].setTitleColor(UIColor.whiteColor(), forState: UIControlState.Disabled)
                    
                    self.wall[i][j].backgroundColor = UIColor.blackColor()
                    self.wall[j][i].backgroundColor = UIColor.blackColor()
                    
                    self.wall[i][j].setTitle("", forState: UIControlState.Normal)
                    self.wall[i][j].setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    self.wall[j][i].setTitle("", forState: UIControlState.Normal)
                    self.wall[j][i].setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    
                    
                    
                    }, completion: nil)
                
            }
        }
        
        appearTime = 2000

    }
    
    @IBAction func restart(sender: UIButton) {
        pauseSFX.play()
        if pauseView.alpha == 1{
            pauseView.alpha = 0
            pauseButton.alpha = 0
        }else{
            UIView.animateWithDuration(0.1, delay: 0, options: [], animations: {
                sender.backgroundColor = UIColor.whiteColor()
            }, completion: nil)
            
            UIView.animateWithDuration(0.2, delay: 0.1, options: [], animations: {
                sender.backgroundColor = UIColor(red: 1, green: 120.0/255.0, blue: 120.0/255.0, alpha: 0.8)
                sender.alpha = 0
            }, completion: nil)
        }
        
        scoreBoard.text = ""
        level = -1
        numOfError = 0
        score = 0
        if mntn{
            mntn = false
        }
        if mntnI == 2{
            mntn = true
            mntnI = 0
            mntnS = 0
        }
        pauseBreak()
    }
    
    var tempLevelTime = -1
    @IBAction func gamePause(sender: AnyObject) {
        pauseSFX.play()
        if gaming{
            NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ViewController2.pauseAnimate(_:)), userInfo: nil, repeats: true)
            gaming = false
            tempLevelTime = levelTime
            levelTime = -1
            pauseView.alpha = 1
            hintLabel.text = "暂停"

            if mntn{
                mntn = false
            }
            mntnS++
        }else{
            gaming = true
            levelTime = tempLevelTime
            pauseView.alpha = 0
            hintLabel.text = "继续"
            
        }
    }
    func pauseAnimate(sender:NSTimer){
        
        if gaming{
            sender.invalidate()
        }else{
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: {
                self.yelloAdjustButton.alpha = 0.3
                self.blueAdjustButton.alpha = 0.3
                self.yelloAdjustButton.center.x -= 10
                self.blueAdjustButton.center.x += 10
                self.resumeButton.center.x -= 5
                }, completion: nil)
            UIView.animateWithDuration(0.1, delay: 0.1, options: .AllowUserInteraction, animations: {
                self.yelloAdjustButton.alpha = 0
                self.blueAdjustButton.alpha = 0
                self.yelloAdjustButton.center.x += 10
                self.blueAdjustButton.center.x -= 10
                self.resumeButton.center.x += 10

                }, completion: nil)
            UIView.animateWithDuration(0.1, delay: 0.2, options: .AllowUserInteraction, animations: {
                self.resumeButton.center.x -= 5

            }, completion: nil)
        }
        
    }
    @IBAction func resumeClick(sender: UIButton) {
        pauseSFX.play()
        gaming = true
        UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: {
            self.yelloAdjustButton.alpha = 0.3
            self.blueAdjustButton.alpha = 0.3
            self.yelloAdjustButton.center.x -= 10
            self.blueAdjustButton.center.x += 10
            self.resumeButton.center.x -= 5

            }, completion: nil)
        UIView.animateWithDuration(0.1, delay: 0.1, options: .AllowUserInteraction, animations: {
            self.yelloAdjustButton.alpha = 0
            self.blueAdjustButton.alpha = 0
            self.yelloAdjustButton.center.x += 10
            self.blueAdjustButton.center.x -= 10
            self.resumeButton.center.x += 10

            }, completion: nil)
        UIView.animateWithDuration(0.1, delay: 0.2, options: .AllowUserInteraction, animations: {
            self.resumeButton.center.x -= 5
            self.pauseView.alpha = 0
            }, completion: nil)
        levelTime = tempLevelTime
        
        hintLabel.text = "继续"
    }
    @IBAction func musicBtnClick(sender: UIButton) {
        if soundOn{
            sender.setTitle("Music Off", forState: UIControlState.Normal)
            BGM.volume = 0
            pauseSFX.volume = 0
            btnSFX.volume = 0
            soundOn = false
        }else{
            sender.setTitle("Music On", forState: UIControlState.Normal)
            BGM.volume = 0.4
            pauseSFX.volume = 1
            pauseSFX.play()
            btnSFX.volume = 1
            soundOn = true
        }
        let setting = "\(documentsPath)/setting.plist"
        var sd:NSMutableDictionary = NSMutableDictionary(contentsOfFile: setting)!
        sd.setValue(soundOn, forKey: "BGM")
        sd.writeToFile(setting, atomically: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
