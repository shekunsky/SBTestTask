//
//  PresentAnimator.swift
//  SBTestTask
//
//  Created by Alex2 on 3/30/19.
//  Copyright © 2019 Alex Shekunsky. All rights reserved.
//

class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimationsConstants.animatorsTransitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        //create animation
        let finalFrame = toView.frame
        
        let xScaleFactor = originFrame.width / finalFrame.width
        let yScaleFactor = originFrame.height / finalFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        toView.transform = scaleTransform
        toView.center = CGPoint(
            x: originFrame.midX,
            y: originFrame.midY
        )
        
        toView.clipsToBounds = true
        
        containerView.addSubview(toView)
        
        
        UIView.animate(withDuration: AnimationsConstants.animatorsTransitionDuration, delay: 0.0,
                       options: [], animations: {
                        
                        toView.transform = CGAffineTransform.identity
                        toView.center = CGPoint(
                            x: finalFrame.midX,
                            y: finalFrame.midY
                        )
                        
        }, completion: {_ in
            
            //complete the transition
            transitionContext.completeTransition(
                !transitionContext.transitionWasCancelled
            )
        })
    }
    
}
