import UIKit
import Gallery
import Lightbox
import AVFoundation
import AVKit
import SVProgressHUD

class ViewController: UIViewController, LightboxControllerDismissalDelegate, GalleryControllerDelegate {

  var button: UIButton!
  var gallery: GalleryController!
  let editor: VideoEditing = VideoEditor()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white

    Gallery.Config.VideoEditor.savesEditedVideoToLibrary = true

    button = UIButton(type: .system)
    button.frame.size = CGSize(width: 200, height: 50)
    button.setTitle("Open Gallery", for: UIControlState())
    button.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)

    view.addSubview(button)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    button.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
  }

  @objc func buttonTouched(_ button: UIButton) {
    /*gallery = GalleryController()
    gallery.delegate = self

    present(gallery, animated: true, completion: nil)*/
    configureGallery(tabsToShow: [.imageTab, .cameraTab, .textTab], imageLimit: 2, recordLocation: false)
  }

  // MARK: - LightboxControllerDismissalDelegate

  func lightboxControllerWillDismiss(_ controller: LightboxController) {

  }

  func configureGallery(tabsToShow: [Gallery.Config.GalleryTab], imageLimit: Int, recordLocation: Bool) {
    Config.tabsToShow = tabsToShow
    Config.Camera.imageLimit = imageLimit
    Config.Camera.recordLocation = recordLocation
    Config.PageIndicator.backgroundColor = UIColor.white
    Config.PageIndicator.textColor = UIColor.black
    Config.Camera.BottomContainer.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.0)
    //Config.Camera.ShutterButton
    Config.Camera.ShutterButton.numberColor = .black
    Config.Grid.FrameView.borderColor = .green
    Config.Gallery.BottomContainer.blurAlpha = 0.5
    Config.Gallery.BottomContainer.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
    Config.PageIndicator.indicatorString = "gallery_page_indicator_green"
    Config.Text.cameraPageText = "KAMERA"
    Config.Text.photosPageText = "FOTOS"
    Config.Text.doneButtonText = "Fertig"
    Config.Text.dropdownButtonText = "ALLE FOTOS"
    Config.Text.flashButtonOnText = "AN"
    Config.Text.flashButtonOffText = "AUS"
    gallery = GalleryController()
    gallery.delegate = self
    self.present(gallery, animated: true, completion: nil)
  }
  
  // MARK: - GalleryControllerDelegate

  func galleryControllerDidCancel(_ controller: GalleryController) {
    controller.dismiss(animated: true, completion: nil)
    gallery = nil
  }

  func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
    controller.dismiss(animated: true, completion: nil)
    gallery = nil


    editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
      DispatchQueue.main.async {
        if let tempPath = tempPath {
          let controller = AVPlayerViewController()
          controller.player = AVPlayer(url: tempPath)

          self.present(controller, animated: true, completion: nil)
        }
      }
    }
  }

  func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
    controller.dismiss(animated: true, completion: nil)
    gallery = nil
  }

  func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
    LightboxConfig.DeleteButton.enabled = true

    SVProgressHUD.show()
    Image.resolve(images: images, completion: { [weak self] resolvedImages in
      SVProgressHUD.dismiss()
      self?.showLightbox(images: resolvedImages.flatMap({ $0 }))
    })
  }

  // MARK: - Helper

  func showLightbox(images: [UIImage]) {
    guard images.count > 0 else {
      return
    }

    let lightboxImages = images.map({ LightboxImage(image: $0) })
    let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
    lightbox.dismissalDelegate = self

    gallery.present(lightbox, animated: true, completion: nil)
  }
}

