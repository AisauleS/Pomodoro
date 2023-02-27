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
    var isWorkTimeStarted = false
    var time = 25
    let shapeLayer = CAShapeLayer()
    
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
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 0.5)
        button.configuration?.image = UIImage(systemName: "play.circle")
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 0.5)
        button.configuration?.image = UIImage(systemName: "stop.circle")
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 0.5)
        button.configuration?.image = UIImage(systemName: "repeat.circle")
        button.imageView?.tintColor = .lightGray
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
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
        stackView.addArrangedSubview(resetButton)
        return stackView
    }()
    
    private let shapeView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Base")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    @objc private func startButtonTapped() {
        cancelButton.isEnabled = true
        cancelButton.alpha = 2.0
        
        if !isTimerStarted{
            startResuneAnimation()
            startTimer()
            isAnimationStarted = true
            isTimerStarted = true
            startButton.configuration?.image = UIImage(systemName: "pause.circle")
            
        } else {
            isTimerStarted = false
            pauseAnimation()
            timer.invalidate()
            isTimerStarted = false
            startButton.configuration?.image = UIImage(systemName: "play.circle")
        }
    }
    
    @objc private func cancelButtonTapped() {
        stopAnimation()
        cancelButton.isEnabled = false
        cancelButton.alpha = 1.0
        timer.invalidate()
        time = 25
        isTimerStarted = false
        timeLabel.text = "00:25"
        startButton.configuration?.image = UIImage(systemName: "play.circle")
    }
    
    @objc private func resetButtonTapped() {
        stopAnimation()
        timer.invalidate()
        time = 25
        isTimerStarted = false
        modeLabel.text = "Focus time"
        modeLabel.textColor = .orange
        timeLabel.text = "00:25"
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        if time<1 {
            cancelButton.isEnabled = false
            startButton.configuration?.image = UIImage(systemName: "play.circle")
            timer.invalidate()
            modeLabel.text = "Break Time"
            modeLabel.textColor = .green
            resetAnimation()
            timer.invalidate()
            time = 5
            isTimerStarted = false
            isWorkTimeStarted = false
        }
        else { time -= 1}
        timeLabel.text = formatTime()
    }
    
    func formatTime()->String{
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func startResuneAnimation() {
        if !isAnimationStarted{
            startAnimation()
        } else {
            resumeAnimation()
        }
    }
    
    func startAnimation() {
        resetAnimation()
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.fromValue = 1
        basicAnimation.toValue = 0
        basicAnimation.duration = CFTimeInterval(time)
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        basicAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        shapeLayer.strokeEnd = 1
        shapeLayer.add(basicAnimation, forKey: "basicAnimation")
    }
    
    func pauseAnimation() {
        let pausedTime = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        shapeLayer.speed = 0.0
        shapeLayer.timeOffset = pausedTime
    }
    
    func resumeAnimation(){
        let pausedTime = shapeLayer.timeOffset
        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0;
        let timeSincePause: CFTimeInterval = shapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        shapeLayer.beginTime = timeSincePause;
    }
    
    func resetAnimation() {
        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0;
        shapeLayer.strokeEnd = 0.0
        isAnimationStarted = false
    }
    
    func stopAnimation() {
        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0;
        shapeLayer.strokeEnd = 0.0
        shapeLayer.removeAllAnimations()
        isAnimationStarted = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupHierarchy()
        setLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.animationCircular()
    }
    
    private func setupHierarchy() {
        [modeLabel, timeLabel, shapeView, buttonsStackView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setLayout() {
        
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
            make.leading.trailing.equalToSuperview().inset(80)
        }
    }
}

