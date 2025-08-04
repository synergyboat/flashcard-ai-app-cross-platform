import UIKit

class GradientButton: UIButton {
    
    private let gradientLayer = CAGradientLayer()
    
    var gradientColors: [UIColor] = [
        UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0),
        UIColor(red: 53/255, green: 122/255, blue: 189/255, alpha: 1.0)
    ] {
        didSet {
            updateGradient()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        layer.cornerRadius = 12
        layer.masksToBounds = false
        
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 3.84
        
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        setTitleColor(.white, for: .normal)
        setTitleColor(UIColor(white: 0.4, alpha: 1.0), for: .disabled)
        
        contentEdgeInsets = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
        
        setupGradient()
        updateAppearance()
    }
    
    private func setupGradient() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.cornerRadius = 12
        layer.insertSublayer(gradientLayer, at: 0)
        updateGradient()
    }
    
    private func updateGradient() {
        gradientLayer.colors = gradientColors.map { $0.cgColor }
    }
    
    private func updateAppearance() {
        if isEnabled {
            gradientLayer.colors = gradientColors.map { $0.cgColor }
            alpha = 1.0
        } else {
            gradientLayer.colors = [
                UIColor(white: 0.8, alpha: 1.0).cgColor,
                UIColor(white: 0.6, alpha: 1.0).cgColor
            ]
            alpha = 0.6
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0.8
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.alpha = self.isEnabled ? 1.0 : 0.6
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.alpha = self.isEnabled ? 1.0 : 0.6
        }
    }
} 