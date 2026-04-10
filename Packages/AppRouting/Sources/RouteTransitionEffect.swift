//
//  RouteTransitionEffect.swift
//  AppRouting
//
//  Created by 孙俊祥 on 2026/4/10.
//

import UIKit

@MainActor
public final class FadePushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval

    public init(duration: TimeInterval = 0.28) {
        self.duration = duration
        super.init()
    }

    public func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        duration
    }

    public func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        toView.alpha = 0.0
        container.addSubview(toView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toView.alpha = 1.0
        }, completion: { finished in
            let cancelled = transitionContext.transitionWasCancelled
            if cancelled {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(!cancelled && finished)
        })
    }
}

@MainActor
public final class FadePopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval

    public init(duration: TimeInterval = 0.28) {
        self.duration = duration
        super.init()
    }

    public func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        duration
    }

    public func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let insertedToView = toView.superview == nil
        if toView.superview == nil {
            container.insertSubview(toView, belowSubview: fromView)
        }

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView.alpha = 0.0
        }, completion: { finished in
            let cancelled = transitionContext.transitionWasCancelled
            fromView.alpha = 1.0
            if cancelled, insertedToView {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(!cancelled && finished)
        })
    }
}
