//
//  TextImageController.swift
//  Cache
//
//  Created by Alexander Korus on 21.08.18.
//

import UIKit
import CoreGraphics
import AVFoundation
import Photos


@available(iOS 10.0, *)
class TextImageController: UIViewController {
    
    let once = Once()
    let cart: Cart
    lazy var textImageView: TextImageView = self.makeTextImageView()
    let layoutManager = NSLayoutManager()
    lazy var stackView: StackView = self.makeStackView()
    @available(iOS 10.0, *)
    lazy var colorPickerButton: UIButton = self.makeColorPickerButton()
    lazy var colorPickerTextButton: UIButton = self.makeColorPickerText()
    lazy var addTextImageButton: UIButton = self.makeAddTextImageButton()
    lazy var doneButton: UIButton = self.makeDoneButton()
    lazy var colorPickerView: UIView = self.makeColorButton()
    let button = GradientRoundedButtonView(type: .system)
    
    // MARK: - Init
    
    public required init(cart: Cart) {
        self.cart = cart
        super.init(nibName: nil, bundle: nil)
        cart.delegates.add(self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    @available(iOS 10.0, *)
    func setup() {
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(self.textImageView)
        
        Constraint.on(
            textImageView.topAnchor.constraint(equalTo: view.topAnchor),
            textImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            textImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            textImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        )
        
        
        self.view.addSubview(self.colorPickerView)
        
        let gradientLayer = GradientRoundedView()
        gradientLayer.gradientLayer.colors = getGradientColor()
        button.gradientLayer.colors = getGradientColor()
        textImageView.backgroundView.tag = 1
        colorPickerView.addSubview(button)
        
        Constraint.on(
            button.centerXAnchor.constraint(equalTo: colorPickerView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: colorPickerView.centerYAnchor),
            button.widthAnchor.constraint(equalTo: colorPickerView.widthAnchor, multiplier: 0.8),
            button.heightAnchor.constraint(equalTo: colorPickerView.heightAnchor, multiplier: 0.8)
        )
        
        
        button.addTarget(self, action: #selector(colorPickerButtonTapped(_:)), for: .touchUpInside)
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.textImageView.addGestureRecognizer(viewTap)
        
        self.view.addSubview(self.stackView)
        stackView.g_pin(on: .left, constant: 38)
        stackView.g_pin(size: CGSize(width: 56, height: 56))
        stackView.g_pin(on: .bottom, constant: -16)
        stackView.addTarget(self, action: #selector(stackViewTouched(_:)), for: .touchUpInside)

        self.view.addSubview(self.addTextImageButton)
        self.view.addSubview(self.colorPickerTextButton)
        colorPickerTextButton.addTarget(self, action: #selector(colorPickerButtonTapped(_:)), for: .touchUpInside)
        
        if #available(iOS 11, *) {
            Constraint.on(
                addTextImageButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
                addTextImageButton.heightAnchor.constraint(equalToConstant: 30.0),
                addTextImageButton.widthAnchor.constraint(equalToConstant: 120.0),
                addTextImageButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -20),
                //addTextImageButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
                //addTextImageButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: ),
                
                colorPickerView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 20),
                colorPickerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
                colorPickerView.heightAnchor.constraint(equalToConstant: 30.0),
                colorPickerView.widthAnchor.constraint(equalToConstant: 30.0),
                
                colorPickerTextButton.leftAnchor.constraint(equalTo: self.colorPickerView.rightAnchor, constant: 5),
                colorPickerTextButton.centerYAnchor.constraint(equalTo: self.colorPickerView.centerYAnchor, constant: 0),
                colorPickerTextButton.widthAnchor.constraint(equalToConstant: 100)
            )
        } else {
            Constraint.on(
                addTextImageButton.topAnchor.constraint(equalTo: self.view.topAnchor),
                colorPickerView.topAnchor.constraint(equalTo: self.view.topAnchor),
                colorPickerView.heightAnchor.constraint(equalToConstant: 30.0),
                colorPickerView.widthAnchor.constraint(equalToConstant: 30.0),
                addTextImageButton.heightAnchor.constraint(equalToConstant: 30.0),
                addTextImageButton.widthAnchor.constraint(equalToConstant: 30.0)
            )
        }
        
        addTextImageButton.addTarget(self, action: #selector(addTextImageButtonTapped(_:)), for: .touchUpInside)
        
        
        textImageView.textView.delegate = self
        
        
        self.view.addSubview(self.doneButton)
        doneButton.g_pin(on: .right, constant: -38)
        doneButton.g_pin(on: .bottom, constant: -20)
        doneButton.addTarget(self, action: #selector(doneButtonTouched(_:)), for: .touchUpInside)
    }
    
    private func makeTextImageView() -> TextImageView {
        let view = TextImageView()
        return view
    }
    
    func makeStackView() -> StackView {
        let view = StackView()
        return view
    }
    
    @available(iOS 10.0, *)
    private func makeColorPickerButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(GalleryBundle.image("gallery_color_picker"), for: UIControl.State())
        return button
    }
    
    private func makeColorPickerText() -> UIButton {
        let label = UIButton()
        label.setTitle(Config.TextImage.Text.colorPickerText, for: .normal)
        label.setTitleColor(UIColor.white, for: .normal)
        label.setTitleColor(UIColor.lightGray, for: .highlighted)
        label.titleLabel?.font = Config.TextImage.Text.colorPickerFont
        label.titleLabel?.textAlignment = .left
        return label
    }
    
    @available(iOS 10.0, *)
    private func makeColorButton() -> UIView {
        let view: RoundedBorderView = RoundedBorderView()
        view.backgroundColor = .clear
        return view
    }
    
    private func makeAddTextImageButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .highlighted)
        button.titleLabel?.font = Config.Font.Text.regular.withSize(13.0)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitle("Text übernehmen", for: .normal)
        return button
    }
    
    func refreshView() {
        let hasImages = !cart.images.isEmpty
        stackView.g_fade(visible: hasImages)
    }
    
    fileprivate func isBelowImageLimit() -> Bool {
        return (Config.Camera.imageLimit == 0 || Config.Camera.imageLimit > cart.images.count)
    }
    
    func makeDoneButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.white, for: UIControl.State())
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.titleLabel?.font = Config.Font.Text.regular.withSize(16)
        button.setTitle("Gallery.Done".g_localize(fallback: Config.Text.doneButtonText), for: UIControl.State())
        
        return button
    }
    
    func getGradientColor() -> [CGColor] {
        
        if Config.TextImage.backgroundColors.colors.indices.contains(textImageView.backgroundView.tag + 1) {
            return Config.TextImage.backgroundColors.colors[textImageView.backgroundView.tag + 1]
        } else {
            // check if tag is the last tag
            if Config.TextImage.backgroundColors.colors.indices.last == textImageView.backgroundView.tag {
                return Config.TextImage.backgroundColors.colors[0]
            } else if Config.TextImage.backgroundColors.colors.indices.contains(1) {
                return Config.TextImage.backgroundColors.colors[1]
            } else if Config.TextImage.backgroundColors.colors.indices.contains(0) {
                return Config.TextImage.backgroundColors.colors[0]
            } else {
                return Config.TextImage.backgroundColors.color1
            }
            
            
        }
        
    }
}

@available(iOS 10.0, *)
extension TextImageController {
    
    @objc func colorPickerButtonTapped(_ passedButton: UIButton) {
      
        
        self.button.gradientLayer.colors = getGradientColor()
        
        let currentTag = textImageView.backgroundView.tag
        
        if currentTag < Config.TextImage.backgroundColors.colors.count {
            textImageView.backgroundView.gradientLayer.colors = Config.TextImage.backgroundColors.colors[currentTag]
            textImageView.backgroundView.tag = currentTag + 1
        } else {
            textImageView.backgroundView.tag = 0
            textImageView.backgroundView.gradientLayer.colors = Config.TextImage.backgroundColors.colors[0]
            textImageView.backgroundView.tag = textImageView.backgroundView.tag + 1
        }
        
    }
    
    @objc func dismissKeyboard() {
        self.textImageView.textView.resignFirstResponder()
    }
    
    @available(iOS 10.0, *)
    @objc func addTextImageButtonTapped(_ button: UIButton) {
        guard isBelowImageLimit() else { return }
        guard textImageView.textView.text != Config.TextImage.Text.placeholder && textImageView.textView.text != "" else {
            return
        }
        stackView.startLoading()
        self.textImageView.textView.resignFirstResponder()
        UIImageWriteToSavedPhotosAlbum(self.textImageView.backgroundView.asImage(), self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    @objc func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        self.textImageView.textView.text = ""
        self.textImageView.textView.text = Config.TextImage.Text.placeholder
        self.textImageView.textView.textColor = UIColor.white.withAlphaComponent(0.7)
        self.textImageView.textView.font = Config.TextImage.Text.placeholderFont
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        // Fetch the image assets
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        if fetchResult.count > 0 {
            if let asset = fetchResult.firstObject {
                cart.add(Image(asset: asset), newlyTaken: true)
            }
        }
        stackView.stopLoading()
    }
    
    @objc func stackViewTouched(_ stackView: StackView) {
        EventHub.shared.stackViewTouched?()
    }
    
    @objc func doneButtonTouched(_ button: UIButton) {
        if cart.images.count > 0 {
            EventHub.shared.doneWithImages?()
        } else {
            EventHub.shared.close?()
        }
    }
}

@available(iOS 10.0, *)
extension TextImageController: CartDelegate {
    
    func cart(_ cart: Cart, didAdd image: Image, newlyTaken: Bool) {
        stackView.reload(cart.images, added: true)
        refreshView()
    }
    
    func cart(_ cart: Cart, didRemove image: Image) {
        stackView.reload(cart.images)
        refreshView()
    }
    
    func cartDidReload(_ cart: Cart) {
        stackView.reload(cart.images)
        refreshView()
    }
}

/*@available(iOS 10.0, *)
extension TextImageController: PageAware {
    
    /*func pageDidShow() {
        once.run {
            setup()
        }
        
    }*/
}*/

@available(iOS 10.0, *)
extension TextImageController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let existingLines = textView.text.components(separatedBy: CharacterSet.newlines)
        let newLines = text.components(separatedBy: CharacterSet.newlines)
        let linesAfterChange = existingLines.count + newLines.count - 1
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return linesAfterChange <= textView.textContainer.maximumNumberOfLines && newText.count < 20
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        var lineRanges: [NSValue] = []
        textView.layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: layoutManager.numberOfGlyphs), using: { rect, usedRect, textContainer, glyphRange, stop in
            let characterRange: NSRange = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            lineRanges.append(NSValue(range: characterRange))
        })
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Config.TextImage.Text.placeholder {
            textView.text = ""
            textView.textColor = .white
            textView.font = Config.TextImage.Text.font
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = Config.TextImage.Text.placeholder
            textView.textColor = UIColor.white.withAlphaComponent(0.7)
            textView.font = Config.TextImage.Text.placeholderFont
        }
    }
}

class RoundedBorderView: UIView {
    
    override func layoutSubviews() {
        self.layer.cornerRadius = self.bounds.size.width / 2.0
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.0
    }
    
}

class RoundedView: UIView {
    
    override func layoutSubviews() {
        self.layer.cornerRadius = self.bounds.size.width / 2.0
        self.clipsToBounds = true
    }
    
}

class RoundedButton: UIButton {
    
    override func layoutSubviews() {
        self.layer.cornerRadius = self.bounds.size.width / 2.0
        self.clipsToBounds = true
    }
    
}
