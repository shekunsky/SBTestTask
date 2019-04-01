//
//  GifSearchController+Extension.swift
//  SBTestTask
//
//  Created by Alex2 on 3/31/19.
//  Copyright © 2019 Alex Shekunsky. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - Keyboard
extension GifSearchController {
    
    @objc internal func updateBottomLayoutConstraintWithNotification(notification: NSNotification?) {
        let constantAdjustment: CGFloat = 0.0
        
        guard let bottomLayoutConstraint: NSLayoutConstraint = keyboardAdjustConstraint else {
            return
        }
        
        guard let userInfo = notification?.userInfo else {
            
            bottomLayoutConstraint.constant = constantAdjustment
            return
        }
        
        let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        let rawAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve = UIView.AnimationOptions(rawValue: UInt(rawAnimationCurve))
        
        let newConstantValue: CGFloat = max(self.view.bounds.maxY - convertedKeyboardEndFrame.minY + constantAdjustment, 0.0)
        
        if abs(bottomLayoutConstraint.constant - newConstantValue) >= 1.0
        {
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationCurve, animations: {
                
                bottomLayoutConstraint.constant = -newConstantValue
                self.view.layoutIfNeeded()
                
            }, completion: nil)
        }
        else
        {
            bottomLayoutConstraint.constant = -newConstantValue
        }
    }
}


// MARK: - SwiftyGiphyGridLayoutDelegate
extension GifSearchController: SwiftyGiphyGridLayoutDelegate {
    
    public func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        
        guard indexPath.row < viewModel.currentGifs.count else {
            return 0.0
        }
        guard let imageSet = viewModel.currentGifs[indexPath.row].imageSetClosestTo(width: withWidth, animated: true) else {
            return 0.0
        }
        
        return AVMakeRect(aspectRatio: CGSize(width: imageSet.width, height: imageSet.height), insideRect: CGRect(x: 0.0, y: 0.0, width: withWidth, height: CGFloat.greatestFiniteMagnitude)).height
    }
}

// MARK: - UICollectionViewDataSource
extension GifSearchController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModel.currentGifs.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kGifSearchCollectionViewCell, for: indexPath) as! SwiftyGiphyCollectionViewCell
        
        guard indexPath.row < viewModel.currentGifs.count else {
            return cell
        }
        
        if let collectionViewLayout = collectionView.collectionViewLayout as? SwiftyGiphyGridLayout, let imageSet = viewModel.currentGifs[indexPath.row].imageSetClosestTo(width: collectionViewLayout.columnWidth, animated: true)
        {
            cell.configureFor(imageSet: imageSet)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension GifSearchController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCell = collectionView.cellForItem(at: indexPath)! as! SwiftyGiphyCollectionViewCell
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let imageRevealVC = mainStoryboard.instantiateViewController(withIdentifier: "SelectedGifVC") as! SelectedGifVC
        
        imageRevealVC.transitioningDelegate = self
        
        if let collectionViewLayout = collectionView.collectionViewLayout as? SwiftyGiphyGridLayout,
            let imageSet = viewModel.currentGifs[indexPath.row].imageSetClosestTo(width: collectionViewLayout.columnWidth, animated: true) {
            
            imageRevealVC.imageSet = imageSet
            imageRevealVC.imageToReveal = selectedCell.imageView
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.navigationController?.present(imageRevealVC, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - UISearchControllerDelegate
extension GifSearchController: UISearchControllerDelegate {
    
    public func willPresentSearchController(_ searchController: UISearchController) {
        viewModel.searchCounter += 1
        viewModel.latestSearchResponse = nil
        viewModel.currentSearchPageOffset = 0
        viewModel.currentGifs = [GiphyItem]()
        errorLabel.isHidden = true
        loadingIndicator.stopAnimating()
    }
    
    public func willDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.text = nil
        for cell in collectionView.visibleCells {
            (cell as! SwiftyGiphyCollectionViewCell).imageView.stopAnimating()
        }
        viewModel.destroyCurrentResults()
        collectionView.setContentOffset(CGPoint(x: 0.0, y: -collectionView.contentInset.top), animated: false)
        setupLabel()
        clearCasheFromImages()
    }
}

// MARK: - UISearchResultsUpdating
extension GifSearchController: UISearchResultsUpdating {
    
    public func updateSearchResults(for searchController: UISearchController) {
        viewModel.destroyCurrentResults()
        viewModel.searchText = searchController.searchBar.text ?? ""
        viewModel.fetchNextSearchPage(false)
        if searchController.searchBar.text!.isEmpty {
            for cell in collectionView.visibleCells {
                (cell as! SwiftyGiphyCollectionViewCell).imageView.stopAnimating()
            }
            clearCasheFromImages()
            setupLabel()
        }
    }
}

// MARK: - UIScrollViewDelegate
extension GifSearchController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard viewModel.allowResultPaging else {
            return
        }
        
        if scrollView.contentOffset.y + scrollView.bounds.height + UIScreen.main.bounds.height >= scrollView.contentSize.height
        {
            if searchController.isActive
            {
                if !viewModel.isSearchPageLoadInProgress && viewModel.latestSearchResponse != nil
                {
                    // Load next search page
                    DispatchQueue.global(qos: .default).async {
                        self.viewModel.searchCoalesceTimer!.invalidate()
                        self.viewModel.fetchNextSearchPage(true)
                    }
                }
            }
        }
    }
}


// MARK: UIViewControllerTransitioningDelegate
extension GifSearchController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = PresentAnimator()
        var frame  = selectedCell.frame //the selected cell gives us the frame origin for the reveal animation
        frame.origin.y -= collectionView.contentOffset.y
        animator.originFrame = frame
        return animator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = DismissAnimator()
        return animator
    }
    
}
