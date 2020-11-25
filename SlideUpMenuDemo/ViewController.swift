//
//  ViewController.swift
//  SlideUpMenuDemo
//
//  Created by 四川 wwgps on 2020/11/25.
//

import UIKit

class ViewController: UIViewController {
    
    var containerView = UIView()
//    var slideUpView = UICollectionView()
    lazy var slideUpView: UICollectionView = {
        let s = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        s.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        s.delegate = self
        return s
    }()
    let slideUpViewHeight: CGFloat = 200
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Slide Up Menu "
        
//        configureHierarchy()
        configureDataSource()
    }

    @IBAction func tap(_ sender: Any) {
        print("onActionTap")
        
        guard let windoS:UIWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,windoS.activationState == .foregroundActive,let window = windoS.windows.first  else { return }
        
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        containerView.frame = view.frame
        window.addSubview(containerView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(slideUpViewTapped))
        containerView.addGestureRecognizer(tap)
        
        containerView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut,animations: {
            self.containerView.alpha = 0.8
        } ,completion:nil )
        
        let screenSize = UIScreen.main.bounds.size
        slideUpView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: slideUpViewHeight)
        window.addSubview(slideUpView)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.containerView.alpha = 0.8
            self.slideUpView.frame = CGRect(x: 0, y: screenSize.height - self.slideUpViewHeight, width: screenSize.width, height: self.slideUpViewHeight)
        }, completion: nil)
    }
    
    @objc func slideUpViewTapped(){
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.containerView.alpha = 0
            self.slideUpView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.slideUpViewHeight)
        }, completion: nil)
    }
}

extension ViewController{
    private func createLayout() -> UICollectionViewLayout{
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension ViewController{
//    private func configureHierarchy() {
//        slideUpView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
//        slideUpView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        slideUpView.delegate = self
//    }
    
    private func configureDataSource(){
        let cellRegistration = UICollectionView.CellRegistration<CustomListCell,Item> { (cell, indexPath, item) in
            cell.updateWithItem(item)
            cell.accessories = [.disclosureIndicator()]
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: slideUpView) { (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        // inital data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Item.all)
        dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
    }
}

extension ViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

private enum Section: Hashable {
    case main
}

private struct Category: Hashable {
    let icon: UIImage?
    let name: String?
    
    static let music = Category(icon: UIImage(systemName: "music.mic"), name: "Music")
    static let transportation = Category(icon: UIImage(systemName: "car"), name: "Transportation")
    static let weather = Category(icon: UIImage(systemName: "cloud.rain"), name: "Weather")
}

private struct Item: Hashable {
    let category: Category
    let image: UIImage?
    let title: String?
    let description: String?
    init(category: Category, imageName: String? = nil, title: String? = nil , description: String? = nil) {
        self.category = category
        if let systemName = imageName {
            self.image = UIImage(systemName: systemName)
        } else {
            self.image = nil
        }
        self.title = title
        self.description = description
    }
    
    private let identifier = UUID()
    
    static let all = [
        Item(category: .music, imageName: "headphones", title: "Headphones",
             description: "A portable pair of earphones that are used to listen to music and other forms of audio."),
        Item(category: .music, imageName: "hifispeaker.fill", title: "Loudspeaker",
             description: "A device used to reproduce sound by converting electrical impulses into audio waves."),
        Item(category: .transportation, imageName: "airplane", title: "Plane",
             description: "A commercial airliner used for long distance travel.")
    ]
}

// Declare a custom key for a custom `item` property.
fileprivate extension UIConfigurationStateCustomKey {
    static let item = UIConfigurationStateCustomKey("com.apple.ItemListCell.item")
}

// Declare an extension on the cell state struct to provide a typed property for this custom state.
private extension UICellConfigurationState {
    var item: Item? {
        set { self[.item] = newValue }
        get { return self[.item] as? Item }
    }
}

private class ItemListCell: UICollectionViewListCell {
    private var item: Item? = nil
    
    func updateWithItem(_ newItem: Item) {
        guard item != newItem else { return }
        item = newItem
        setNeedsUpdateConfiguration()
    }
    
    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.item = self.item
        return state
    }
}

private class CustomListCell: ItemListCell{
    private func defaultListContentConfiguration() -> UIListContentConfiguration{
        return .subtitleCell()
    }
    
    private lazy var listContentView = UIListContentView(configuration: defaultContentConfiguration())
    
    private let categoryIconView = UIImageView()
    private let categoryLabel = UILabel()
    private var customViewConstraints: (categoryLabelLeading: NSLayoutConstraint,
                                        categoryLabelTrailing: NSLayoutConstraint,
                                        categoryIconTrailing: NSLayoutConstraint)?
    
    private func setupViewsIfNeeded(){
        guard customViewConstraints == nil  else {return}
        
        contentView.addSubview(listContentView)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(categoryIconView)
        listContentView.translatesAutoresizingMaskIntoConstraints = false
        let defaultHorizontalCompressionResistance = listContentView.contentCompressionResistancePriority(for: .horizontal)
        // 值越小 宽度不够的情况下，会被压缩；在默认值情况下，若宽度不够时，先被addSubview的值越小
        listContentView.setContentCompressionResistancePriority(defaultHorizontalCompressionResistance - 1, for: .horizontal)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryIconView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = (
            categoryLabelLeading: categoryLabel.leadingAnchor.constraint(greaterThanOrEqualTo: listContentView.trailingAnchor),
            categoryLabelTrailing: categoryIconView.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor),
            categoryIconTrailing: contentView.trailingAnchor.constraint(equalTo: categoryIconView.trailingAnchor)
        )
        
        NSLayoutConstraint.activate([
            listContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            listContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            listContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryIconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            constraints.categoryLabelLeading,
            constraints.categoryLabelTrailing,
            constraints.categoryIconTrailing
        ])
        customViewConstraints = constraints

    }
    
    private var separatorConstraint: NSLayoutConstraint?
    private func updateSeparatorConstraint() {
        guard let textLayoutGuide = listContentView.textLayoutGuide else {return}
        if let existingConstraint = separatorConstraint, existingConstraint.isActive {return}
        let constraint = separatorLayoutGuide.leadingAnchor.constraint(equalTo: textLayoutGuide.leadingAnchor)
        constraint.isActive = true
        separatorConstraint = constraint
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        setupViewsIfNeeded()
        
        var content = defaultListContentConfiguration().updated(for: state)
        content.imageProperties.preferredSymbolConfiguration = .init(font: content.textProperties.font, scale: .large)
        content.image = state.item?.image
        content.text = state.item?.title
        content.secondaryText = state.item?.description
        content.axesPreservingSuperviewLayoutMargins = []
        listContentView.configuration = content
        
        // Get the list value cell configuration for the current state, which we'll use to obtain the system default
        // styling and metrics to copy to our custom views.
        
        let valueCongiguation = UIListContentConfiguration.valueCell().updated(for: state)
        
        // Configure custom image view for the category icon, copying some of the styling from the value cell configuration.
        categoryIconView.image = state.item?.category.icon
        categoryIconView.tintColor = valueCongiguation.imageProperties.resolvedTintColor(for: tintColor)
        categoryIconView.preferredSymbolConfiguration = .init(font: valueCongiguation.secondaryTextProperties.font, scale: .small)
        
        // Configure custom label for the category name, copying some of the styling from the value cell configuration.
        
        categoryLabel.text = state.item?.category.name
        categoryLabel.textColor = valueCongiguation.secondaryTextProperties.color
        categoryLabel.font = valueCongiguation.secondaryTextProperties.font
        categoryLabel.adjustsFontForContentSizeCategory = valueCongiguation.secondaryTextProperties.adjustsFontForContentSizeCategory
        
        // Update some of the constraints for our custom views using the system default metrics from the configurations.
        customViewConstraints?.categoryLabelLeading.constant = content.directionalLayoutMargins.trailing
        customViewConstraints?.categoryLabelTrailing.constant = content.textToSecondaryTextHorizontalPadding
        customViewConstraints?.categoryIconTrailing.constant = content.directionalLayoutMargins.trailing
        updateSeparatorConstraint()
    }
}
