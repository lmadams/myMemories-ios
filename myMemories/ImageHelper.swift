//
//  ImageHelper.swift
//  myMemories
//
//  Created by dainf on 18/08/17.
//  Copyright © 2017 br.utfpr. All rights reserved.
//

import UIKit

class ImageHelper: NSObject {
    
    static func resize(image: UIImage, to width: CGFloat) -> UIImage? {
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

}
