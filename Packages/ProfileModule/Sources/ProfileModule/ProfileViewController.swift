//
//  ProfileViewController.swift
//  iOSArchitecture
//
//  Created by 孙俊祥 on 2026/4/8.
//

import UIKit
import AppRouting

@MainActor
final class ProfileViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    private let userId: String
    let routing: AppRoutable
    private var didFinishThroughPop = false

    init(userId: String, routing: AppRoutable) {
        self.userId = userId
        self.routing = routing
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile: \(userId)"

        let hintLabel = UILabel()
        hintLabel.text = "Swipe down to dismiss, or use Close (GoRouter.pop)"
        hintLabel.textColor = .secondaryLabel
        hintLabel.numberOfLines = 0
        hintLabel.textAlignment = .center
        hintLabel.translatesAutoresizingMaskIntoConstraints = false

        let closeButton = UIButton(type: .system)
        closeButton.configuration = .filled()
        closeButton.configuration?.title = "Close"
        closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(hintLabel)
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hintLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 16)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        attachAdaptivePresentationDelegate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        attachAdaptivePresentationDelegate()
    }

    private func attachAdaptivePresentationDelegate() {
        let sheetPresentation = navigationController?.presentationController ?? presentationController
        sheetPresentation?.delegate = self
    }

    @objc
    private func onClose() {
        didFinishThroughPop = true
        routing.pop(from: self, animated: true)
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard !didFinishThroughPop else { return }
        routing.pop(from: self, animated: true)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
