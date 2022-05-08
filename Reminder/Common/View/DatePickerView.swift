//
//  DatePickerView.swift
//  Reminder
//
//  Created by Linh Nguyen Duc on 28/02/2022.
//

import UIKit

protocol DatePickerViewDelegate: AnyObject {
    func datePickerView(_ view: DatePickerView, didSelectDate date: Date)
}

class DatePickerView: UIViewController {
    weak var delegate: DatePickerViewDelegate?
    var pickerMode: UIDatePicker.Mode = .date {
        didSet {
            datePicker.datePickerMode = pickerMode
        }
    }
    
    var date: Date! {
        didSet {
            datePicker.date = date
        }
    }
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewDidTap(gesure:)))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            fatalError("date picker only support ios version 13.4 or more")
        }
        
        datePicker.datePickerMode = pickerMode
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private lazy var containerPickerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0xF3F7FF)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(doneButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(currentDate: Date) {
        super.init(nibName: nil, bundle: nil)
        datePicker.date = currentDate
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildUI()
    }
    
    // MARK: - Build UI
    private func buildUI() {
        self.view.addSubview(backgroundView)
        self.view.addSubview(containerPickerView)
        containerPickerView.addSubview(datePicker)
        containerPickerView.addSubview(cancelButton)
        containerPickerView.addSubview(doneButton)
        
        backgroundView.fitSuperviewConstraint()
        
        doneButton.sizeToFit()
        cancelButton.sizeToFit()
        
        NSLayoutConstraint.activate([
            containerPickerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            containerPickerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            containerPickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            datePicker.leftAnchor.constraint(equalTo: containerPickerView.leftAnchor),
            datePicker.rightAnchor.constraint(equalTo: containerPickerView.rightAnchor),
            datePicker.bottomAnchor.constraint(equalTo: containerPickerView.bottomAnchor),
            datePicker.topAnchor.constraint(equalTo: cancelButton.bottomAnchor),
           
            cancelButton.topAnchor.constraint(equalTo: containerPickerView.topAnchor, constant: 5),
            cancelButton.leftAnchor.constraint(equalTo: containerPickerView.leftAnchor, constant: 12),
            
            doneButton.topAnchor.constraint(equalTo: containerPickerView.topAnchor, constant: 5),
            doneButton.rightAnchor.constraint(equalTo: containerPickerView.rightAnchor, constant: -12),
        ])
    }
    
    // MARK: - Action
    @objc private func backgroundViewDidTap(gesure: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func cancelButtonDidTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneButtonDidTap() {
        delegate?.datePickerView(self, didSelectDate: datePicker.date)
        self.dismiss(animated: true, completion: nil)
    }
}
