import Foundation

struct AppConfig {
    struct ScreenTitles {
        static let home = "Flashcard AI"
        static let deckDetails = "Deck Details"
        static let aiGenerate = "AI Generate Deck"
        static let study = "Study"
    }
    
    struct CardLimits {
        static let min = 1
        static let max = 20
        static let defaultValue = 5
    }
    
    struct Animations {
        static let flipTension: Float = 300
        static let flipFriction: Float = 10
        static let swipeDuration: TimeInterval = 0.3
        static let cardHeight: CGFloat = 400
        static let swipeThreshold: CGFloat = 150
    }
    
    struct UI {
        struct BorderRadius {
            static let small: CGFloat = 8
            static let medium: CGFloat = 12
            static let large: CGFloat = 16
        }
        
        struct Spacing {
            static let small: CGFloat = 8
            static let medium: CGFloat = 16
            static let large: CGFloat = 24
            static let containerPadding: CGFloat = 16
        }
        
        struct Dimensions {
            static let fabSize: CGFloat = 56
            static let buttonHeight: CGFloat = 48
        }
    }
}