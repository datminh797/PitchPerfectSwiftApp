//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by minhdat on 07/06/2022.
//

import UIKit
import AVFAudio
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    @IBOutlet weak var slow : UIButton!
    @IBOutlet weak var fast : UIButton!
    @IBOutlet weak var highPitch : UIButton!
    @IBOutlet weak var lowPitch : UIButton!
    @IBOutlet weak var echo : UIButton!
    @IBOutlet weak var reverb : UIButton!
    @IBOutlet weak var stopButton : UIButton!
    
    var recordedAudioURL: URL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    enum ButtonType: Int {case slow = 1, fast, highPitch, lowPitch, echo, reverb}
    
    @IBAction func playSoundForButton(_ sender: UIButton){
        
        switch(ButtonType(rawValue: sender.tag)!){
        
        case .slow:
            playSound(rate: 0.3)
        case .fast:
            playSound(rate: 2)
        case .highPitch:
            playSound(pitch: 1500)
        case .lowPitch:
            playSound(pitch: -1000)
        case .echo:
            playSound(echo: true)
        case .reverb:
            playSound(reverb: true)
        }
        
        configureUI(.playing)
    }
    
    @IBAction func stopButtonPressed(_ sender : AnyObject){
        stopAudio()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAudio()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI(.notPlaying)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
