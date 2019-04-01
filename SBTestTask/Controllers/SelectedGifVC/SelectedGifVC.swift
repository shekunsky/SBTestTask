//
//  SelectedGifVC.swift
//  SBTestTask
//
//  Created by Alex2 on 3/30/19.
//  Copyright © 2019 Alex Shekunsky. All rights reserved.
//

import UIKit

class SelectedGifVC: UIViewController {

    //MARK: vars
    internal var imageToReveal: FLAnimatedImageView!
    internal var imageSet: GiphyImageSet!
    private var gifDataForSharing: [Any] = []
    
    //MARK: outlets
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var imageView: FLAnimatedImageView!
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareImage()
        prepareShareData()
    }
    
    private func prepareImage() {
        if imageToReveal.image != nil && imageToReveal.animatedImage != nil {
            imageView.image = imageToReveal.image
            imageView.animatedImage = imageToReveal.animatedImage
        } else {
            configureFor(imageSet: imageSet)
        }
    }
    
    private func configureFor(imageSet: GiphyImageSet) {
        imageView.sd_setShowActivityIndicatorView(true)
        imageView.sd_setIndicatorStyle(.gray)
        imageView.sd_setImage(with: imageSet.url)
    }
    
    private func prepareShareData() {
        DispatchQueue.global(qos: .default).async {
            let shareURL: NSURL = self.imageSet!.url! as NSURL
            let shareData: NSData = NSData(contentsOf: shareURL as URL)!
            self.gifDataForSharing = [shareData as Any]
        }
    }
    
    //MARK: actions
    @IBAction func shareButtonPressed(_ sender: Any) {
        guard !gifDataForSharing.isEmpty else {
            return
        }
        
        let shareController = UIActivityViewController(
            activityItems: gifDataForSharing,
            applicationActivities: nil)
        
        shareController.popoverPresentationController?.permittedArrowDirections = .any
        present(shareController, animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        imageView.stopAnimating()
        dismiss(animated: true, completion: nil)
    }
    
}
