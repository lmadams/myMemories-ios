//
//  ViewController.swift
//  myMemories
//
//  Created by dainf on 28/07/17.
//  Copyright © 2017 br.utfpr. All rights reserved.
//

import UIKit

import AVFoundation // biblioteca para utilizar o microfone
import Photos // biblioteca de fotos do usuario
import Speech // reconhecimento de transcrição de fala

class ViewController: UIViewController {

    @IBOutlet weak var labelConfirmar: UILabel!
    
    @IBAction func onClickConfirmar(_ sender: Any) {
        requestPhotoPermission()
    }
    
    func requestPhotoPermission() {
        PHPhotoLibrary.requestAuthorization { [unowned self]
            authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.requestRecorderPermissions()
                } else {
                    self.labelConfirmar.text = "As permissões para acessar a biblioteca de fotos foram negadas. Para o aplicativo funcionar corretamente, favor habilitar as permissões nas configurações de seu celular"
                }
            }
        }
    }
    
    func requestRecorderPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { [unowned self]
            allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.requestTranscribePermissions()
                } else {
                    self.labelConfirmar.text = "As permissões para gravação de áudio foram negadas. Para o aplicativo funcionar corretamente, favor habilitar essa permissão nas configurações de seu celular"
                }
            }
        }
    }
    
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { [unowned self]
            authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.completeAuthorization()
                } else {
                    self.labelConfirmar.text = "As permissões para transcrição de áudio foram negadas. Favor habilitar as permissões em seu celular"
                }
            }
        }
    }
    
    func completeAuthorization() {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
