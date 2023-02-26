//
//  ViewController.swift
//  Pomodoro
//
//  Created by Aisaule Sibatova on 25.02.2023.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    var timer = Timer()
    var isTimerStarted = false
    var isAnimationStarted = false
    
    var time = 25
    let shapeLayer = CAShapeLayer()
    let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    
    lazy var modeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .orange
        label.text = "Focus time"
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "00:25"
        return label
    }()
    
    lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .gray()
        button.configuration?.baseBackgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 0.5)
        button.configuration?.image = UIImage(named: "play")
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .gray()
        button.configuration?.baseBackgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 0.5)
        button.configuration?.image = UIImage(named: "stop")
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(startButton)
        stackView.addArrangedSubview(cancelButton)
        return stackView
    }()
    
    private let shapeView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Base")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.animationCircular()
    }
    
    @objc private func startButtonTapped() {
        cancelButton.isEnabled = true
        cancelButton.alpha = 2.0
        startAnimation()
        
        if !isTimerStarted{
            startTimer()
            isTimerStarted = true
            startButton.configuration?.image = UIImage(named: "pause")
            
        } else {
            timer.invalidate()
            isTimerStarted = false
            startButton.configuration?.image = UIImage(named: "play")
        }
    }
    
    @objc private func cancelButtonTapped() {
        cancelButton.isEnabled = false
        cancelButton.alpha = 1.0
        resetAnimation()
        timer.invalidate()
        time = 25
        isTimerStarted = false
        timeLabel.text = "00:25"
        startButton.configuration?.image = UIImage(named: "play")
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        if time<1 {
            cancelButton.isEnabled = true
            startButton.configuration?.image = UIImage(named: "play")
            modeLabel.text = "Break Time"
            modeLabel.textColor = .green
            cancelButtonTapped()
            time = 5
        }
        else { time -= 1}
        timeLabel.text = formatTime()
    }
    
    func formatTime()->String{
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func startAnimation() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.fromValue = 1
        basicAnimation.toValue = 0
        basicAnimation.duration = CFTimeInterval(time)
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = true
        basicAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        shapeLayer.strokeEnd = 0
        shapeLayer.add(basicAnimation, forKey: "basicAnimation")
    }
    
    func pauseAnimation() {
        let pausedTime = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        shapeLayer.speed = 0.0
        shapeLayer.timeOffset = pausedTime
    }
    
    func resetAnimation() {
        let pausedTime: CFTimeInterval = shapeLayer.timeOffset
        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        let timeSincePause: CFTimeInterval = shapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        shapeLayer.beginTime = timeSincePause
    }
    
    func animationCircular() {
        let center = CGPoint(x: shapeView.frame.width / 2, y: shapeView.frame.height / 2)
        let endAngle = (-CGFloat.pi / 2)
        let startAngle = 2 * CGFloat.pi + endAngle
        let circularPath = UIBezierPath(arcCenter: center, radius: 120, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        shapeLayer.path = circularPath.cgPath
        shapeLayer.lineWidth = 5
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 1
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.strokeColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
        shapeView.layer.addSublayer(shapeLayer)
    }
    
    private func setLayout() {
        
        [modeLabel, timeLabel, shapeView, buttonsStackView].forEach {
            view.addSubview($0)
        }
        
        modeLabel.snp.makeConstraints {make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(80)
        }
        
        timeLabel.snp.makeConstraints {make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(270)
        }
        
        shapeView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(180)
            make.centerX.equalToSuperview()
        }
        
        buttonsStackView.snp.makeConstraints {make in
            make.top.equalTo(timeLabel.snp.bottom).offset(198)
            make.leading.trailing.equalToSuperview().inset(100)
        }
    }
}

