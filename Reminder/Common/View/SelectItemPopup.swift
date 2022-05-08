//
//  SelectItemPopup.swift
//  Reminder
//
//  Created by linzsc on 26/02/2022.
//

import UIKit

protocol ItemSelectedPopupViewDelegate: AnyObject {
    func itemSelectedPopupViewDidSelected(_ view: ItemSelectedPopupView)
}

class ItemSelectedPopupView: TapableView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    init(index: Int) {
        super.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        commonInit()
        self.index = index
    }

    // MARK: - Variables
    private lazy var selectedImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "ic_ratio_unselected")
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Nunito.semiboldFont(size: 16)
        label.textColor = UIColor(rgb: 0x212121)
        return label
    }()

    private lazy var underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0xf0f0f0)
        return view
    }()

    weak var delegate: ItemSelectedPopupViewDelegate?
    var index: Int!
    var text: String! {
        didSet {
            titleLabel.text = text
        }
    }

    var isSelect: Bool = false {
        didSet {
            selectedImageView.image = UIImage(named: isSelect ? "ic_ratio_selected" : "ic_ratio_unselected")
        }
    }

    // MARK: - Common init
    private func commonInit() {
        self.scaleOnHighlight = 1
        self.backgroundColor = .white

        selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        underlineView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(selectedImageView)
        self.addSubview(titleLabel)
        self.addSubview(underlineView)

        NSLayoutConstraint.activate([
            selectedImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            selectedImageView.widthAnchor.constraint(equalToConstant: 16),
            selectedImageView.heightAnchor.constraint(equalToConstant: 16),
            selectedImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            titleLabel.leftAnchor.constraint(equalTo: selectedImageView.rightAnchor, constant: 12),
            titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            underlineView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            underlineView.leftAnchor.constraint(equalTo: self.leftAnchor),
            underlineView.rightAnchor.constraint(equalTo: self.rightAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: 1)
        ])

        self.addTarget(self, action: #selector(viewDidTap), for: .touchUpInside)
    }

    @objc private func viewDidTap() {
        delegate?.itemSelectedPopupViewDidSelected(self)
    }
}

protocol SelectItemPopupDelegate: AnyObject {
    func selectItemPopup(_ view: SelectItemPopup, didSelect index: Int)
    func selectItemPopupGetText(_ view: SelectItemPopup, index: Int) -> String
    func selectItemPopupGetNumberItems(_ view: SelectItemPopup) -> Int
    func selectItemPopupGetSelectedIndex(_ view: SelectItemPopup) -> Int
}

class SelectItemPopup: UIView {
    static func show(title: String, delegate: SelectItemPopupDelegate?, tag: Int) {
        let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow})!

        let view = SelectItemPopup.loadView(fromNib: "SelectItemPopup")!
        view.tag = tag
        view.delegate = delegate
        view.title = title
        view.buildUI()

        view.alpha = 0
        window.addSubview(view)
        view.fitSuperviewConstraint()
        view.superview?.layoutIfNeeded()
        UIView.animate(withDuration: 0.25) {
            view.alpha = 1
        }
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!

    weak var delegate: SelectItemPopupDelegate?
    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }

    // MARK: - Action
    @IBAction func closeButtonDidTap(_ sender: Any) {
        self.dismiss()
    }

    // MARK: - Helper
    private func dismiss() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }

    func buildUI() {
        stackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
        for index in 0 ..< (delegate?.selectItemPopupGetNumberItems(self) ?? 0) {
            let itemView = ItemSelectedPopupView(index: index)
            itemView.delegate = self
            itemView.isSelect = delegate?.selectItemPopupGetSelectedIndex(self) == index
            itemView.text = delegate?.selectItemPopupGetText(self, index: index) ?? ""
            itemView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(itemView)
            NSLayoutConstraint.activate([
                itemView.leftAnchor.constraint(equalTo: stackView.leftAnchor),
                itemView.rightAnchor.constraint(equalTo: stackView.rightAnchor),
                itemView.heightAnchor.constraint(equalToConstant: 48)
            ])
        }
    }
}

// MARK: - ItemSelectedPopupViewDelegate
extension SelectItemPopup: ItemSelectedPopupViewDelegate {
    func itemSelectedPopupViewDidSelected(_ view: ItemSelectedPopupView) {
        delegate?.selectItemPopup(self, didSelect: view.index)
        self.dismiss()
    }
}
