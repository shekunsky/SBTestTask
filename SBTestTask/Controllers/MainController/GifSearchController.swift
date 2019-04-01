//
//  GifSearchController.swift
//  SBTestTask
//
//  Created by Alex2 on 3/30/19.
//  Copyright © 2019 Alex Shekunsky. All rights reserved.
//

import UIKit

internal let kGifSearchCollectionViewCell = "GifSearchCollectionViewCell"

class GifSearchController: UIViewController {
    
    private enum PresentationStyle: String, CaseIterable {
        case table
        case defaultGrid
        
        var buttonImage: UIImage {
            switch self {
            case .table: return #imageLiteral(resourceName: "table")
            case .defaultGrid: return #imageLiteral(resourceName: "grid")
            }
        }
    }
    
    internal var viewModel = GifSearchViewModel()
    internal let searchController: UISearchController = UISearchController(searchResultsController: nil)
    fileprivate let searchContainerView: UIView = UIView(frame: CGRect.zero)
    fileprivate let collectionViewGridLayOut = SwiftyGiphyGridLayout()
    internal lazy var collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewGridLayOut)
    
    internal let loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)
    internal var errorLabel: UILabel = UILabel()
    internal var selectedCell = SwiftyGiphyCollectionViewCell()
    internal var keyboardAdjustConstraint: NSLayoutConstraint!
    
    internal var collectionViewLayout: SwiftyGiphyGridLayout? {
        get {
            return collectionView.collectionViewLayout as? SwiftyGiphyGridLayout
        }
    }
    
    private var selectedStyle: PresentationStyle = .table {
        didSet { updatePresentationStyle() }
    }
    
    
    //MARK: Life Cyсle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupSearchController()
        setupCollectionView()
        setupLabel()
        setupConstraints()
        updatePresentationStyle()
        memoryPerfomance()
        setupNotifications()
        bindViewModel()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        setupSearchController()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if #available(iOS 11, *)
        {
            collectionView.contentInset = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 10.0, right: 0.0)
            collectionView.scrollIndicatorInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 10.0, right: 0.0)
        }
        else
        {
            collectionView.contentInset = UIEdgeInsets.init(top: self.topLayoutGuide.length-UIConstants.searchControllerHeight-10, left: 0.0, bottom: 10.0, right: 0.0)
            collectionView.scrollIndicatorInsets = UIEdgeInsets.init(top: self.topLayoutGuide.length-UIConstants.searchControllerHeight-10, left: 0.0, bottom: 10.0, right: 0.0)
        }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchController.searchBar.frame = searchContainerView.bounds
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        clearCasheFromImages()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: memory perfomance
    private func memoryPerfomance() {
        //memory perfomance for cashe images
        SDImageCache.shared().config.maxCacheAge = MemoryPerfomanceConstants.maxCacheAge
        SDImageCache.shared().maxMemoryCost = MemoryPerfomanceConstants.maxMemoryCost
        SDImageCache.shared().config.shouldCacheImagesInMemory = true //Default True => Store images in RAM cache for Fast performance
        SDImageCache.shared().config.shouldDecompressImages = false
        SDWebImageDownloader.shared().shouldDecompressImages = false
        SDImageCache.shared().config.diskCacheReadingOptions = NSData.ReadingOptions.mappedIfSafe
    }
    
    internal func clearCasheFromImages() {
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    //MARK: UI
    fileprivate func setupNavigation() {
        definesPresentationContext = true
        navigationItem.title = NSLocalizedString(TextConstants.kMainScreenTitle, comment: "Giphy")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: selectedStyle.buttonImage, style: .plain, target: self, action: #selector(changeContentLayout))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    fileprivate func setupSearchController() {
        searchController.searchBar.placeholder = NSLocalizedString(TextConstants.kSearchPlaceholder, comment: "The placeholder string for the Giphy search field")
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.delegate = self
        
        searchContainerView.backgroundColor = UIColor.clear
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        searchContainerView.isOpaque = true
        searchContainerView.addSubview(searchController.searchBar)
    }
    
    fileprivate func setupCollectionView() {
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .interactive
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(SwiftyGiphyCollectionViewCell.self, forCellWithReuseIdentifier: kGifSearchCollectionViewCell)
        if let collectionViewLayout = collectionView.collectionViewLayout as? SwiftyGiphyGridLayout
        {
            collectionViewLayout.delegate = self
        }
    }
    
    internal func setupLabel() {
        view.backgroundColor = UIColor.groupTableViewBackground
        loadingIndicator.color = .red
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        errorLabel.textAlignment = .center
        errorLabel.textColor = UIColor.lightGray
        errorLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .medium)
        errorLabel.numberOfLines = 0
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.text = NSLocalizedString(TextConstants.kTextForStartSearch, comment: "Please enter gif name to start search.")
        errorLabel.isHidden = false
    }
    
    fileprivate func setupConstraints() {
        self.view.addSubview(collectionView)
        self.view.addSubview(loadingIndicator)
        self.view.addSubview(errorLabel)
        self.view.addSubview(searchContainerView)
        
        keyboardAdjustConstraint = collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            searchContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            searchContainerView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor),
            searchContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            searchContainerView.heightAnchor.constraint(equalToConstant: UIConstants.searchControllerHeight),
            collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            collectionView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            keyboardAdjustConstraint
            ])
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor, constant: 0.0),
            loadingIndicator.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor, constant: 30.0)
            ])
        
        NSLayoutConstraint.activate([
            errorLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30.0),
            errorLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30.0),
            errorLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor, constant: 30.0)
            ])
    }
    
    fileprivate func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateBottomLayoutConstraintWithNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    //MARK: Layout style
    private func updatePresentationStyle() {
        switch selectedStyle {
        case .table:
            collectionViewGridLayOut.numberOfColumns = 1
        case .defaultGrid:
            collectionViewGridLayOut.numberOfColumns = 2
        }
        collectionView.layer.speed = AnimationsConstants.collectionViewLayerSpeed
        collectionView.performBatchUpdates({
            let indexSet = IndexSet(integersIn: 0...0)
            collectionView.reloadSections(indexSet)
        }, completion: { [unowned self] (finish) in
            if finish {
                self.collectionView.layer.speed = 1.0
            }
        })
        
        navigationItem.rightBarButtonItem?.image = selectedStyle.buttonImage
    }
    
    @objc private func changeContentLayout() {
        let allCases = PresentationStyle.allCases
        guard let index = allCases.firstIndex(of: selectedStyle) else { return }
        let nextIndex = (index + 1) % allCases.count
        selectedStyle = allCases[nextIndex]
        
    }
    
    //MARK: ViewModel
    func bindViewModel() {
        viewModel.startLoadingClosure = { [unowned self] in
            DispatchQueue.main.async {
                self.loadingIndicator.startAnimating()
                self.errorLabel.isHidden = true
                }
            }
        
        viewModel.stopLoadingClosure = { [unowned self] in
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.errorLabel.isHidden = true
            }
        }
        
        viewModel.showErrorClosure = { [unowned self] (error) in
            DispatchQueue.main.async {
                self.errorLabel.text = error
                self.errorLabel.isHidden = false
            }
        }
        
        viewModel.resultsListChangedClosure = { [unowned self] in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.navigationItem.rightBarButtonItem?.isEnabled = self.viewModel.currentGifs.count > 0
            }
        }
        
        viewModel.bindModelFor(width: max((self.collectionView.collectionViewLayout as? SwiftyGiphyGridLayout)?.columnWidth ?? 0.0, 0.0))
    }
    
}
