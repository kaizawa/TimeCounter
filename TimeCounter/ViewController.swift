//
//  ViewController.swift
//  TimeCounter
//
//  Created by Kazuyoshi Aizawa on 2016/05/05.
//  Copyright © 2016年 Kazuyoshi Aizawa. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class ViewController: UIViewController {
    
    enum Status {
        case STOPPED
        case STARTED
        case SUSPENDED
        case INTERVAL
    }
    
    var beepSoundId : SystemSoundID = 1000 // default sound
    var status : Status = Status.STOPPED
    var timeCount:Int = 0
    var rapCount:Int = 0
    var first:Bool = true
    var intervalCount: UInt32 = 0;

    @IBOutlet weak var minLeft: UILabel!
    @IBOutlet weak var secLeft: UILabel!
    @IBOutlet weak var rapLeft: UILabel!
    @IBOutlet weak var colon: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var minute: PickerTextField!
    @IBOutlet weak var second: PickerTextField!
    @IBOutlet weak var interval: PickerTextField!
    @IBOutlet weak var rap: PickerTextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.minute.setup(count:60, selectedRow:(Int(self.minute.text!))!)
        self.second.setup(count:60, selectedRow:(Int(self.second.text!))!)
        self.interval.setup(count:60, selectedRow:(Int(self.interval.text!))!)
        self.rap.setup(count:10, selectedRow:(Int(self.rap.text!))!)
        
        if let soundUrl = Bundle.main.url(forResource: "beep", withExtension: "mp3"){
            AudioServicesCreateSystemSoundID(soundUrl as CFURL, &beepSoundId)
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // set category to play sound in background
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            // enable audio session
            try audioSession.setActive(true)
        } catch  {
            fatalError("failed to setup audio session")
        }
    }
  
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func startAction(_ sender: AnyObject) {
        

        //stopped = false
        if(status == Status.STOPPED) {
            
            OperationQueue.main.addOperation({() -> Void in
                self.startButton.setTitle("一時停止", for: .normal)
            })
            self.timeCount = (Int(self.minute.text!))! * 60 + (Int(self.second.text!))!
            self.rapCount = (Int(self.rap.text!))!
            self.intervalCount = (UInt32(self.interval.text!))!
            //not to sleep while running
            UIApplication.shared.isIdleTimerDisabled = true
            status = Status.STARTED
        }
        else if(status == Status.STARTED) {
            
            OperationQueue.main.addOperation({() -> Void in
                self.startButton.setTitle("再開", for: .normal)
            })
            status = Status.SUSPENDED
            return
        }
        else if(status == Status.SUSPENDED) {
            
            OperationQueue.main.addOperation({() -> Void in
                self.startButton.setTitle("一時停止", for: .normal)
            })
            status = Status.STARTED
        }
        
        OperationQueue().addOperation({() -> Void in
            
                self.countDown()
        })
    }
    
    func countDownInterval() {
        
        OperationQueue.main.addOperation({() -> Void in
            self.message.text = "インターバル"
        })
            
        while( self.intervalCount > 0) {
            
                OperationQueue.main.addOperation({() -> Void in
                    self.secLeft.text = String(self.intervalCount)
                })
                
                if(self.status == Status.STOPPED){
                    self.reset()
                    return
                } else if(self.status == Status.SUSPENDED){
                    return
                }
                sleep(1)
                self.intervalCount -= 1
        }
            
        OperationQueue.main.addOperation({() -> Void in
                
            self.status = Status.STARTED
            self.message.text = ""
            self.intervalCount = (UInt32(self.interval.text!))!
            self.timeCount = (Int(self.minute.text!))! * 60 + (Int(self.second.text!))!
            
            OperationQueue().addOperation({() -> Void in
                
                self.countDown()
            })
        })
            
        AudioServicesPlaySystemSound(self.beepSoundId)
    }
    
    func countDown() {
        
        while(self.rapCount > 0)
        {
                if(self.status == Status.INTERVAL)
                {
                    self.countDownInterval()
                    return
                }
            
                // decrement rap count
                OperationQueue.main.addOperation({() -> Void in
                    self.rapLeft.text = (self.rapCount - 1).description
                })

                while(self.timeCount >= 0)
                {
                    if(self.status == Status.STOPPED){
                        self.reset()
                        return
                    } else if (self.status == Status.SUSPENDED) {
                        return
                    }
                 
                    OperationQueue.main.addOperation({() -> Void in
                        
                        var sec:Int = 0
                        var min:Int = 0
                        sec = self.timeCount % 60
                        if(self.timeCount >= 60) {
                            min = self.timeCount / 60
                            self.minLeft.isHidden = false
                            self.colon.isHidden = false
                            self.secLeft.text = NSString(format: "%02d", sec) as String
                        } else {
                            self.minLeft.isHidden = true
                            self.colon.isHidden = true
                            self.secLeft.text = NSString(format: "%d", sec) as String
                        }

                        self.minLeft.text = NSString(format: "%d", min) as String
                    })
                    
                    if(self.timeCount == 0){
                        break
                    }
                    speechTimeLeft()
                    sleep(1)
                    self.timeCount -= 1
                }
            
                AudioServicesPlaySystemSound(self.beepSoundId)

                self.rapCount -= 1
                self.status = Status.INTERVAL
        }
        self.reset()
    }
    
    func speechTimeLeft()
    {
        if(self.timeCount % 30 == 0 || self.timeCount == 20 || self.timeCount == 10) {
            TextSpeaker.sharedInstance.append(text: "のこり" + self.timeCount.description + "秒です")
        }
    }
    
    func reset () {

        OperationQueue.main.addOperation({() -> Void in
            
            self.minLeft.text = String("00")
            self.secLeft.text = String("00")
            self.rapLeft.text = String("0")
            self.colon.isHidden = false
            self.minLeft.isHidden = false
            self.first = true
            self.message.text = ""
            self.intervalCount = 0
            self.status = Status.STOPPED
            // enable sleep if not running
            UIApplication.shared.isIdleTimerDisabled = false
            self.startButton.setTitle("スタート", for: .normal)
        })
    }

    @IBAction func stopAction(_ sender: AnyObject) {
        
        if(status == Status.SUSPENDED) {
            reset()
        }
        self.status = Status.STOPPED
    }
    
    @IBAction func presetMinute60sec(_ sender: AnyObject) {
        presetMinute(60)
    }
    
    @IBAction func presetMinute90sec(_ sender: AnyObject) {
        presetMinute(90)
    }
    
    @IBAction func presetMinute120sec(_ sender: AnyObject) {
        presetMinute(120)
    }

    @IBAction func presetMinute180sec(_ sender: AnyObject) {
        presetMinute(180)
    }
    
    func presetMinute(_ val : Double)
    {
        let min:Int = Int(val) / 60
        let sec:Int = Int(val) % 60
        
        OperationQueue.main.addOperation({() -> Void in
            self.minute.text = min.description
            self.second.text = sec.description
        })
        second.picker.selectRow(sec, inComponent: 0, animated: true)
        minute.picker.selectRow(min, inComponent: 0, animated: true)
    }

    @IBAction func presetInterval5sec(_ sender: AnyObject) {
        presetInterval(5)
    }
    
    @IBAction func presetInterval10sec(_ sender: AnyObject) {
        presetInterval(10)
    }
    
    @IBAction func presetInterval20sec(_ sender: AnyObject) {
        presetInterval(20)
    }
    
    @IBAction func presetInterval30sec(_ sender: AnyObject) {
        presetInterval(30)
    }
    
    func presetInterval(_ sec : Double)
    {
        OperationQueue.main.addOperation({() -> Void in
            self.interval.text = Int(sec).description
        })
        interval.picker.selectRow(Int(sec), inComponent: 0, animated: true)
    }
    
    @IBAction func presetRap1(_ sender: AnyObject) {
        presetRap(1)
    }
    
    @IBAction func presetRap2(_ sender: AnyObject) {
        presetRap(2)
    }
    
    @IBAction func presetRap3(_ sender: AnyObject) {
        presetRap(3)
    }
    
    @IBAction func presetRap5(_ sender: AnyObject) {
        presetRap(5)
    }

    func presetRap(_ count : Double)
    {
        OperationQueue.main.addOperation({() -> Void in
            self.rap.text = Int(count).description
        })
        rap.picker.selectRow(Int(count), inComponent: 0, animated: true)
    }
}

