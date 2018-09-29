//
//  CameraCaptureButton.swift
//  CamChat
//
//  Created by Patrick Hanna on 9/23/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//



import HelpKit



private class CameraCaptureRingView: UIView{
    
    init(){
        super.init(frame: CGRect.zero)
        backgroundColor = .clear
        isUserInteractionEnabled = false
        layer.addSublayer(whiteRing)
        layer.addSublayer(redRing)
    }
    
    fileprivate lazy var whiteRing = getNewRing(color: .white)
    private lazy var redRing: CAShapeLayer = {
        let x = getNewRing(color: .red)
        x.strokeEnd = 0
        x.lineWidth = 6.25
        return x
    }()
    
    private let strokeWidth: CGFloat = 6
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sizeAndPosition(ring: whiteRing)
        sizeAndPosition(ring: redRing)
    }
    
    
    private func getNewRing(color: UIColor) -> CAShapeLayer{
        let x = CAShapeLayer()
        x.fillColor = UIColor.clear.cgColor
        x.strokeColor = color.cgColor
        x.lineWidth = strokeWidth
        return x
    }
    
    private func sizeAndPosition(ring: CAShapeLayer){
        ring.frame = self.bounds
        let radius = (self.bounds.width / 2) - strokeWidth.half
        let path = UIBezierPath(arcCenter: self.centerInBounds, radius: radius, startAngle: -(CGFloat.pi.half), endAngle: 2 * CGFloat.pi, clockwise: true)
        ring.path = path.cgPath
    }
    
    private let animatorKey = "greatestAnimationEver"
    
    
    func startAnimatingRedRing(){
        let animator = CABasicAnimation(keyPath: "strokeEnd")
        animator.fillMode = CAMediaTimingFillMode.forwards
        animator.duration = 10
        animator.toValue = 0.8
        animator.isAdditive = true
        animator.repeatCount = Float.greatestFiniteMagnitude
        animator.isRemovedOnCompletion = false
        redRing.add(animator, forKey: animatorKey)
    }
    
    
    
    func stopAnimatingRedRing(){
        redRing.removeAnimation(forKey: animatorKey)
        redRing.strokeEnd = 0
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}














protocol CameraCaptureButtonDelegate: class{
    func respondToTap()
    func respondToLongPress(event: CameraCaptureButton.LongPressEvent)
    func shouldRespondToLongPressGesture() -> Bool
}


class CameraCaptureButton: UIView{
    
    
    
    enum LongPressEvent{ case began, ended }

    
    private var ringView = CameraCaptureRingView()
    
    private var redCircle: UIView = {
        let x = HKCircleView()
        x.backgroundColor = .red
        x.isUserInteractionEnabled = false
        return x
    }()
    
    func changeRingTintColor(to color: UIColor){
        ringView.whiteRing.strokeColor = color.cgColor
    }
    
    private weak var delegate: CameraCaptureButtonDelegate?
    
    init(delegate: CameraCaptureButtonDelegate){
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        setUpViews()
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(respondToLongTapGesture(gesture:)))
        addGestureRecognizer(gesture)
        gesture.minimumPressDuration = 0.3
        gesture.stopInterferingWithTouchesInView()
        
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(respondToTapGesture(gesture:)))
        addGestureRecognizer(gesture2)
        
    }
    
    @objc private func respondToTapGesture(gesture: UITapGestureRecognizer){
        delegate?.respondToTap()
    }
    
    @objc private func respondToLongTapGesture(gesture: UILongPressGestureRecognizer){
        guard let delegate = delegate else {return}
        
        
        if gesture.state == .began {
            if delegate.shouldRespondToLongPressGesture().isFalse{ return }
            delegate.respondToLongPress(event: .began)
            self.startAnimating()
        } else if gesture.state == .ended{
            if delegate.shouldRespondToLongPressGesture().isFalse{ return }
            delegate.respondToLongPress(event: .ended)
            self.stopAnimating()
        }
        
    }
    

    
    
    
    
    
    private func setUpViews(){
        self.ringView.pinAllSides(addTo: self, pinTo: self)
        redCircle.pin(addTo: self, anchors: [.centerX: centerXAnchor, .centerY: centerYAnchor], constants: [.height: 60, .width: 60])
        redCircle.transform = minRedCircleTransform
    }
    
    private let minRedCircleTransform = CGAffineTransform(scaleX: 0.0000001, y: 0.0000001)

    private func startAnimating(){
        UIView.animate(withDuration: 1, delay: 0.2, options: .curveEaseOut, animations: {
            self.ringView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.redCircle.transform = CGAffineTransform.identity
        }, completion: nil)
        self.ringView.startAnimatingRedRing()
    }
    

    
    private func stopAnimating(){
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            self.ringView.transform = CGAffineTransform.identity
            self.redCircle.transform = self.minRedCircleTransform
        }, completion: nil)
        self.ringView.stopAnimatingRedRing()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}
