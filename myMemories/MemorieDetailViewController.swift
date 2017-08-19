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

    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var transcripionText: UITextField!
    
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

    @IBAction func onClickPlayMemory(_ sender: Any) {
        print("Play audio")
        audioPlayer?.play()
    }
    
    @IBAction func onClickRecord(_ sender: Any) {
        print("On Click to record")
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
