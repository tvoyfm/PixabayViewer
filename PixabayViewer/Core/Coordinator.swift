import UIKit

// MARK: - Base Coordinator Protocol

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    
    func start()
}

// MARK: - Search Coordinator Protocol

protocol SearchCoordinator: Coordinator {
    func showImagePreview(for imagePair: ImagePair, selectedIndex: Int)
}

// MARK: - Search Coordinator Implementation

final class PixabaySearchCoordinator: SearchCoordinator {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let searchVC = SearchVC(coordinator: self)
        navigationController.pushViewController(searchVC, animated: false)
    }
    
    func showImagePreview(for imagePair: ImagePair, selectedIndex: Int) {
        let previewVC = ImagePreviewVC(imagePair: imagePair, selectedIndex: selectedIndex)
        navigationController.present(previewVC, animated: true)
    }
} 