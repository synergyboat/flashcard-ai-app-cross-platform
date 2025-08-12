import UIKit

class GradientButton: UIButton {
    
    let gradientLayer = CAGradientLayer()
    
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
        
        // Apply padding without using deprecated contentEdgeInsets on iOS 15+
        if #available(iOS 15.0, *) {
            // Avoid setting UIButton.Configuration to preserve custom gradient/background.
            // Padding is handled via intrinsicContentSize override below.
        } else {
            contentEdgeInsets = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
        }
        
        // Handle image positioning for all iOS versions
        imageView?.contentMode = .scaleAspectFit
        
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
        
        // Handle image and title spacing for iOS 15+ without deprecated edge insets
        if let imageView = imageView, let titleLabel = titleLabel,
           let image = imageView.image, !titleLabel.text.isNilOrEmpty {
            let spacing: CGFloat = 8
            
            // Position image on the left and title on the right with spacing
            let totalWidth = image.size.width + titleLabel.intrinsicContentSize.width + spacing
            let imageX = (bounds.width - totalWidth) / 2
            let titleX = imageX + image.size.width + spacing
            
            imageView.frame = CGRect(
                x: imageX,
                y: (bounds.height - image.size.height) / 2,
                width: image.size.width,
                height: image.size.height
            )
            
            titleLabel.frame = CGRect(
                x: titleX,
                y: (bounds.height - titleLabel.intrinsicContentSize.height) / 2,
                width: titleLabel.intrinsicContentSize.width,
                height: titleLabel.intrinsicContentSize.height
            )
        }
    }
    
    // Provide padding-compatible sizing for iOS 15+ without UIButton.Configuration
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        // Mirror the previous 16/32 padding used via contentEdgeInsets
        size.width += 32 * 2
        size.height += 16 * 2
        return size
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

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        return self?.isEmpty != false
    }
}