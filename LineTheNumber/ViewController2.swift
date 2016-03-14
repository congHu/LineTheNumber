//
//  ViewController2.swift
//  LineTheNumber
//
//  Created by David on 16/1/21.
//  Copyright (c) 2016年 David. All rights reserved.
//

import UIKit
class ViewController2: UIViewController {

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
    @IBOutlet var htpLabel: UILabel!
    @IBOutlet var htpYAJ: UILabel!
    @IBOutlet var htpBAJ: UILabel!
    
    
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
    
    //维护参数
    var mntn = false
    var mntnS = 0
    var mntnI = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0..<49{
            var btn = view.viewWithTag(i+100) as! UIButton
            btn.alpha = 0
            btn.enabled = false
            btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Disabled)
            
        }
        hintLabel.text = "Ready"
        scoreBoard.text = ""
        NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: "gameCounter:", userInfo: nil, repeats: true)
        countdownView.alpha = 0
        restartButton.alpha = 0
        pauseView.alpha = 0
        pauseButton.alpha = 0
        blueAdjustButton.alpha = 0
        yelloAdjustButton.alpha = 0
        htpBAJ.alpha = 0
        htpYAJ.alpha = 0
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for i in 0..<7{
            for j in i..<7{
                var btn = view.viewWithTag(100+j+i*7) as! UIButton
                var btnv = view.viewWithTag(100+j*7+i) as! UIButton
                UIView.animateWithDuration(0.05, delay: NSTimeInterval(Double(i)*0.1), options: nil, animations: {
                        btn.alpha = 1
                        btnv.alpha = 1
                    }, completion: nil)
                UIView.animateWithDuration(0.05, delay: NSTimeInterval(0.5 + Double(i)*0.1), options: nil, animations: {
                        btn.backgroundColor = UIColor.blackColor()
                        btnv.backgroundColor = UIColor.blackColor()
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
            for i in 0..<7{
                for j in i..<7{
                    var btn = view.viewWithTag(100+j+i*7) as! UIButton
                    var btnv = view.viewWithTag(100+j*7+i) as! UIButton
                    btn.enabled = false
                    btnv.enabled = false
                    UIView.animateWithDuration(0.05, delay: NSTimeInterval(Double(i)*0.1), options: nil, animations: {
                        btn.backgroundColor = UIColor(red: 1, green: 80.0/255.0, blue: 70.0/255.0, alpha: 1)
                        btnv.backgroundColor = UIColor(red: 1, green: 80.0/255.0, blue: 70.0/255.0, alpha: 1)
                        
                        }, completion: nil)
                    
                    
                }
            }
            gaming = false
            
            
            if numOfError == 2{
                hintLabel.text = "Failed: 3/3"
                scoreBoard.alpha = 0
                UIView.animateWithDuration(0.5, animations: {
                    self.scoreBoard.textColor = UIColor(red: 176.0/255.0, green: 208.0/255.0, blue: 1, alpha: 1)
                    
                    self.scoreBoard.alpha = 1
                    self.restartButton.alpha = 0.8
                    self.pauseButton.alpha = 0
                })
                scoreBoard.text = "Score: \(score)"
                
                
            }else{
                pauseBreaking = 1000
                numOfError++
                scoreBoard.alpha = 0
                UIView.animateWithDuration(0.5, animations: {
                    self.scoreBoard.textColor = UIColor(red: 1, green: 80.0/255.0, blue: 70.0/255.0, alpha: 1)
                    self.scoreBoard.alpha = 1
                    self.pauseButton.alpha = 0
                })
                scoreBoard.text = "Failed: \(numOfError)/3"
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
        
        hintLabel.text = "Ready"
        if level%5 == 0 && level != 0{
            hintLabel.text = "Level Up!"
        }
        for i in 0..<level/5+3{
            var indexRand = Int(arc4random()%49)
            
            //要创建不重复的数组，要整个数组遍历比较
            //数字出现的位置不能太靠近了
            if indexAryAdd != 0{
                for i in 1...indexAryAdd{
                   while detectRight(indexRand, a: indexAry[i-1]){
                        indexRand = Int(arc4random()%49)
                    }
                }
                
            }
            indexAryAdd++
            
            var numRand = Int(arc4random()%100)
            if numAryAdd != 0{
                for i in 1...numAryAdd{
                    while numRand == numAry[i-1]{
                        numRand = Int(arc4random()%49)
                    }
                }
                
            }
            numAryAdd++
            
            indexAry.append(indexRand)
            numAry.append(numRand)
            var btn = view.viewWithTag(indexRand+100) as! UIButton
            btn.setTitle("\(numRand)", forState: UIControlState.Disabled)
            
            //维护模式
            if mntn{
                btn.setTitle("\(numRand)", forState: UIControlState.Normal)
                btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
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
        for i in 100...148{
            var clear = self.view.viewWithTag(i) as! UIButton
            clear.enabled = true
            clear.setTitleColor(UIColor.blackColor(), forState: UIControlState.Disabled)
            
        }
        
        levelTime = 5000+(level/10)*1000
        
        
        countdownView.progress = 0

        UIView.animateWithDuration(0.5, animations: {
            self.countdownView.alpha = 1
            self.countdownView.trackTintColor = UIColor(red: 176.0/255.0, green: 208.0/255.0, blue: 1, alpha: 1)
            self.pauseButton.alpha = 1
        })
        gaming = true
        
    }
    func detectRight(i:Int,a:Int) ->Bool{
        /*
            ┏━━━┳━━━┳━━━┓
            ┃i-8┃i-7┃i-6┃
            ┣━━━╋━━━╋━━━┫
            ┃i-1┃ i ┃i+1┃
            ┣━━━╋━━━╋━━━┫
            ┃i+6┃i+7┃i+8┃
            ┗━━━┻━━━┻━━━┛
        */
        
        if a==i{
            return true
        }else{
            switch i{
                //四个角落
            case 0:
                if a-1==i||a-7==i||a-8==i{
                    return true
                }else{
                    return false
                }
            case 6:
                if a+1==i||a-7==i||a-6==i{
                    return true
                }else{
                    return false
                }
            case 42:
                if a-1==i||a+7==i||a+6==i{
                    return true
                }else{
                    return false
                }
            case 48:
                if a+1==i||a+7==i||a+8==i{
                    return true
                }else{
                    return false
                }
            default://不是角落
                if (i>=1&&i<=5){
                    //上边缘
                    if a-1==i||a+1==i||a-7==i||a-6==i||a-8==i{
                        return true
                    }else{
                        return false
                    }
                }else{
                    if(i%7==0&&i/7>=1&&i/7<=5){
                        //左边缘
                        if a-7==i||a+7==i||a-1==i||a+6==i||a-8==i{
                            return true
                        }else{
                            return false
                        }
                    }else{
                        if((i-6)%7==0&&(i-6)/7>=1&&(i-6)/7<=5){
                            //右边缘
                            if a-7==i||a+7==i||a+1==i||a-6==i||a+8==i{
                                return true
                            }else{
                                return false
                            }
                        }else{
                            if((i-42)>=1&&(i-42)<=5){
                                //下边缘
                                if a-1==i||a+1==i||a+7==i||a+6==i||a+8==i{
                                    return true
                                }else{
                                    return false
                                }
                            }else{
                                //普通的，又不是角落又不是边缘
                                if a-1==i||a+1==i||a+7==i||a-7==i||a+6==i||a-6==i||a+8==i||a-8==i{
                                    return true
                                }else{
                                    return false
                                }
                            }
                        }
                    }
                }
                
            }//switch结束
        }//检测盲点结束
        
        
    }
    @IBAction func btnClick(sender: UIButton) {
        if gaming{
            var indexClick = sender.tag - 100
            if detectRight(indexAry[numOfCorrect],a:indexClick) {
                var btn = self.view.viewWithTag(indexAry[numOfCorrect]+100) as! UIButton
                btn.backgroundColor = UIColor(red: 176.0/255.0, green: 208.0/255.0, blue: 1, alpha: 1)
                btn.enabled = false
                numOfCorrect++
                hintLabel.text = "\(numOfCorrect)/\(indexAry.count)"
                
                if numOfCorrect == indexAry.count{
                    score++
                    hintLabel.text = "Great! ^_^"
                    scoreBoard.alpha = 0
                    UIView.animateWithDuration(0.5, animations: {
                        self.scoreBoard.textColor = UIColor(red: 176.0/255.0, green: 208.0/255.0, blue: 1, alpha: 1)
                        self.scoreBoard.alpha = 1
                        self.pauseButton.alpha = 0
                    })
                    scoreBoard.text = "Score: \(score)"
                    for i in 0..<indexAry.count{
                        var btn = self.view.viewWithTag(100+indexAry[i]) as! UIButton
                        
                        UIView.animateWithDuration(0.05, delay: NSTimeInterval(0.5 + Double(i)*0.1), options: nil, animations: {
                            btn.backgroundColor = UIColor.blackColor()
                            
                        }, completion: nil)
                    }

                    for i in 0..<7{
                        for j in i..<7{
                            var btn = view.viewWithTag(100+j+i*7) as! UIButton
                            var btnv = view.viewWithTag(100+j*7+i) as! UIButton
                            btn.enabled = false
                            btnv.enabled = false
                            
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
                    if mntnI == 1 && indexClick == 48{
                        mntnI++
                    }
                }
                hintLabel.text = "Lose :("
                if numOfCorrect == indexAry.count-1{
                    hintLabel.text = "Almost!"
                }
                
                
                for i in 0..<7{
                    for j in i..<7{
                        var btn = view.viewWithTag(100+j+i*7) as! UIButton
                        var btnv = view.viewWithTag(100+j*7+i) as! UIButton
                        btn.enabled = false
                        btnv.enabled = false
                        UIView.animateWithDuration(0.05, delay: NSTimeInterval(Double(i)*0.1), options: nil, animations: {
                            btn.backgroundColor = UIColor(red: 1, green: 80.0/255.0, blue: 70.0/255.0, alpha: 1)
                            btnv.backgroundColor = UIColor(red: 1, green: 80.0/255.0, blue: 70.0/255.0, alpha: 1)
                            
                            }, completion: nil)
                        
                    }
                }
                levelTime = -1
                
                gaming = false
                if numOfError == 2{
                    hintLabel.text = "Failed: 3/3"
                    scoreBoard.alpha = 0
                    UIView.animateWithDuration(0.5, animations: {
                        self.scoreBoard.textColor = UIColor(red: 176.0/255.0, green: 208.0/255.0, blue: 1, alpha: 1)
                        self.scoreBoard.alpha = 1
                        self.restartButton.alpha = 0.8
                        self.pauseButton.alpha = 0
                    })
                    scoreBoard.text = "Score: \(score)"
                    
                }else{
                    pauseBreaking = 1000
                    numOfError++
                    scoreBoard.alpha = 0
                    UIView.animateWithDuration(0.5, animations: {
                        self.scoreBoard.textColor = UIColor(red: 1, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1)
                        self.scoreBoard.alpha = 1
                        self.pauseButton.alpha = 0
                    })
                    scoreBoard.text = "Failed: \(numOfError)/3"
                }

            }
        }
        
    }
    
    func pauseBreak(){
        level++
        hintLabel.text = "Ready"
        if level%5 == 0 && level != 0{
            hintLabel.text = "Level Up!"
        }
        
        for i in 0..<7{
            for j in i..<7{
                var btn = view.viewWithTag(100+j+i*7) as! UIButton
                var btnv = view.viewWithTag(100+j*7+i) as! UIButton
                btn.enabled = false
                btnv.enabled = false
                UIView.animateWithDuration(1, animations: {
                    self.countdownView.alpha = 0
                })
                UIView.animateWithDuration(0.05, delay: NSTimeInterval(0.5 + Double(i)*0.1), options: nil, animations: {
                    btn.setTitle("", forState: UIControlState.Disabled)
                    btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Disabled)
                    btnv.setTitle("", forState: UIControlState.Disabled)
                    btnv.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Disabled)
                    btn.backgroundColor = UIColor.blackColor()
                    btnv.backgroundColor = UIColor.blackColor()
                    btn.setTitle("", forState: UIControlState.Normal)
                    btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    btnv.setTitle("", forState: UIControlState.Normal)
                    btnv.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    
                    
                    
                    }, completion: nil)
                
            }
        }
        appearTime = 2000

    }
    
    @IBAction func restart(sender: UIButton) {
        if pauseView.alpha == 1{
            pauseView.alpha = 0
            pauseButton.alpha = 0
        }else{
            UIView.animateWithDuration(0.1, delay: 0, options: nil, animations: {
                sender.backgroundColor = UIColor.whiteColor()
            }, completion: nil)
            
            UIView.animateWithDuration(0.2, delay: 0.1, options: nil, animations: {
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
        if gaming{
            NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "pauseAnimate:", userInfo: nil, repeats: true)
            gaming = false
            tempLevelTime = levelTime
            levelTime = -1
            pauseView.alpha = 1
            hintLabel.text = "Now Pause"
            htpLabel.text = "How To Play?\nFind \(numAry)"
            htpBAJ.text = "How To Play?\nFind \(numAry)"
            htpYAJ.text = "How To Play?\nFind \(numAry)"
            if mntn{
                mntn = false
            }
            mntnS++
        }else{
            gaming = true
            levelTime = tempLevelTime
            pauseView.alpha = 0
            hintLabel.text = "Now go on"
            
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
                self.htpYAJ.alpha = 1
                self.htpYAJ.alpha = 1
                self.htpLabel.center.x -= 5
                }, completion: nil)
            UIView.animateWithDuration(0.1, delay: 0.1, options: .AllowUserInteraction, animations: {
                self.yelloAdjustButton.alpha = 0
                self.blueAdjustButton.alpha = 0
                self.yelloAdjustButton.center.x += 10
                self.blueAdjustButton.center.x -= 10
                self.resumeButton.center.x += 10
                self.htpYAJ.alpha = 0
                self.htpYAJ.alpha = 0
                self.htpLabel.center.x += 10
                }, completion: nil)
            UIView.animateWithDuration(0.1, delay: 0.2, options: .AllowUserInteraction, animations: {
                self.resumeButton.center.x -= 5
                self.htpLabel.center.x -= 5
            }, completion: nil)
        }
        
    }
    @IBAction func resumeClick(sender: UIButton) {
        gaming = true
        UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: {
            self.yelloAdjustButton.alpha = 0.3
            self.blueAdjustButton.alpha = 0.3
            self.yelloAdjustButton.center.x -= 10
            self.blueAdjustButton.center.x += 10
            self.resumeButton.center.x -= 5
            self.htpYAJ.alpha = 1
            self.htpYAJ.alpha = 1
            self.htpLabel.center.x -= 5
            }, completion: nil)
        UIView.animateWithDuration(0.1, delay: 0.1, options: .AllowUserInteraction, animations: {
            self.yelloAdjustButton.alpha = 0
            self.blueAdjustButton.alpha = 0
            self.yelloAdjustButton.center.x += 10
            self.blueAdjustButton.center.x -= 10
            self.resumeButton.center.x += 10
            self.htpYAJ.alpha = 0
            self.htpYAJ.alpha = 0
            self.htpLabel.center.x += 10
            }, completion: nil)
        UIView.animateWithDuration(0.1, delay: 0.2, options: .AllowUserInteraction, animations: {
            self.resumeButton.center.x -= 5
            self.htpLabel.center.x -= 5
            self.pauseView.alpha = 0
            }, completion: nil)
        levelTime = tempLevelTime
        
        hintLabel.text = "Now go on"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
