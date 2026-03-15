//
//  SwiftList.swift
//  SwiftCookie
//
//  Created by 김동현 on 3/15/26.
//

import SwiftUI
import UIKit

struct SwiftUICellView: View {
    var number: Int
    
    var body: some View {
        VStack {
            Text("\(number)")
                .font(.system(size: 20, weight: .bold))
            Text("Hello, World!")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .border(.red)
    }
}


final class UIHostingCell<Content: View>: UICollectionViewCell {
    private let hostingController = UIHostingController<Content?>(rootView: nil)
    
    // optional
    override func prepareForReuse() {
        super.prepareForReuse()
        self.hostingController.rootView = nil
        self.hostingController.removeFromParent()
    }
    
    func configure(view: Content, parent: UIViewController?) {
        self.hostingController.rootView = view
        self.hostingController.view.invalidateIntrinsicContentSize()
        self.hostingController.view.backgroundColor = .clear
        
        // 셀 재사용 시 view 중복 방지
        if !contentView.subviews.contains(hostingController.view) {
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(hostingController.view)
            
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
           
        }
        // layoutIfNeeded()
    }
}

class ViewController: UIViewController {
    private var dataSource: [Int] = Array(1...100)
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        
    }
    
    private func setupUI() {
         view.backgroundColor = .white
         view.addSubview(collectionView)
         collectionView.translatesAutoresizingMaskIntoConstraints = false
         
         NSLayoutConstraint.activate([
             collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             collectionView.topAnchor.constraint(equalTo: view.topAnchor),
             collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
         ])
     }
    
    private func setupCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        collectionView.register(
            UIHostingCell<SwiftUICellView>.self,
            forCellWithReuseIdentifier: "Cell"
        )
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // 셀 개수
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return dataSource.count
    }
    
    // 셀 재사용 설정
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "Cell",
            for: indexPath
        ) as? UIHostingCell<SwiftUICellView> else {
            return UICollectionViewCell()
        }
        
        let number = dataSource[indexPath.item]
        let cellView = SwiftUICellView(number: number)
        cell.configure(view: cellView, parent: self)
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    // 셀 크기
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    // 셀 간격
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 30
    }
}


#Preview {
    ViewController()
}
