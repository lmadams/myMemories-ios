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

import CoreSpotlight
import MobileCoreServices

class MemoriesViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, AVAudioRecorderDelegate {
    
    var memories = [URL]()
    var filteredMemories = [URL]()
    var activeMemory: URL!
    var recordingURL: URL!
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var searchQuery: CSSearchQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMemory))
        
        recordingURL = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
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
        
        filteredMemories = memories
        
        collectionView?.reloadSections(IndexSet(integer: 1))
        
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
        let thumbnailName = memoryName + ".thumb"
        do {
            let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
            if let jpegData = UIImageJPEGRepresentation(image, 80) {
                try jpegData.write(to: imagePath, options: [.atomicWrite])
            }
            
            if let thumbnail = resize(image: image, to: 200) {
                let thumbPath = getDocumentsDirectory().appendingPathComponent(thumbnailName)
                
                if let thumbData = UIImageJPEGRepresentation(thumbnail, 80) {
                    try thumbData.write(to: thumbPath, options: [.atomicWrite])
                }
            }
        } catch {
            print("Falha ao salvar foto no disco")
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            return filteredMemories.count
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterMemories(text: searchText)
    }
    
    func filterMemories(text: String) {
        guard text.characters.count > 0 else {
            filteredMemories = memories
        
            UIView.performWithoutAnimation {
                collectionView?.reloadSections(IndexSet(integer: 1))
            }
            
            return
        }
        
        var allItems = [CSSearchableItem]()
        
        searchQuery?.cancel()
        
        let queryString = "contentDescription == \"*\(text)*\"c"
        searchQuery = CSSearchQuery(queryString: queryString, attributes: nil)
        
        searchQuery?.foundItemsHandler = {
            items in
            allItems.append(contentsOf: items)
        }
        
        searchQuery?.completionHandler = {
            error in
            
            DispatchQueue.main.async {
                [unowned self] in
                
                self.listItems(matches: allItems)
            }
        }
        
        searchQuery?.start()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func listItems (matches: [CSSearchableItem]) {
        filteredMemories = matches.map {
            item in
            return URL(fileURLWithPath: item.uniqueIdentifier)
        }
        
        UIView.performWithoutAnimation {
            collectionView?.reloadSections(IndexSet(integer: 1))
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Memory",
                                                      for: indexPath) as! MemoryCell
        
        let memory = filteredMemories[indexPath.row]
        
        let imageName = memory.appendingPathExtension("thumb").path
        
        let image = UIImage.init(contentsOfFile: imageName)
        
        cell.imageView.image = image
        
        if cell.gestureRecognizers == nil {
            let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(memoryLongPress))
            
            recognizer.minimumPressDuration = 0.25
            
            cell.addGestureRecognizer(recognizer)
            
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.borderWidth = 3
            cell.layer.cornerRadius = 10
        }
        
        return cell
    }
    
    func memoryLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let cell = sender.view as! MemoryCell
            
            if let index = collectionView?.indexPath(for: cell) {
                activeMemory = filteredMemories[index.row]
                
                recordMemory()
            }
        } else if sender.state == .ended {
            finishRecording(success: true)
        }
    }
    
    func transcribeHack(memory: URL) {
        
        let transcription = transcriptionURL(for: memory)
        
        let text = "MInha memoria do dia 10/08"
        
        do {
            print (text)
            
            try text.write(to: transcription, atomically: true, encoding: String.Encoding.utf8)
            
            indexMemory(memory: memory, text: text)
            
        } catch {
            print("Erro ao salvar a transcrição de áudio")
        }
    }
    
    func recordMemory() {
        collectionView?.backgroundColor = UIColor.red
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
    
    // Metodo chamado quando usuario clica na imagem da tela
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Abre tela com os detalhes da memoria
        let viewController = storyboard?.instantiateViewController(withIdentifier: "MemoryDetail") as! MemorieDetailViewController
        viewController.memory = filteredMemories[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
        
        
        /*
        let memory = filteredMemories[indexPath.row]
        
        let fileManager = FileManager.default
        
        do {
            let audioName = audioURL(for: memory)
            
            if fileManager.fileExists(atPath: audioName.path) {
                audioPlayer = try AVAudioPlayer(contentsOf: audioName)
                
                audioPlayer?.play()
            }
            
            let transcriptionName = transcriptionURL(for: memory)
            
            if fileManager.fileExists(atPath: transcriptionName.path) {
                let contents = try String(contentsOf: transcriptionName)
                
                print(contents)
            }
            
        } catch let error {
            print("Erro ao reproduzir áudio \(error)")
        }
 */
    }
    
    func transcribeAudio(memory: URL) {
        let audio = audioURL(for: memory)
        
        let transcription = transcriptionURL(for: memory)
        
        let recognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "pt-BR"))
        
        let request = SFSpeechURLRecognitionRequest(url: audio)
        
        recognizer?.recognitionTask(with: request) {
            
            (result, error) in
            
            guard let result = result else {
                
                let err = "Erro ao transcrever áudio: \(error!)"
                print(err)
                
                return
            }
            
            if result.isFinal {
                let text = result.bestTranscription.formattedString
                
                do {
                    print (text)
                    
                    try text.write(to: transcription, atomically: true, encoding: String.Encoding.utf8)
                    
                } catch {
                    print("Erro ao salvar a transcrição de áudio")
                }
            }
            
            
        }
    }
    
    func finishRecording(success: Bool) {
        collectionView?.backgroundColor = UIColor.white
        audioRecorder?.stop()
        
        if (success) {
            do {
                let memoryAudioURL = activeMemory.appendingPathExtension("m4a")
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: memoryAudioURL.path) {
                    
                    try fileManager.removeItem(at: memoryAudioURL)
                    
                }
                
                try fileManager.moveItem(at: recordingURL, to: memoryAudioURL)
                
//                transcribeAudio(memory: activeMemory)
                transcribeHack(memory: activeMemory)
            } catch let error {
                print("Erro ao copiar arquivo de áudio \(error)")
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 1 {
            return CGSize.zero
        } else {
            return CGSize(width: 0, height: 50)
        }
    }
    
    func audioURL(for memory: URL) -> URL {
        
        return memory.appendingPathExtension("m4a")
    }
    
    func thumbailURL(for memory: URL) -> URL {
        
        return memory.appendingPathExtension("thumb")
    }
    
    func transcriptionURL(for memory: URL) -> URL {
        
        return memory.appendingPathExtension("txt")
    }
    
    func imageURL(for memory: URL) -> URL {
        
        return memory.appendingPathExtension("jpg")
    }
    
    func indexMemory(memory: URL, text: String) {
        
        let attributeset = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        
        attributeset.title = "myMemories App"
        attributeset.contentDescription = text
        attributeset.thumbnailURL = thumbailURL(for: memory)
        
        let item = CSSearchableItem(uniqueIdentifier: memory.path, domainIdentifier: "br.utfpr.myMemories",
                                    attributeSet: attributeset)
        
        item.expirationDate = Date.distantFuture
        
        CSSearchableIndex.default().indexSearchableItems([item]) {
            error in
            
            if let error = error {
                print("Erro de indexação \(error.localizedDescription)")
            } else {
                print("A memória foi indexada com sucesso!")
            }
        }
        
    }
}
