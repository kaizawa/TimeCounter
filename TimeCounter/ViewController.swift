//
//  ViewController.swift
//  TimeCounter
//
//  Created by Kazuyoshi Aizawa on 2016/05/05.
//  Copyright © 2016年 Kazuyoshi Aizawa. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {
    
    
    var stopped : Bool = false
    var soundId : SystemSoundID = 1000 // default sound

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        duration.text = Int(durationStepper.value).description
        interval.text = Int(intervalStepper.value).description
        rap.text = Int(rapStepper.value).description

        if let soundUrl = NSBundle.mainBundle().URLForResource("beep", withExtension: "mp3"){
            AudioServicesCreateSystemSoundID(soundUrl, &soundId)
        }
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
    }

    @IBOutlet weak var interval: UITextField!
    @IBOutlet weak var duration: UITextField!
    @IBOutlet weak var rap: UITextField!
    
    @IBOutlet weak var timeLeft: UILabel!
    @IBOutlet weak var rapLeft: UILabel!
    
    @IBAction func startAction(sender: AnyObject) {

        stopped = false

        NSOperationQueue().addOperationWithBlock({() -> Void in
            
            var first:Bool = true
            
            var rapCount:Int = (Int(self.rap.text!))!
            
            while(rapCount > 0){
                
                // decrement rap count
                NSOperationQueue.mainQueue().addOperationWithBlock({() -> Void in
                    self.rapLeft.text = rapCount.description
                })

                // for the second or later iteration, sound beep.
                if(first){
                    first = false;
                } else {
                    
                    var intervalCount = UInt32(self.interval.text!)!
                    for _ in 0...intervalCount - 1 {

                        NSOperationQueue.mainQueue().addOperationWithBlock({() -> Void in
                            self.timeLeft.text = String(intervalCount)
                        })
                        
                        if(self.stopped){
                            break
                        }
                        sleep(1)
                        intervalCount -= 1
                    }
                    AudioServicesPlaySystemSoundWithCompletion(self.soundId){ () -> Void in }
                }
                
                var timeCount:Int = (Int(self.duration.text!))!
                
                while(timeCount >= 0){
                    
                    if(self.stopped){
                        break;
                    }
                 
                    NSOperationQueue.mainQueue().addOperationWithBlock({() -> Void in
                        self.timeLeft.text = timeCount.description
                    })
                    
                    if(timeCount == 0){
                        break
                    }
                    sleep(1)
                    timeCount -= 1
                }
                
                if(self.stopped){
                    break
                }
                AudioServicesPlaySystemSoundWithCompletion(self.soundId){ () -> Void in }

                rapCount -= 1

            }
            NSOperationQueue.mainQueue().addOperationWithBlock({() -> Void in
                self.timeLeft.text = String("0")
                self.rapLeft.text = String("0")
            })
        })
        
    }

    @IBAction func stopAction(sender: AnyObject) {
        
        stopped = true;
    }
    
    @IBOutlet weak var durationStepper: UIStepper!

    @IBAction func dureationStepperValueChanged(sender: UIStepper) {
        
        duration.text = Int(sender.value).description
    }
    
    @IBOutlet weak var intervalStepper: UIStepper!
    
    @IBAction func intervalStepperValueChanged(sender: UIStepper) {
        
        interval.text = Int(sender.value).description
    }
    

    @IBOutlet weak var rapStepper: UIStepper!
    
    @IBAction func rapStepperValueChanged(sender: UIStepper) {
        
        rap.text = Int(sender.value).description
    }
    
    @IBAction func presetDuration60sec(sender: AnyObject) {
        presetDuration(60)
    }
    
    @IBAction func presetDuration90sec(sender: AnyObject) {
        presetDuration(90)
    }
    
    @IBAction func presetDuration120sec(sender: AnyObject) {
        presetDuration(120)
    }

    @IBAction func presetDuration180sec(sender: AnyObject) {
        presetDuration(180)
    }
    
    func presetDuration(sec : Double){
        duration.text = String(Int(sec))
        durationStepper.value = sec
    }

    @IBAction func presetInterval5sec(sender: AnyObject) {
        presetInterval(5)
    }
    
    @IBAction func presetInterval10sec(sender: AnyObject) {
        presetInterval(10)
    }
    
    @IBAction func presetInterval20sec(sender: AnyObject) {
        presetInterval(20)
    }
    
    @IBAction func presetInterval30sec(sender: AnyObject) {
        presetInterval(30)
    }
    
    func presetInterval(sec : Double){
        interval.text = String(Int(sec))
        intervalStepper.value = sec
    }
    
    @IBAction func presetRap1(sender: AnyObject) {
        presetRap(1)
    }
    
    @IBAction func presetRap2(sender: AnyObject) {
        presetRap(2)
    }
    
    @IBAction func presetRap3(sender: AnyObject) {
        presetRap(3)
    }
    
    @IBAction func presetRap5(sender: AnyObject) {
        presetRap(5)
    }

    func presetRap(count : Double){
        rap.text = String(Int(count))
        rapStepper.value = count
    }
}

