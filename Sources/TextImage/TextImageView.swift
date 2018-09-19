//
//  TextImageView.swift
//  Gallery-iOS
//
//  Created by Alexander Korus on 21.08.18.
//  Copyright © 2018 Hyper Interaktiv AS. All rights reserved.
//

import Foundation

class TextImageView: UIView {
    
    lazy var backgroundView: GradientView = self.makeBackgroundView()
    lazy var textView: UITextView = self.makeTextView()

    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup() {
        self.backgroundColor = UIColor.white
        
        self.addSubview(self.backgroundView)
        
        Constraint.on(
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundView.rightAnchor.constraint(equalTo: self.rightAnchor),
            backgroundView.leftAnchor.constraint(equalTo: self.leftAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        )
        
        self.backgroundView.addSubview(self.textView)
        
        Constraint.on(
            textView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            textView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            textView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.4)
        )
        
    }
    
    
    private func makeBackgroundView() -> GradientView {
        let view = GradientView()
        view.gradientLayer.colors = Config.TextImage.backgroundColors.color1
        view.gradientLayer.gradient = GradientPoint.topLeftBottomRight.draw()
        view.tag = 0
        return view
    }
    
    private func makeTextView() -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        if #available(iOS 10.0, *) {
            textView.adjustsFontForContentSizeCategory = true
        } 
        textView.textColor = UIColor.white.withAlphaComponent(0.7)
        textView.isScrollEnabled = false
        let attributedString = NSAttributedString(string: "", attributes: [NSAttributedStringKey.font: Config.TextImage.Text.font])
        textView.attributedText = attributedString
        textView.font = Config.TextImage.Text.placeholderFont
        textView.text = Config.TextImage.Text.placeholder
        textView.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        textView.textContainer.maximumNumberOfLines = 3
        //textView.textContainer.lineBreakMode = .byTruncatingTail
        return textView
    }
    
}
