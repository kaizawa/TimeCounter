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
    
    
    var stopped : Bool = false
    var beepSoundId : SystemSoundID = 1000 // default sound

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        duration.text = Int(durationStepper.value).description
        interval.text = Int(intervalStepper.value).description
        rap.text = Int(rapStepper.value).description

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

    @IBOutlet weak var interval: UITextField!
    @IBOutlet weak var duration: UITextField!
    @IBOutlet weak var rap: UITextField!
    
    @IBOutlet weak var timeLeft: UILabel!
    @IBOutlet weak var rapLeft: UILabel!
    
    @IBAction func startAction(_ sender: AnyObject) {

        stopped = false

        OperationQueue().addOperation({() -> Void in
            
            var first:Bool = true
            
            var rapCount:Int = (Int(self.rap.text!))!
            
            while(rapCount > 0){
                
                // decrement rap count
                OperationQueue.main.addOperation({() -> Void in
                    self.rapLeft.text = rapCount.description
                })

                // for the second or later iteration, sound beep.
                if(first){
                    first = false;
                } else {
                    
                    var intervalCount = UInt32(self.interval.text!)!
                    for _ in 0...intervalCount - 1 {

                        OperationQueue.main.addOperation({() -> Void in
                            self.timeLeft.text = String(intervalCount)
                        })
                        
                        if(self.stopped){
                            break
                        }
                        sleep(1)
                        intervalCount -= 1
                    }
                    AudioServicesPlaySystemSoundWithCompletion(self.beepSoundId){ () -> Void in }
                }
                
                var timeCount:Int = (Int(self.duration.text!))!
                
                while(timeCount >= 0){
                    
                    if(self.stopped){
                        break;
                    }
                 
                    OperationQueue.main.addOperation({() -> Void in
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
                AudioServicesPlaySystemSoundWithCompletion(self.beepSoundId){ () -> Void in }

                rapCount -= 1

            }
            OperationQueue.main.addOperation({() -> Void in
                self.timeLeft.text = String("0")
                self.rapLeft.text = String("0")
            })
        })
        
    }

    @IBAction func stopAction(_ sender: AnyObject) {
        
        stopped = true;
    }
    
    @IBOutlet weak var durationStepper: UIStepper!

    @IBAction func dureationStepperValueChanged(_ sender: UIStepper) {
        
        duration.text = Int(sender.value).description
    }
    
    @IBOutlet weak var intervalStepper: UIStepper!
    
    @IBAction func intervalStepperValueChanged(_ sender: UIStepper) {
        
        interval.text = Int(sender.value).description
    }
    

    @IBOutlet weak var rapStepper: UIStepper!
    
    @IBAction func rapStepperValueChanged(_ sender: UIStepper) {
        
        rap.text = Int(sender.value).description
    }
    
    @IBAction func presetDuration60sec(_ sender: AnyObject) {
        presetDuration(60)
    }
    
    @IBAction func presetDuration90sec(_ sender: AnyObject) {
        presetDuration(90)
    }
    
    @IBAction func presetDuration120sec(_ sender: AnyObject) {
        presetDuration(120)
    }

    @IBAction func presetDuration180sec(_ sender: AnyObject) {
        presetDuration(180)
    }
    
    func presetDuration(_ sec : Double){
        duration.text = String(Int(sec))
        durationStepper.value = sec
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
    
    func presetInterval(_ sec : Double){
        interval.text = String(Int(sec))
        intervalStepper.value = sec
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

    func presetRap(_ count : Double){
        rap.text = String(Int(count))
        rapStepper.value = count
    }
}

