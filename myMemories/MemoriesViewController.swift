//
//  MemoriesViewController.swift
//  myMemories
//
//  Created by dainf on 28/07/17.
//  Copyright © 2017 br.utfpr. All rights reserved.
//

import UIKit

import AVFoundation // biblioteca para utilizar o microfone
import Photos // biblioteca de fotos do usuario
import Speech // reconhecimento de transcrição de fala

class MemoriesViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var memories = [URL]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMemory))
        
        loadMemories()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkPermissions()
    }
    
    func checkPermissions() {
        let photosAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
        let recordingAuthorized = AVAudioSession.sharedInstance().recordPermission() == .granted
        let transcribeAuthorized = SFSpeechRecognizer.authorizationStatus() == .authorized
        
        let authorized = photosAuthorized && recordingAuthorized && transcribeAuthorized
        
        if authorized == false {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "Permissions") {
                navigationController?.present(viewController, animated: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func loadMemories() {
        memories.removeAll()
        
        // Tentativa de carregar todos os arquivos de nosso diretório raiz (root)
        guard let files = try? FileManager.default.contentsOfDirectory(at:
            getDocumentsDirectory(), includingPropertiesForKeys: nil, options: [])
            else {
                return
            }
        
        // Percorre todos os arquivos, um a um
        for file in files {
            let filename = file.lastPathComponent
            
            // Se encontrar arquivos com a extensão .thumb
            if filename.hasSuffix(".thumb") {
                
                // Remove a extensão
                let noExtension = filename.replacingOccurrences(of: ".thumb", with: "")
                let memoryPath = getDocumentsDirectory().appendingPathComponent(noExtension)
                
                // Armazena o path dos arquivos
                memories.append(memoryPath)
            }
        }
    }
    
    func resize(image: UIImage, to width: CGFloat) -> UIImage? {
        // Calcula a escala da imagem em relção a largura original
        let scale = width / image.size.width
        
        // Calcula a altura baseado na escala, mantendo a proporção da imagem
        let height = image.size.height * scale
        
        // Cria um contexto (canvas) para desenhar dentro dele
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height),
                                               false, 0)
        
        // Desenha a imagem original dentro do contexto
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Armazena a imagem compactada na variável
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // Finaliza o contexto criado
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let possibleImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            saveNewMemory(image: possibleImage)
            
            loadMemories()
        }
        
        dismiss(animated: true)
    }
    
    func addMemory() {
        let viewController = UIImagePickerController()
        viewController.modalPresentationStyle = .formSheet
        viewController.delegate = self
        navigationController?.present(viewController, animated: true)
    }
    
    func saveNewMemory(image: UIImage) {
        let memoryName = "memory-\(Date().timeIntervalSince1970)"
        let imageName = memoryName + ".jpg"
//        let thumbnailName = memoryName + ".thumb"
        do {
            let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
            if let jpegData = UIImageJPEGRepresentation(image, 80) {
                try jpegData.write(to: imagePath, options: [.atomicWrite])
            }
        } catch {
            print("Falha ao salvar foto no disco")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
