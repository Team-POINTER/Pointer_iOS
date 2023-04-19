//
//  UIImage.swift
//  Pointer_iOS
//
//  Created by 박현준 on 2023/03/09.
//

import UIKit

extension UIImage {
    static let defaultProfile = UIImage(named: "PointerDefaultProfile")
    
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale

        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
//        print("화면 배율: \(UIScreen.main.scale)")// 배수
//        print("origin: \(self), resize: \(renderImage)")
        return renderImage
    }
}
