//
//  SettingViewController.swift
//  iOSArchitecture
//
//  Created by 孙俊祥 on 2026/4/8.
//

import UIKit
import AppRouting

@MainActor
final class SettingsViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let routing: AppRoutable
    init?(routing: AppRoutable) {
        self.routing = routing
        super.init(nibName: nil, bundle: nil)
    }
    private var didFinishThroughPop = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Settings"

        let closeButton = UIButton(type: .system)
        closeButton.configuration = .filled()
        closeButton.configuration?.title = "Dismiss (pop)"
        closeButton.addTarget(self, action: #selector(onDismiss), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
    private func onDismiss() {
        didFinishThroughPop = true
        routing.pop(from: self, animated: true)
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard !didFinishThroughPop else { return }
        routing.pop(from: self, animated: true)
    }
}
