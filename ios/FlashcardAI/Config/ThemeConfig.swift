import UIKit

struct ThemeConfig {
    struct Colors {
        static let primary = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0)
        static let secondary = UIColor(red: 108/255, green: 117/255, blue: 125/255, alpha: 1.0)
        static let success = UIColor(red: 40/255, green: 167/255, blue: 69/255, alpha: 1.0)
        static let error = UIColor(red: 220/255, green: 53/255, blue: 69/255, alpha: 1.0)
        
        struct Background {
            static let primary = UIColor(red: 254/255, green: 248/255, blue: 255/255, alpha: 1.0) // #FEF8FF
            static let card = UIColor.white
            static let cardLight = UIColor(red: 248/255, green: 249/255, blue: 250/255, alpha: 1.0)
            static let header = UIColor.white
            static let gradientStart = UIColor(red: 254/255, green: 248/255, blue: 255/255, alpha: 1.0)
            static let gradientEnd = UIColor(red: 254/255, green: 248/255, blue: 255/255, alpha: 1.0)
        }
        
        struct Text {
            static let primary = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0) // #333333
            static let secondary = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0) // #666666
            static let muted = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0) // #999999
        }
        
        struct Border {
            static let light = UIColor(red: 225/255, green: 229/255, blue: 233/255, alpha: 1.0)
            static let medium = UIColor(red: 222/255, green: 226/255, blue: 230/255, alpha: 1.0)
        }
    }
    
    struct Typography {
        struct FontSize {
            static let small: CGFloat = 12
            static let medium: CGFloat = 14
            static let large: CGFloat = 16
            static let xlarge: CGFloat = 18
            static let xxlarge: CGFloat = 20
            static let title: CGFloat = 24
        }
        
        struct FontWeight {
            static let regular = UIFont.Weight.regular
            static let medium = UIFont.Weight.medium
            static let semibold = UIFont.Weight.semibold
            static let bold = UIFont.Weight.bold
        }
    }
    
    struct Shadows {
        static let card: [String: Any] = [
            "shadowColor": UIColor.black.cgColor,
            "shadowOffset": CGSize(width: 0, height: 2),
            "shadowOpacity": 0.1,
            "shadowRadius": 4
        ]
        
        static let cardElevated: [String: Any] = [
            "shadowColor": UIColor.black.cgColor,
            "shadowOffset": CGSize(width: 0, height: 4),
            "shadowOpacity": 0.15,
            "shadowRadius": 8
        ]
        
        static let fab: [String: Any] = [
            "shadowColor": UIColor.black.cgColor,
            "shadowOffset": CGSize(width: 0, height: 4),
            "shadowOpacity": 0.3,
            "shadowRadius": 8
        ]
    }
}