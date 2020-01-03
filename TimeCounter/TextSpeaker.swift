import UIKit
import Foundation
import AVFoundation

class TextSpeaker : NSObject, AVSpeechSynthesizerDelegate
{
    static let sharedInstance = TextSpeaker()
    
    var texts = [String]()
    let talker = AVSpeechSynthesizer()
    
    private override init() {
        super.init()
        talker.delegate = self
    }
    
    func append(text: String) {
        texts.append(text)
        if texts.count == 1 {
            play(texts[0])
        }
    }
    
    // MARK: AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if texts.count > 0 {
            texts.removeFirst()
            if texts.count > 0 {
                play(texts[0])
            }
        } else {
            // speech finished
        }
    }
    
    func clear() {
        texts.removeAll()
        if talker.isSpeaking {
            talker.stopSpeaking(at: .immediate)
        }
    }
    
    private func play(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        talker.speak(utterance)
    }

}
