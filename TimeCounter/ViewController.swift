//
//  ViewController.swift
//  TimeCounter
//
//  Created by Kazuyoshi Aizawa on 2016/05/05.
//  Copyright © 2016年 Kazuyoshi Aizawa. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    enum Status {
        case STOPPED
        case STARTED
        case INTERVAL
    }

    var status: Status = .STOPPED
    var suspended = false
    var timeCount: Int = 0
    var rapCount: Int = 0
    var intervalCount: UInt32 = 0
    var speechEnabled: Bool = true
    var audioPlayer: AVAudioPlayer!
    var timer: Timer?

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
    @IBOutlet weak var speechSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        speechSwitch.isOn = true

        self.minute.setup(count: 60, selectedRow: Int(self.minute.text!)!)
        self.second.setup(count: 60, selectedRow: Int(self.second.text!)!)
        self.interval.setup(count: 60, selectedRow: Int(self.interval.text!)!)
        self.rap.setup(count: 10, selectedRow: Int(self.rap.text!)!)

        if let soundUrl = Bundle.main.url(forResource: "beep", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundUrl)
                audioPlayer.prepareToPlay()
            } catch {}
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func startAction(_ sender: AnyObject) {
        if status == .STOPPED {
            timeCount = Int(minute.text!)! * 60 + Int(second.text!)!
            rapCount = Int(rap.text!)!
            intervalCount = UInt32(interval.text!)!
            UIApplication.shared.isIdleTimerDisabled = true
            status = .STARTED
            suspended = false
            rapLeft.text = (rapCount - 1).description
            updateTimeDisplay()
            if speechEnabled { speechTimeLeft() }
            startButton.setTitle("一時停止", for: .normal)
            startTimer()
        } else if !suspended {
            suspended = true
            stopTimer()
            startButton.setTitle("再開", for: .normal)
        } else {
            suspended = false
            startButton.setTitle("一時停止", for: .normal)
            startTimer()
        }
    }

    @IBAction func stopAction(_ sender: AnyObject) {
        stopTimer()
        suspended = false
        status = .STOPPED
        reset()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        switch status {
        case .STARTED:  tickCountdown()
        case .INTERVAL: tickInterval()
        case .STOPPED:  break
        }
    }

    private func tickCountdown() {
        timeCount -= 1
        updateTimeDisplay()

        if timeCount == 0 {
            playBeep()
            rapCount -= 1
            if rapCount == 0 {
                stopTimer()
                reset()
            } else if intervalCount == 0 {
                // interval=0: immediately restart countdown without pause
                timeCount = Int(minute.text!)! * 60 + Int(second.text!)!
                rapLeft.text = (rapCount - 1).description
                updateTimeDisplay()
                if speechEnabled { speechTimeLeft() }
            } else {
                status = .INTERVAL
                message.text = "インターバル"
                secLeft.text = String(intervalCount)
            }
            return
        }

        rapLeft.text = (rapCount - 1).description
        if speechEnabled { speechTimeLeft() }
    }

    private func tickInterval() {
        // transition when intervalCount reaches 1 so we never display "0"
        if intervalCount <= 1 {
            playBeep()
            status = .STARTED
            message.text = ""
            intervalCount = UInt32(interval.text!)!
            timeCount = Int(minute.text!)! * 60 + Int(second.text!)!
            rapLeft.text = (rapCount - 1).description
            updateTimeDisplay()
            if speechEnabled { speechTimeLeft() }
            return
        }
        intervalCount -= 1
        secLeft.text = String(intervalCount)
    }

    private func updateTimeDisplay() {
        let sec = timeCount % 60
        let min = timeCount / 60
        if timeCount >= 60 {
            minLeft.isHidden = false
            colon.isHidden = false
            secLeft.text = String(format: "%02d", sec)
        } else {
            minLeft.isHidden = true
            colon.isHidden = true
            secLeft.text = String(format: "%d", sec)
        }
        minLeft.text = String(format: "%d", min)
    }

    func playBeep() {
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }

    func speechTimeLeft() {
        let min = timeCount / 60
        let sec = timeCount % 60
        if timeCount % 30 == 0 || timeCount == 20 || timeCount == 10 || timeCount == 5 {
            if min == 0 {
                TextSpeaker.sharedInstance.append(text: "のこり" + timeCount.description + "秒です")
            } else if sec == 0 {
                TextSpeaker.sharedInstance.append(text: "のこり" + min.description + "分です")
            } else {
                TextSpeaker.sharedInstance.append(text: "のこり" + min.description + "分" + sec.description + "秒です")
            }
        }
    }

    func reset() {
        minLeft.text = "00"
        secLeft.text = "00"
        rapLeft.text = "0"
        colon.isHidden = false
        minLeft.isHidden = false
        message.text = ""
        intervalCount = 0
        status = .STOPPED
        UIApplication.shared.isIdleTimerDisabled = false
        startButton.setTitle("スタート", for: .normal)
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

    func presetMinute(_ val: Double) {
        let min: Int = Int(val) / 60
        let sec: Int = Int(val) % 60
        minute.text = min.description
        second.text = sec.description
        second.picker.selectRow(sec, inComponent: 0, animated: true)
        minute.picker.selectRow(min, inComponent: 0, animated: true)
    }

    @IBAction func preset5sec(_ sender: AnyObject) {
        presetSecond(5)
    }

    @IBAction func preset10sec(_ sender: AnyObject) {
        presetSecond(10)
    }

    @IBAction func preset20sec(_ sender: AnyObject) {
        presetSecond(20)
    }

    @IBAction func preset30sec(_ sender: AnyObject) {
        presetSecond(30)
    }

    func presetSecond(_ val: Double) {
        let sec: Int = Int(val)
        second.text = sec.description
        minute.text = "0"
        second.picker.selectRow(sec, inComponent: 0, animated: true)
        minute.picker.selectRow(0, inComponent: 0, animated: true)
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

    func presetInterval(_ sec: Double) {
        interval.text = Int(sec).description
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

    func presetRap(_ count: Double) {
        rap.text = Int(count).description
        rap.picker.selectRow(Int(count), inComponent: 0, animated: true)
    }

    @IBAction func speechSwitchAction(_ sender: UISwitch) {
        speechEnabled = sender.isOn
    }
}
