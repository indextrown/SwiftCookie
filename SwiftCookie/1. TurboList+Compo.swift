////
////  TurboList.swift
////  SwiftCookie
////
////  Created by 김동현 on 3/15/26.
////
//
//import SwiftUI
//import UIKit
//
//public struct TurboList<Data: RandomAccessCollection, ID: Hashable & Sendable, Content: View>: View {
//    private let items: [TurboListItem<ID>]
//    private let spacing: CGFloat
//
//    public init(
//        _ data: Data,
//        id: KeyPath<Data.Element, ID>,
//        spacing: CGFloat = 0,
//        @ViewBuilder content: @escaping (Data.Element) -> Content
//    ) {
//        self.spacing = spacing
//        self.items = data.map { element in
//            TurboListItem(
//                id: element[keyPath: id],
//                view: AnyView(content(element))
//            )
//        }
//    }
//    
//    public init(
//        spacing: CGFloat = 0,
//        @ViewBuilder content: () -> Content
//    ) where Data == [Int], ID == Int {
//        
//        let views = TurboList.flatten(content())
//
//        self.spacing = spacing
//        self.items = views.enumerated().map { index, view in
//            TurboListItem(
//                id: index,
//                view: view
//            )
//        }
//    }
//    
////    static func flatten<V: View>(_ view: V) -> [AnyView] {
////        let mirror = Mirror(reflecting: view)
////
////        if mirror.displayStyle == .tuple {
////            return mirror.children.compactMap {
////                AnyView(_fromValue: $0.value)
////            }
////        }
////
////        return [AnyView(view)]
////    }
//    static func flatten<V: View>(_ view: V) -> [AnyView] {
//
//        let mirror = Mirror(reflecting: view)
//
//        if mirror.displayStyle == .struct,
//           String(describing: type(of: view)).contains("TupleView") {
//
//            if let valueChild = mirror.children.first {
//                let tupleMirror = Mirror(reflecting: valueChild.value)
//
//                return tupleMirror.children.compactMap {
//                    AnyView(_fromValue: $0.value)
//                }
//            }
//        }
//
//        return [AnyView(view)]
//    }
//}
//
//
//
//public extension TurboList where Data.Element: Identifiable, ID == Data.Element.ID, ID: Sendable {
//    init(
//        _ data: Data,
//        spacing: CGFloat = 0,
//        @ViewBuilder content: @escaping (Data.Element) -> Content
//    ) {
//        self.init(data, id: \.id, spacing: spacing, content: content)
//    }
//}
//
//public extension TurboList {
//    var body: some View {
//        TurboListRepresentable(items: items, spacing: spacing)
//    }
//}
//
//private struct TurboListItem<ID: Hashable & Sendable> {
//    let id: ID
//    let view: AnyView
//}
//
//private enum TurboListSection {
//    case main
//}
//
//private final class TurboListCell: UICollectionViewCell {
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .clear
//        contentView.backgroundColor = .clear
//    }
//
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func configure(with view: AnyView) {
//        contentConfiguration = UIHostingConfiguration {
//            view
//                .frame(maxWidth: .infinity)
//                //.background(Color.red.opacity(0.2))
//        }
//        .margins(.all, 0)
//    }
//}
//
//private struct TurboListRepresentable<ID: Hashable & Sendable>: UIViewRepresentable {
//    let items: [TurboListItem<ID>]
//    let spacing: CGFloat
//
//    func makeUIView(context: Context) -> UICollectionView {
//        let collectionView = UICollectionView(
//            frame: .zero,
//            collectionViewLayout: makeLayout()
//        )
//        collectionView.backgroundColor = .clear
//        collectionView.showsVerticalScrollIndicator = false
//        collectionView.alwaysBounceVertical = true
//        collectionView.contentInset = .zero
//        collectionView.contentInsetAdjustmentBehavior = .never
//        collectionView.register(TurboListCell.self, forCellWithReuseIdentifier: "cell")
//
//        context.coordinator.configureDataSource(with: collectionView)
//        context.coordinator.items = items
//        context.coordinator.applySnapshot(animated: false)
//        return collectionView
//    }
//
//    func updateUIView(_ uiView: UICollectionView, context: Context) {
//        context.coordinator.items = items
//        uiView.setCollectionViewLayout(makeLayout(), animated: false)
//        context.coordinator.applySnapshot(animated: false)
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(items: items)
//    }
//
//    private func makeLayout() -> UICollectionViewCompositionalLayout {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(1)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .estimated(1)
//        )
//        let group = NSCollectionLayoutGroup.vertical(
//            layoutSize: groupSize,
//            subitems: [item]
//        )
//
//        let section = NSCollectionLayoutSection(group: group)
//        section.interGroupSpacing = spacing
//        section.contentInsets = .zero
//
//        let configuration = UICollectionViewCompositionalLayoutConfiguration()
//        configuration.contentInsetsReference = .none
//
//        return UICollectionViewCompositionalLayout(
//            section: section,
//            configuration: configuration
//        )
//    }
//
//    final class Coordinator: NSObject {
//        var items: [TurboListItem<ID>]
//        private var dataSource: UICollectionViewDiffableDataSource<TurboListSection, ID>?
//
//        init(items: [TurboListItem<ID>]) {
//            self.items = items
//        }
//
//        func configureDataSource(with collectionView: UICollectionView) {
//            let dataSource = UICollectionViewDiffableDataSource<TurboListSection, ID>(
//                collectionView: collectionView
//            ) { [weak self] collectionView, indexPath, itemID in
//                guard let self,
//                      let cell = collectionView.dequeueReusableCell(
//                        withReuseIdentifier: "cell",
//                        for: indexPath
//                      ) as? TurboListCell,
//                      let item = self.items.first(where: { $0.id == itemID }) else {
//                    return UICollectionViewCell()
//                }
//
//                cell.configure(with: item.view)
//                return cell
//            }
//            self.dataSource = dataSource
//        }
//
//        func applySnapshot(animated: Bool) {
//            guard let dataSource else { return }
//
//            var snapshot = NSDiffableDataSourceSnapshot<TurboListSection, ID>()
//            snapshot.appendSections([.main])
//            snapshot.appendItems(items.map(\.id), toSection: .main)
//            dataSource.apply(snapshot, animatingDifferences: animated)
//        }
//    }
//}
//
//struct TestUICellView: View {
//    let number: Int
//
//    var body: some View {
//        VStack(spacing: 0) {
//            Text("\(number)")
//                .font(.system(size: 30, weight: .bold))
//            Text("Hello, World!")
//        }
//        .frame(maxWidth: .infinity)
//        //.border(.red)
//    }
//}
//
//private struct SampleItem: Identifiable {
//    let id = UUID()
//    let title: String
//    let number: Int?
//}
//
//struct SampleView: View {
//    private let items = [
//        SampleItem(title: "Hello, World!", number: nil),
//        SampleItem(title: "Hello, World!", number: nil),
//        SampleItem(title: "", number: 1),
//        SampleItem(title: "", number: 2),
//        SampleItem(title: "", number: 3)
//    ]
//
//    var body: some View {
//        TurboList(spacing: 20) {
//
//            TestUICellView(number: 1)
//            TestUICellView(number: 2)
//            TestUICellView(number: 3)
//        }
//    }
//}
//
//#Preview {
//    SampleView()
//}
