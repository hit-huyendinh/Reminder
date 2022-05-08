//
//  PieChartView.swift
//  Reminder
//
//  Created by linhnd99 on 08/03/2022.
//

import UIKit

protocol PieChartViewDataSource: AnyObject {
    func pieChartViewNumberOfItems(_ view: PieChartView) -> Int
    func pieChartView(_ view: PieChartView, valueAt index: Int) -> Int
    func pieChartView(_ view: PieChartView, colorAt index: Int) -> UIColor
}

class PieChartView: UIView {
    var dataSource: PieChartViewDataSource?
    var padding: CGFloat = 32 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var lineWidth: CGFloat = 10 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var title: String! {
        didSet {
            titleLabel.text = title
            titleLabel.sizeToFit()
        }
    }
    
    var subtitle: String! = "%" {
        didSet {
            subtitleLabel.text = subtitle
            subtitleLabel.sizeToFit()
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Nunito.semiboldFont(size: 16)
        label.textColor = UIColor(rgb: 0x212121)
        label.text = title
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Nunito.semiboldFont(size: 12)
        label.textColor = UIColor(rgb: 0x212121)
        label.text = subtitle
        label.textAlignment = .center
        return label
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
        
    // MARK: - Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        self.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            contentView.leftAnchor.constraint(equalTo: contentView.superview!.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: contentView.superview!.rightAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor),
            
            subtitleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            subtitleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Draw
    override func draw(_ rect: CGRect) {
        guard let dataSource = dataSource else {
            return
        }

        let centerPoint = CGPoint(x: rect.width/2, y: rect.height/2)
        var sum = 0
        for index in 0 ..< dataSource.pieChartViewNumberOfItems(self) {
            sum += dataSource.pieChartView(self, valueAt: index)
        }
        
        let radius: CGFloat = rect.width/2 - lineWidth - padding
        if sum == 0 {
            let bezierPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: 0, endAngle: .pi*2, clockwise: false)
            bezierPath.lineWidth = lineWidth
            dataSource.pieChartView(self, colorAt: 2).setStroke()
            bezierPath.stroke()
            return
        }
        
        var currentAngle: CGFloat = -.pi/2
        for index in (0...dataSource.pieChartViewNumberOfItems(self)-1).reversed() {
            let angle = CGFloat(dataSource.pieChartView(self, valueAt: index)) / CGFloat(sum) * CGFloat.pi*2
            if (angle == 0) {
                continue
            }
            
            let bezierPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: currentAngle, endAngle: currentAngle - angle, clockwise: false)
            bezierPath.lineWidth = lineWidth
            dataSource.pieChartView(self, colorAt: index).setStroke()
            bezierPath.stroke()
            
            let dotStartBezierPath = UIBezierPath()
            let startPoint = self.getPoint(centerPoint: centerPoint, radius: radius, angle: currentAngle)
            dotStartBezierPath.addArc(withCenter: startPoint, radius: lineWidth/2, startAngle: 0, endAngle: .pi*2, clockwise: true)
            dotStartBezierPath.lineWidth = 1
            dataSource.pieChartView(self, colorAt: index).setFill()
            dotStartBezierPath.fill()
            
            let dotEndBezierPath = UIBezierPath()
            let endPoint = self.getPoint(centerPoint: centerPoint, radius: radius, angle: currentAngle - angle)
            dotEndBezierPath.addArc(withCenter: endPoint, radius: lineWidth/2, startAngle: 0, endAngle: .pi*2, clockwise: true)
            dotEndBezierPath.lineWidth = 1
            dataSource.pieChartView(self, colorAt: index).setFill()
            dotEndBezierPath.fill()
            
            currentAngle -= angle
        }
    }
    
    private func getPoint(centerPoint: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPoint {
        var point = CGPoint.zero
        point.x = radius * cos(angle) + centerPoint.x
        point.y = radius * sin(angle) + centerPoint.y
        return point
    }
}
