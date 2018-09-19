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


class TextImageController: UIViewController {
    
    let once = Once()
    let cart: Cart
    lazy var textImageView: TextImageView = self.makeTextImageView()
    let layoutManager = NSLayoutManager()
    lazy var stackView: StackView = self.makeStackView()
    lazy var colorPickerButton: UIButton = self.makeColorPickerButton()
    lazy var addTextImageButton: UIButton = self.makeAddTextImageButton()
    lazy var doneButton: UIButton = self.makeDoneButton()

    
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
    
    func setup() {
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(self.textImageView)
        
        Constraint.on(
            textImageView.topAnchor.constraint(equalTo: view.topAnchor),
            textImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            textImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            textImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        )
        
        self.view.addSubview(self.colorPickerButton)
        if #available(iOS 11.0, *) {
            Constraint.on (
                self.colorPickerButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 40.0),
                self.colorPickerButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -20.0)
            )
        } else {
            // Fallback on earlier versions
            Constraint.on (
                self.colorPickerButton.rightAnchor.constraint(equalTo: self.view.leftAnchor, constant: 100.0),
                self.colorPickerButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -20.0)
            )
        }
    
        
        colorPickerButton.addTarget(self, action: #selector(colorPickerButtonTapped(_:)), for: .touchUpInside)
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.textImageView.addGestureRecognizer(viewTap)
        
        self.view.addSubview(self.stackView)
        stackView.g_pin(on: .left, constant: 38)
        stackView.g_pin(size: CGSize(width: 56, height: 56))
        stackView.g_pin(on: .bottom, constant: -16)
        stackView.addTarget(self, action: #selector(stackViewTouched(_:)), for: .touchUpInside)

        self.view.addSubview(self.addTextImageButton)
        if #available(iOS 11.0, *) {
            Constraint.on (
                self.addTextImageButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -20),
                self.addTextImageButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -20.0)
            )
        } else {
            // Fallback on earlier versions
            Constraint.on (
                self.colorPickerButton.rightAnchor.constraint(equalTo: self.view.leftAnchor, constant: 100.0),
                self.colorPickerButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -20.0)
            )
        }
        
        if #available(iOS 10.0, *) {
            addTextImageButton.addTarget(self, action: #selector(addTextImageButtonTapped(_:)), for: .touchUpInside)
        } else {
            // Fallback on earlier versions
        }
        
        textImageView.textView.delegate = self
        
        
        self.view.addSubview(self.doneButton)
        doneButton.g_pin(on: .right, constant: -38)
        doneButton.g_pin(on: .bottom, constant: -12)
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
    
    private func makeColorPickerButton() -> UIButton {
        let button = UIButton(type: .custom)
        //button.setTitle("WTF", for: .normal)
        button.setImage(GalleryBundle.image("gallery_color_picker"), for: UIControlState())
        return button
    }
    
    private func makeAddTextImageButton() -> UIButton {
        let button = UIButton(type: .custom)
        //button.setTitle("Hinzufügen", for: .normal)
        button.setImage(GalleryBundle.image("gallery_done_button"), for: UIControlState())
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
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.titleLabel?.font = Config.Font.Text.regular.withSize(16)
        button.setTitle("Gallery.Done".g_localize(fallback: Config.Text.doneButtonText), for: UIControlState())
        
        return button
    }
}

extension TextImageController {
    
    @objc func colorPickerButtonTapped(_ button: UIButton) {
        
        switch (textImageView.backgroundView.tag) {
        case 0:
            textImageView.backgroundView.gradientLayer.colors = [UIColor.blue.cgColor, UIColor.green.cgColor]
            textImageView.backgroundView.tag = 1
        case 1:
            textImageView.backgroundView.gradientLayer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
            textImageView.backgroundView.tag = 2
        case 2:
            textImageView.backgroundView.gradientLayer.colors = [UIColor.black.cgColor, UIColor.white.cgColor]
            textImageView.backgroundView.tag = 0
        default:
            textImageView.backgroundView.gradientLayer.colors = [UIColor.black.cgColor, UIColor.white.cgColor]
            textImageView.backgroundView.tag = 0
        }
        
    }
    
    @objc func dismissKeyboard() {
        self.textImageView.textView.resignFirstResponder()
    }
    
    @available(iOS 10.0, *)
    @objc func addTextImageButtonTapped(_ button: UIButton) {
        guard isBelowImageLimit() else { return }
        stackView.startLoading()
        self.textImageView.textView.resignFirstResponder()
        UIImageWriteToSavedPhotosAlbum(self.textImageView.backgroundView.asImage(), self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    @objc func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        print("saved")
        self.textImageView.textView.text = ""
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
        EventHub.shared.doneWithImages?()
    }
}

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

extension TextImageController: PageAware {
    
    func pageDidShow() {
        once.run {
            setup()
        }
        
    }
}

extension TextImageController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
      
        /*let pointSize: CGFloat = 40.0 // arbitrary
        var attributedString: NSAttributedString? = nil
        if let aSize = UIFont(name: "Helvetica", size: pointSize) {
            attributedString = NSAttributedString(string: text, attributes: [NSAttributedStringKey.font: aSize])
        }
        let textWidth: CGFloat = (attributedString?.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), context: nil).width)!
    
        let scaleFactor: CGFloat = textView.size.width / textWidth
        let preferredFontSize: CGFloat = pointSize * scaleFactor
        let calculatedFontSize = preferredFontSize.clamped(to: 25.0...30.0)
        let fontDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptor.AttributeName.family : "Arial MT Bold"])
        var typingAttributes = textView.typingAttributes
        typingAttributes[NSAttributedStringKey.font.rawValue] = UIFont(descriptor: fontDescriptor, size: calculatedFontSize)
        textView.typingAttributes = typingAttributes*/
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 20
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        var lineRanges: [NSValue] = []
        textView.layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: layoutManager.numberOfGlyphs), using: { rect, usedRect, textContainer, glyphRange, stop in
            let characterRange: NSRange = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            lineRanges.append(NSValue(range: characterRange))
        })
        
    }
    
}
