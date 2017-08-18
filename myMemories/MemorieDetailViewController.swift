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

class MemorieDetailViewController: UIViewController {
    var memory: URL!
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadInformation()
    }
    
    func loadInformation() {
        let fileManager = FileManager.default
        
        do {
            let audioName = URLHelper.audioURL(for: memory)
            
            // Recupera AUDIO
            if fileManager.fileExists(atPath: audioName.path) {
                audioPlayer = try AVAudioPlayer(contentsOf: audioName)
//                audioPlayer?.play()
            }
            
            // recupera transcricption
            let transcriptionName = URLHelper.transcriptionURL(for: memory)
            if fileManager.fileExists(atPath: transcriptionName.path) {
                let contents = try String(contentsOf: transcriptionName)
                print(contents)
            }
            
            // Recupera titulo
            
            // Recupera imagem para exibir
            
        } catch let error {
            print("Erro ao recuperar informacoes do file manager \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
