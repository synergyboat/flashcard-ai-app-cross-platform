import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
//            return
//        }
//        let navigationController = UINavigationController(rootViewController: homeViewController)
        
        let win = UIWindow(windowScene: windowScene)
        let benchmark = BenchmarkViewController()
        benchmark.itemCount = 100            // tweak if you want
        benchmark.iterations = 3
        benchmark.benchmarkType = .scrollPerformance
        
        let navigationController = UINavigationController(rootViewController: benchmark)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        

    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
} 
