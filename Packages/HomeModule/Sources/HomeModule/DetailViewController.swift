//
//  DetailViewController.swift
//  iOSArchitecture
//
//  Created by 孙俊祥 on 2026/4/8.
//

import UIKit
import AppRouting

@MainActor
final class DetailViewController: UIViewController {
    private let routing: AppRoutable
    private let itemId: String

    init(routing: AppRoutable, itemId: String) {
        self.routing = routing
        self.itemId = itemId
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Detail \(itemId)"

        let popButton = UIButton(type: .system)
        popButton.configuration = .filled()
        popButton.configuration?.title = "Pop Current"
        popButton.addTarget(self, action: #selector(onPop), for: .touchUpInside)
        popButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(popButton)
        NSLayoutConstraint.activate([
            popButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc
    private func onPop() {
        routing.pop(from: self, animated: true)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
