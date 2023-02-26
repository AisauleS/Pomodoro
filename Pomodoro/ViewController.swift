//
//  ViewController.swift
//  Pomodoro
//
//  Created by Aisaule Sibatova on 25.02.2023.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
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
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .gray()
        button.configuration?.baseBackgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 0.5)
        button.configuration?.image = UIImage(named: "stop")
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let shapeView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Base")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
       var timer = Timer()
       var isTimerStarted = false
       var time = 25
    let shapeLayer = CAShapeLayer()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setLayout()
        animationCircular()
    }
    
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           self.animationCircular()
       }

    @objc private func startButtonTapped() {
            cancelButton.isEnabled = true
            cancelButton.alpha = 2.0
            basicAnimation()

            if !isTimerStarted{
                
                startTimer()
                isTimerStarted = true
                startButton.configuration?.image = UIImage(named: "pause")
                
            }else {
                timer.invalidate()
                isTimerStarted = false
                startButton.configuration?.image = UIImage(named: "play")
            }
        }
        

    @objc private func cancelButtonTapped() {
            cancelButton.isEnabled = false
        cancelButton.alpha = 1.0
            timer.invalidate()
            time = 25
            isTimerStarted = false
            timeLabel.text = "00:25"
        startButton.configuration?.image = UIImage(named: "play")
        }
        
        func startTimer(){
//            basicAnimation()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        }
    
  
        
       @objc func updateTimer(){
   if time == 0 {
       startButton.configuration?.image = UIImage(named: "play")
       modeLabel.text = "Rest Time"
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
    
    func animationCircular() {
        
        let center = CGPoint(x: shapeView.frame.width / 2, y: shapeView.frame.height / 2)
        
        let endAngle = (-CGFloat.pi / 2)
        let startAngle = 2 * CGFloat.pi + endAngle
        
        let circularPath = UIBezierPath(arcCenter: center, radius: 120, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.lineWidth = 5
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 1
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.strokeColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
        shapeView.layer.addSublayer(shapeLayer)
    }
    
    
    func basicAnimation() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 0
        basicAnimation.duration = CFTimeInterval(time)
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = true
        shapeLayer.add(basicAnimation, forKey: "basicAnimation")
    }
        
    private func setLayout() {
           
           [modeLabel, timeLabel, shapeView, buttonsStackView].forEach {
               view.addSubview($0)
           }
       
        
        modeLabel.snp.makeConstraints {make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
        }

           timeLabel.snp.makeConstraints {make in
               make.centerX.equalToSuperview()
               make.top.equalToSuperview().offset(270)           }
        
        shapeView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(180)
            make.centerX.equalToSuperview()
        }
        
        buttonsStackView.snp.makeConstraints {make in
            make.top.equalTo(timeLabel.snp.bottom).offset(158)
            make.leading.trailing.equalToSuperview().inset(100)
            make.size.equalTo(56)
       }
       }
}

