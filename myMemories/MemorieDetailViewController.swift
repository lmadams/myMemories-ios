//
//  MemorieDetailViewController.swift
//  myMemories
//
//  Created by dainf on 18/08/17.
//  Copyright © 2017 br.utfpr. All rights reserved.
//

import UIKit

import AVFoundation // biblioteca para utilizar o microfone
import Photos // biblioteca de fotos do usuario
import Speech // reconhecimento de transcrição de fala

class MemorieDetailViewController: UIViewController, AVAudioRecorderDelegate {
    var memory: URL!
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var recordingURL: URL!

    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var transcripionText: UITextField!
    
    @IBOutlet weak var buttonRecord: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Definir long press para o btn de record
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressButton))
        buttonRecord.addGestureRecognizer(longGesture)
        
        // Arquivo temporario para gravacao
        recordingURL = Memory.getDocumentsDirectory().appendingPathComponent("recording.m4a")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadInformation()
    }
    
    func loadInformation() {
        let fileManager = FileManager.default
        
        do {
            // Recupera AUDIO
            let audioName = URLHelper.audioURL(for: memory)
            if fileManager.fileExists(atPath: audioName.path) {
                audioPlayer = try AVAudioPlayer(contentsOf: audioName)
            }
            
            // recupera transcricption
            let transcriptionName = URLHelper.transcriptionURL(for: memory)
            if fileManager.fileExists(atPath: transcriptionName.path) {
                let contents = try String(contentsOf: transcriptionName)
                transcripionText.text = contents
            }
            
            // Recupera titulo
            labelTitle.text = memory.lastPathComponent
            
            // Recupera imagem para exibir
            let imgName = URLHelper.imageURL(for: memory).path
            let image = UIImage.init(contentsOfFile: imgName)
            imageView.image = image
            
        } catch let error {
            print("Erro ao recuperar informacoes do file manager \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func longPressButton(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            recordMemory()
        } else if sender.state == .ended {
            finishRecording(success: true)
        }
    }
    
//    @TODO refatorar
    func recordMemory() {
        let recordSession = AVAudioSession.sharedInstance()
        do {
            try recordSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 44100,
                            AVNumberOfChannelsKey: 2, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
            
            audioRecorder?.delegate = self
            
            audioRecorder?.record()
        } catch let error {
            print("Erro ao gravar áudio \(error)")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if !flag {
            finishRecording(success: false)
        }
    }
    
    // @TODO refatorar
    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        
        if (success) {
            do {
                let memoryAudioURL = URLHelper.audioURL(for: memory)
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: memoryAudioURL.path) {
                    
                    try fileManager.removeItem(at: memoryAudioURL)
                    
                }
                
                try fileManager.moveItem(at: recordingURL, to: memoryAudioURL)
                
                // Recarregar informacoes e audio
                loadInformation()
            } catch let error {
                print("Erro ao copiar arquivo de áudio \(error)")
            }
        }
    }

    @IBAction func onClickPlayMemory(_ sender: Any) {
        print("Play audio")
        audioPlayer?.play()
    }
    
    @IBAction func onClickToEdit(_ sender: Any) {
        print("On click to edit description")
        
        let transcription = URLHelper.transcriptionURL(for: memory)
        
        if let text = transcripionText.text {
            do {
                print (text)
                
                try text.write(to: transcription, atomically: true, encoding: String.Encoding.utf8)
                
                Memory.indexMemory(memory: memory, text: text)
                
                navigationController?.popViewController(animated: true)
            } catch {
                print("Erro ao salvar a transcrição de áudio")
            }
        }
    }
    
    
}
