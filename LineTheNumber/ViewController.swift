//
//  ViewController.swift
//  LineTheNumber
//
//  Created by David on 16/1/21.
//  Copyright (c) 2016年 David. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {

    lazy var documentsPath: String = {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths.first! as! String
        }()
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //Outlets
    @IBOutlet var gameMainTitle: UILabel!
    @IBOutlet var hintLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var blueAdjustTitle: UILabel!
    @IBOutlet var yellowAdjustTitle: UILabel!
    @IBOutlet var showTutorSwitch: UISwitch!
    @IBOutlet var BGMSwitcher: UISwitch!
    
    var audioPlayer:AVAudioPlayer!
    var playSFX:AVAudioPlayer!
    
    //全局参数
    var gaming = false
    var countdownTime = -1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "animateTitle:", userInfo: nil, repeats: true)
        
        let setting = "\(documentsPath)/setting.plist"
        println(setting)
        if !NSFileManager.defaultManager().fileExistsAtPath(setting){
            var sd = NSMutableDictionary()
            sd.setValue(true, forKey: "showTutor")
            sd.setValue(true, forKey: "BGM")
            sd.writeToFile(setting, atomically: true)
        }else{
            var sd = NSDictionary(contentsOfFile: setting)!
            showTutorSwitch.on = sd.objectForKey("showTutor") as! Bool
            BGMSwitcher.on = sd.objectForKey("BGM") as! Bool
        }
        showTutorSwitch.layer.cornerRadius = 19
        BGMSwitcher.layer.cornerRadius = 19
        
        //音乐
        audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("BGM", ofType: "mp3")!), error: nil)
        playSFX = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("menuSelect", ofType: "wav")!), error: nil)
        
        audioPlayer.numberOfLoops = -1
        if(BGMSwitcher.on){
            audioPlayer.volume = 0.4
        }else{
            audioPlayer.volume = 0
            playSFX.volume = 0
        }
        
        audioPlayer.play()
        
    }
    
    func animateTitle(sender:NSTimer){
        
        if !gaming{
            self.gameMainTitle.center.x += 5
            self.blueAdjustTitle.alpha = 0.6
            self.yellowAdjustTitle.alpha = 0.6
            self.hintLabel.alpha = 0.5
            UIView.animateWithDuration(0.1, delay: 0.1, options: nil, animations: {
                self.gameMainTitle.center.x -= 10
                self.blueAdjustTitle.alpha = 0
                self.yellowAdjustTitle.alpha = 0
                self.hintLabel.alpha = 0
                }, completion: nil)
            UIView.animateWithDuration(0.1, delay: 0.2, options: nil, animations: {
                self.gameMainTitle.center.x += 5
                self.hintLabel.alpha = 1
                }, completion: nil)
        }
    }
    
    @IBAction func gameStart(sender: UIButton) {
        playSFX.play()
        self.gameMainTitle.center.x += 5
        self.blueAdjustTitle.alpha = 0.6
        self.yellowAdjustTitle.alpha = 0.6
        sender.backgroundColor = UIColor(red: 255, green: 218, blue: 106, alpha: 1)
        UIView.animateWithDuration(0.1, delay: 0.1, options: nil, animations: {
            self.gameMainTitle.center.x -= 10
            self.blueAdjustTitle.alpha = 0
            self.yellowAdjustTitle.alpha = 0
            sender.backgroundColor = UIColor(red: 86, green: 129, blue: 184, alpha: 1)
            }, completion: nil)
        UIView.animateWithDuration(0.1, delay: 0.2, options: nil, animations: {
            self.gameMainTitle.center.x += 5
            self.gameMainTitle.alpha = 0
            sender.alpha = 0
            self.hintLabel.alpha = 0
            }, completion: nil)
        gaming = true
        countdownTime = 10
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "gameClock:", userInfo: nil, repeats: false)
    }
    
    func gameClock(sender:NSTimer){
        
        var numPadView = storyboard?.instantiateViewControllerWithIdentifier("numPadView") as! ViewController2
        numPadView.BGM = audioPlayer
        presentViewController(numPadView, animated: false, completion: nil)
        
    }
    @IBAction func turnTutor(sender: UISwitch) {
        let setting = "\(documentsPath)/setting.plist"
        var sd:NSMutableDictionary = NSMutableDictionary(contentsOfFile: setting)!
        sd.setValue(sender.on, forKey: "showTutor")
        sd.writeToFile(setting, atomically: true)
        
    }
    @IBAction func turnBGM(sender: UISwitch) {
        let setting = "\(documentsPath)/setting.plist"
        var sd:NSMutableDictionary = NSMutableDictionary(contentsOfFile: setting)!
        sd.setValue(sender.on, forKey: "BGM")
        sd.writeToFile(setting, atomically: true)
        if sender.on{
            audioPlayer.volume = 0.4
            playSFX.volume = 1
        }else{
            audioPlayer.volume = 0
            playSFX.volume = 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

