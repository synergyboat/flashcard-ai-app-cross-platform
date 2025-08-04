import UIKit

protocol FlashcardViewDelegate: AnyObject {
    func flashcardDidSwipeLeft(_ flashcardView: FlashcardView)
    func flashcardDidSwipeRight(_ flashcardView: FlashcardView)
}

class FlashcardView: UIView {
    
    weak var delegate: FlashcardViewDelegate?
    
    private let contentView = UIView()
    private let questionLabel = UILabel()
    private let answerLabel = UILabel()
    private let flipIndicatorLabel = UILabel()
    
    private var isShowingAnswer = false
    private var flashcard: Flashcard?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupGestures()
    }
    
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 8
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(questionLabel)
        contentView.addSubview(answerLabel)
        contentView.addSubview(flipIndicatorLabel)
        
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        flipIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Question label
        questionLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        questionLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        questionLabel.textAlignment = .center
        questionLabel.numberOfLines = 0
        
        // Answer label
        answerLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        answerLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        answerLabel.textAlignment = .center
        answerLabel.numberOfLines = 0
        answerLabel.alpha = 0
        
        // Flip indicator
        flipIndicatorLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        flipIndicatorLabel.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
        flipIndicatorLabel.textAlignment = .center
        flipIndicatorLabel.text = "Tap to reveal answer"
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            questionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            questionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            answerLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            answerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            answerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            flipIndicatorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            flipIndicatorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    @objc private func handleTap() {
        flipCard()
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        
        switch gesture.state {
        case .changed:
            let rotation = translation.x / bounds.width * 0.25
            transform = CGAffineTransform(rotationAngle: rotation).translatedBy(x: translation.x * 0.5, y: 0)
            
        case .ended:
            let threshold: CGFloat = 80
            
            if abs(translation.x) > threshold || abs(velocity.x) > 500 {
                if translation.x > 0 {
                    // Swipe right
                    animateSwipeRight()
                } else {
                    // Swipe left
                    animateSwipeLeft()
                }
            } else {
                // Return to center
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: []) {
                    self.transform = .identity
                }
            }
            
        default:
            break
        }
    }
    
    private func flipCard() {
        UIView.transition(with: contentView, duration: 0.6, options: .transitionFlipFromRight) {
            if self.isShowingAnswer {
                self.showQuestion()
            } else {
                self.showAnswer()
            }
        }
    }
    
    private func showQuestion() {
        answerLabel.alpha = 0
        questionLabel.alpha = 1
        flipIndicatorLabel.text = "Tap to reveal answer"
        isShowingAnswer = false
    }
    
    private func showAnswer() {
        questionLabel.alpha = 0.5
        answerLabel.alpha = 1
        flipIndicatorLabel.text = "Tap to show question"
        isShowingAnswer = true
    }
    
    private func animateSwipeLeft() {
        UIView.animate(withDuration: 0.3, animations: {
            self.center.x -= self.bounds.width
            self.transform = CGAffineTransform(rotationAngle: -0.5)
        }) { _ in
            self.delegate?.flashcardDidSwipeLeft(self)
        }
    }
    
    private func animateSwipeRight() {
        UIView.animate(withDuration: 0.3, animations: {
            self.center.x += self.bounds.width
            self.transform = CGAffineTransform(rotationAngle: 0.5)
        }) { _ in
            self.delegate?.flashcardDidSwipeRight(self)
        }
    }
    
    func configure(with flashcard: Flashcard) {
        self.flashcard = flashcard
        questionLabel.text = flashcard.question
        answerLabel.text = flashcard.answer
        showQuestion()
    }
    
    func resetPosition() {
        transform = .identity
        center = superview?.center ?? center
    }
} 