import UIKit

struct ThemeConfig {
    struct Colors {
        static let primary = UIColor(red: 12/255, green: 127/255, blue: 255/255, alpha: 1.0) // #0c7fff
        static let secondary = UIColor(red: 77/255, green: 208/255, blue: 225/255, alpha: 1.0) // #4dd0e1
        static let success = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0) // #4CAF50
        static let error = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1.0) // #f44336
        static let warning = UIColor(red: 255/255, green: 152/255, blue: 0/255, alpha: 1.0) // #FF9800
        static let info = UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1.0) // #2196F3
        
        struct Background {
            static let primary = UIColor(red: 254/255, green: 248/255, blue: 255/255, alpha: 1.0) // #FEF8FF
            static let card = UIColor.white // #ffffff
            static let header = UIColor(red: 254/255, green: 248/255, blue: 255/255, alpha: 1.0) // #FEF8FF
            static let modal = UIColor(red: 27/255, green: 29/255, blue: 38/255, alpha: 1.0) // #1b1d26
            static let gradientStart = UIColor(red: 254/255, green: 248/255, blue: 255/255, alpha: 1.0) // #FEF8FF
            static let gradientEnd = UIColor(red: 240/255, green: 230/255, blue: 255/255, alpha: 1.0) // #F0E6FF
        }
        
        struct Text {
            static let primary = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0) // #333333
            static let secondary = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0) // #666666
            static let light = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0) // #999999
            static let white = UIColor.white // #ffffff
            static let error = UIColor(red: 255/255, green: 68/255, blue: 68/255, alpha: 1.0) // #ff4444
        }
        
        struct Border {
            static let light = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0) // #E0E0E0
            static let medium = UIColor(red: 158/255, green: 158/255, blue: 158/255, alpha: 1.0) // #9E9E9E
            static let dark = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0) // #333333
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
        
        static let fab: [String: Any] = [
            "shadowColor": UIColor(red: 77/255, green: 208/255, blue: 225/255, alpha: 1.0).cgColor, // #4dd0e1
            "shadowOffset": CGSize(width: 0, height: 4),
            "shadowOpacity": 0.6,
            "shadowRadius": 8
        ]
        
        static let button: [String: Any] = [
            "shadowColor": UIColor(red: 12/255, green: 127/255, blue: 255/255, alpha: 1.0).cgColor, // #0c7fff
            "shadowOffset": CGSize(width: 0, height: 4),
            "shadowOpacity": 0.4,
            "shadowRadius": 16
        ]
    }
}