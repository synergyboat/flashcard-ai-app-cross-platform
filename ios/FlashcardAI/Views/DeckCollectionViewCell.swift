import UIKit

class DeckCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "DeckCollectionViewCell"
    
    private let stackContainer = UIView()
    private let backCard1 = UIView()
    private let backCard2 = UIView()
    private let frontCard = UIView()
    private let nameLabel = UILabel()
    private let cardCountLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // Edit button overlay
    private let editButtonContainer = UIView()
    private let editButton = UIButton(type: .system)
    
    // Animation properties
    private var shakingAnimationTimer: Timer?
    private var isShaking = false
    
    // Callback for edit button tap
    var onEditTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(stackContainer)
        stackContainer.addSubview(backCard1)
        stackContainer.addSubview(backCard2)
        stackContainer.addSubview(frontCard)
        frontCard.addSubview(nameLabel)
        frontCard.addSubview(cardCountLabel)
        frontCard.addSubview(descriptionLabel)
        
        // Add edit button overlay (initially hidden)
        contentView.addSubview(editButtonContainer)
        editButtonContainer.addSubview(editButton)
        
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
        backCard1.translatesAutoresizingMaskIntoConstraints = false
        backCard2.translatesAutoresizingMaskIntoConstraints = false
        frontCard.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardCountLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        editButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup stacked cards with gradient and shadows
        setupCardView(backCard1, scale: 0.90, rotation: 0.2, offsetX: 15, offsetY: 0, shadowOpacity: 0.0)
        setupCardView(backCard2, scale: 0.95, rotation: -0.2, offsetX: -18, offsetY: 10, shadowOpacity: 0.15)
        setupCardView(frontCard, scale: 1.0, rotation: 0, offsetX: 0, offsetY: 0, shadowOpacity: 0.15)
        
        // Name label
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        nameLabel.numberOfLines = 2
        
        // Card count label
        cardCountLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        cardCountLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        
        // Description label
        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        descriptionLabel.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
        descriptionLabel.numberOfLines = 2
        
        // Edit button setup
        setupEditButton()
        
        NSLayoutConstraint.activate([
            stackContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // All cards fill the container - transforms will position them
            backCard1.centerXAnchor.constraint(equalTo: stackContainer.centerXAnchor),
            backCard1.centerYAnchor.constraint(equalTo: stackContainer.centerYAnchor),
            backCard1.widthAnchor.constraint(equalTo: stackContainer.widthAnchor),
            backCard1.heightAnchor.constraint(equalTo: stackContainer.heightAnchor),
            
            backCard2.centerXAnchor.constraint(equalTo: stackContainer.centerXAnchor),
            backCard2.centerYAnchor.constraint(equalTo: stackContainer.centerYAnchor),
            backCard2.widthAnchor.constraint(equalTo: stackContainer.widthAnchor),
            backCard2.heightAnchor.constraint(equalTo: stackContainer.heightAnchor),
            
            frontCard.centerXAnchor.constraint(equalTo: stackContainer.centerXAnchor),
            frontCard.centerYAnchor.constraint(equalTo: stackContainer.centerYAnchor),
            frontCard.widthAnchor.constraint(equalTo: stackContainer.widthAnchor),
            frontCard.heightAnchor.constraint(equalTo: stackContainer.heightAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: frontCard.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: frontCard.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: frontCard.trailingAnchor, constant: -20),
            
            cardCountLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            cardCountLabel.leadingAnchor.constraint(equalTo: frontCard.leadingAnchor, constant: 20),
            cardCountLabel.trailingAnchor.constraint(equalTo: frontCard.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: cardCountLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: frontCard.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: frontCard.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: frontCard.bottomAnchor, constant: -20),
            
            // Edit button constraints
            editButtonContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            editButtonContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            editButtonContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            editButtonContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            editButton.topAnchor.constraint(equalTo: editButtonContainer.topAnchor, constant: -6),
            editButton.trailingAnchor.constraint(equalTo: editButtonContainer.trailingAnchor, constant: 12),
            editButton.widthAnchor.constraint(equalToConstant: 42),
            editButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
    
    private func setupCardView(_ cardView: UIView, scale: CGFloat, rotation: CGFloat, offsetX: CGFloat, offsetY: CGFloat, shadowOpacity: Float) {
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 32
        cardView.layer.borderWidth = 0.5
        cardView.layer.borderColor = UIColor.gray.withAlphaComponent(0.4).cgColor
        
        // Add shadow
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowOpacity = shadowOpacity
        cardView.layer.shadowRadius = 8
        cardView.layer.masksToBounds = false
        
        // Apply transforms
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: scale, y: scale)
        transform = transform.rotated(by: rotation)
        transform = transform.translatedBy(x: offsetX, y: offsetY)
        cardView.transform = transform
    }
    
    private func setupEditButton() {
        // Edit button container (initially hidden)
        editButtonContainer.isHidden = true
        editButtonContainer.backgroundColor = .clear
        
        // Edit button styling to match Flutter design
        editButton.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        editButton.tintColor = UIColor.black.withAlphaComponent(0.7)
        editButton.backgroundColor = .white
        editButton.layer.cornerRadius = 21
        editButton.layer.shadowColor = UIColor.black.cgColor
        editButton.layer.shadowOffset = CGSize(width: -2, height: 2)
        editButton.layer.shadowOpacity = 0.1
        editButton.layer.shadowRadius = 8
        editButton.layer.masksToBounds = false
        
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    
    @objc private func editButtonTapped() {
        onEditTapped?()
    }
    
    func configure(with deck: Deck) {
        nameLabel.text = deck.name
        
        let cardCount = deck.flashcardCount ?? 0
        cardCountLabel.text = "\(cardCount) card\(cardCount != 1 ? "s" : "")"
        
        if !deck.description.isEmpty {
            descriptionLabel.text = deck.description
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        cardCountLabel.text = nil
        descriptionLabel.text = nil
        descriptionLabel.isHidden = false
        stopShaking()
    }
    
    // MARK: - Animation Methods
    func startShaking() {
        guard !isShaking else { return }
        isShaking = true
        
        // Show edit button
        editButtonContainer.isHidden = false
        
        shakingAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: [.autoreverse], animations: {
                self.stackContainer.transform = CGAffineTransform(rotationAngle: 0.04)
            }) { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.stackContainer.transform = CGAffineTransform(rotationAngle: -0.04)
                })
            }
        }
    }
    
    func stopShaking() {
        guard isShaking else { return }
        isShaking = false
        shakingAnimationTimer?.invalidate()
        shakingAnimationTimer = nil
        
        // Hide edit button
        editButtonContainer.isHidden = true
        
        UIView.animate(withDuration: 0.1) {
            self.stackContainer.transform = .identity
        }
    }
} 