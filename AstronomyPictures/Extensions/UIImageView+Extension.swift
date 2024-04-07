//
//  UIImageView+Extension.swift
//  AstronomyPictures
//
//  Created by Duy Đỗ on 6/4/24.
//

import Foundation
import UIKit

extension UIImageView {
    
    func animateSetImage(_ image: UIImage) {
        UIView.transition(with: self, duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
            self?.image = image
        },
                          completion: nil
        )
    }
}
