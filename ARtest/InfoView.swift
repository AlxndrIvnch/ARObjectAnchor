//
//  InfoView.swift
//  ARtest
//
//  Created by alexander.ivanchenko on 05.03.2023.
//

import UIKit

class InfoView: UIView {
    lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Info Info Info Info Info Info Info Info Info Info"
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addLabel() {
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([label.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
                                     label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
                                     label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
                                     label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16)])
    }
    
}
