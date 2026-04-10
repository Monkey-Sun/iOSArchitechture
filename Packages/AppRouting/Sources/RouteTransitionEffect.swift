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

@MainActor
public final class BottomSheetPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private enum Constants {
        static let dimmingViewTag = 0xB07_7001
    }

    private let duration: TimeInterval
    private let dampingRatio: CGFloat
    private let initialVelocity: CGFloat
    private let dimmingAlpha: CGFloat
    private let backgroundScale: CGFloat

    public init(
        duration: TimeInterval = 0.36,
        dampingRatio: CGFloat = 0.9,
        initialVelocity: CGFloat = 0.2,
        dimmingAlpha: CGFloat = 0.18,
        backgroundScale: CGFloat = 0.98
    ) {
        self.duration = duration
        self.dampingRatio = dampingRatio
        self.initialVelocity = initialVelocity
        self.dimmingAlpha = dimmingAlpha
        self.backgroundScale = backgroundScale
        super.init()
    }

    public func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        duration
    }

    public func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard
            let toView = transitionContext.view(forKey: .to),
            let toVC = transitionContext.viewController(forKey: .to),
            let fromView = transitionContext.view(forKey: .from)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        let originalFromTransform = fromView.transform
        let dimmingView = UIView(frame: container.bounds)
        dimmingView.tag = Constants.dimmingViewTag
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView.backgroundColor = .black
        dimmingView.alpha = 0.0
        container.insertSubview(dimmingView, aboveSubview: fromView)
        toView.frame = finalFrame.offsetBy(dx: 0, dy: container.bounds.height)
        container.addSubview(toView)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: dampingRatio,
            initialSpringVelocity: initialVelocity,
            options: [.curveEaseOut, .allowUserInteraction]
        ) {
            dimmingView.alpha = self.dimmingAlpha
            fromView.transform = CGAffineTransform(scaleX: self.backgroundScale, y: self.backgroundScale)
            toView.frame = finalFrame
        } completion: { finished in
            let cancelled = transitionContext.transitionWasCancelled
            if cancelled {
                fromView.transform = originalFromTransform
                dimmingView.removeFromSuperview()
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(!cancelled && finished)
        }
    }
}

@MainActor
public final class BottomSheetPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private enum Constants {
        static let dimmingViewTag = 0xB07_7001
    }

    private let duration: TimeInterval

    public init(duration: TimeInterval = 0.30) {
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
        if insertedToView {
            container.insertSubview(toView, belowSubview: fromView)
        }
        let originalFromFrame = fromView.frame
        let finalFromFrame = originalFromFrame.offsetBy(dx: 0, dy: container.bounds.height)
        let originalToTransform = toView.transform
        let dimmingView = container.viewWithTag(Constants.dimmingViewTag)
        let originalDimmingAlpha = dimmingView?.alpha ?? 0.0

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: [.curveLinear, .allowUserInteraction]
        ) {
            dimmingView?.alpha = 0.0
            toView.transform = .identity
            fromView.frame = finalFromFrame
        } completion: { finished in
            let cancelled = transitionContext.transitionWasCancelled
            if cancelled {
                fromView.frame = originalFromFrame
                toView.transform = originalToTransform
                dimmingView?.alpha = originalDimmingAlpha
                if insertedToView {
                    toView.removeFromSuperview()
                }
            } else {
                dimmingView?.removeFromSuperview()
            }
            transitionContext.completeTransition(!cancelled && finished)
        }
    }
}
