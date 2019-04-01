//
//  DismissAnimator.swift
//  SBTestTask
//
//  Created by Alex2 on 3/30/19.
//  Copyright © 2019 Alex Shekunsky. All rights reserved.
//

class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimationsConstants.animatorsTransitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        //setup the transition
        let containerView = transitionContext.containerView
        
        if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from),
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
            containerView.insertSubview(toView, belowSubview: fromView)
            
            //animations
            UIView.animate(withDuration: AnimationsConstants.animatorsTransitionDuration, delay: 0.0, options: [], animations: {
                
                fromView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                
            }, completion: {_ in
                //complete the transition
                transitionContext.completeTransition(
                    !transitionContext.transitionWasCancelled
                )
                
            })
        } else {
            transitionContext.completeTransition(
                !transitionContext.transitionWasCancelled
            )
        }
    }
    
}
