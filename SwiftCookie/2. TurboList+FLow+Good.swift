//
//  TurboList.swift
//  SwiftCookie
//
//  Created by 김동현 on 3/15/26.
//

/**
 https://jinsangjin.tistory.com/184
 
 AnyView
 - 함수에서 서로 다른 타입의 뷰를 리턴해야 하는 경우에 사용한다
 */
/*
import SwiftUI

public struct TurboList<Data, Content>: View where Data: RandomAccessCollection, Content : View {
    
    private let views: [AnyView]
    private var spacing: CGFloat = 0
    
    // MARK: ViewBuilder initializer
    public init(
        spacing: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) where Data == [Int] {
        self.spacing = spacing
        self.views = TurboList.flatten(content())
    }
    
    // MARK: Data 기반 initializer
    public init(
        _ data: Data,
        spacing: CGFloat = 0,
        @ViewBuilder content: (Data.Element) -> Content
    ) {
        self.spacing = spacing
        self.views = data.map { AnyView(content($0)) }
    }

    
    public var body: some View {
        TurboListRepresentable(
            spacing: spacing,
            views: views
        )
    }
}

extension TurboList {
//    // SwiftUI ViewBuilder는 tuple로 들어오기 때문에 flatten이 필요합니다
//    static func flatten<V: View>(_ view: V) -> [AnyView] {
//        let mirror = Mirror(reflecting: view)
//        if mirror.displayStyle == .tuple {
//            return mirror.children.compactMap {
//                AnyView(_fromValue: $0.value)
//            }
//        }
//        return [AnyView(view)]
//    }
    
    static func flatten<V: View>(_ view: V) -> [AnyView] {

        let mirror = Mirror(reflecting: view)

        if mirror.displayStyle == .struct,
           String(describing: type(of: view)).contains("TupleView") {

            if let valueChild = mirror.children.first {
                let tupleMirror = Mirror(reflecting: valueChild.value)

                return tupleMirror.children.compactMap {
                    AnyView(_fromValue: $0.value)
                }
            }
        }

        return [AnyView(view)]
    }
}

// UIViewRepresentable
struct TurboListRepresentable: UIViewRepresentable {
    let spacing: CGFloat
    let views: [AnyView]
    
    func makeUIView(
        context: Context
    ) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.sectionInset = .zero
        
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        // layout.estimatedItemSize = CGSize(width: 1, height: 1)
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        
        collectionView.alwaysBounceVertical = true              // 스크롤
        collectionView.showsVerticalScrollIndicator = false     // 인디케이터
        collectionView.backgroundColor = .clear                 // 배경

        collectionView.register(
            TurboListCell.self,
            forCellWithReuseIdentifier: "cell"
        )
        
        return collectionView
    }
    
    func updateUIView(
        _ uiView: UIViewType,
        context: Context
    ) {
        context.coordinator.views = views
        uiView.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(spacing: spacing, views: views)
    }
}

final class Coordinator: NSObject {
    let spacing: CGFloat
    var views: [AnyView]
    init(spacing: CGFloat,
         views: [AnyView]
    ) {
        self.spacing = spacing
        self.views = views
    }
}

extension Coordinator: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        views.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath
        )
        
        // SwiftUI View를 Cell에 넣기
        cell.contentConfiguration = UIHostingConfiguration {
            views[indexPath.item]
                .frame(maxWidth: .infinity)
        }
        .margins(.all, 0)
        return cell
    }
}

extension Coordinator: UICollectionViewDelegateFlowLayout {
    // 셀 간격
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return spacing
    }
}

struct TestUICellView: View {
    var number: Int
    
    var body: some View {
        VStack {
            Text("\(number)")
                .font(.system(size: 30, weight: .bold))
            Text("Hello, World!")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .border(.red)
    }
}

final class TurboListCell: UICollectionViewCell {

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {

        let attrs = super.preferredLayoutAttributesFitting(layoutAttributes)

        if let collectionView = superview as? UICollectionView {

            attrs.frame.size.width = collectionView.bounds.width
        }

        return attrs
    }
}


struct SampleView: View {
    var body: some View {
        
        VStack {
            TurboList(spacing: 10) {
                TestUICellView(number: 1)
                TestUICellView(number: 2)
                TestUICellView(number: 3)
                
                HStack {
                    TestUICellView(number: 2)
                    TestUICellView(number: 3)
                }
            }
        }.padding(10)

    }
}

#Preview {
    SampleView()
}
*/


//
//import SwiftUI
//import UIKit
//
//// MARK: - Section Model
//
//struct TurboSectionModel {
//    var header: AnyView?
//    var items: [AnyView]
//}
//
//// MARK: - AnyTurboSection Protocol
//
//protocol AnyTurboSection {
//    var headerView: AnyView { get }
//    var items: [AnyView] { get }
//}
//
//// MARK: - TurboSection
//
//public struct TurboSection<Header: View, Content: View>: View {
//
//    let header: Header
//    let content: Content
//
//    public init(
//        @ViewBuilder header: () -> Header,
//        @ViewBuilder content: () -> Content
//    ) {
//        self.header = header()
//        self.content = content()
//    }
//
//    public var body: some View {
//        content
//    }
//}
//
//// MARK: - TurboSection Protocol Conformance
//
//extension TurboSection: AnyTurboSection {
//
//    var headerView: AnyView {
//        AnyView(header)
//    }
//
//    var items: [AnyView] {
//
//        let mirror = Mirror(reflecting: content)
//
//        if mirror.displayStyle == .tuple {
//
//            return mirror.children.compactMap {
//                ($0.value as? any View).map { AnyView($0) }
//            }
//        }
//
//        if let view = content as? any View {
//            return [AnyView(view)]
//        }
//
//        return []
//    }
//}
//
//// MARK: - TurboList
//
//public struct TurboList<Content: View>: View {
//
//    private let sections: [TurboSectionModel]
//    private let spacing: CGFloat
//
//    public init(
//        spacing: CGFloat = 0,
//        @ViewBuilder content: () -> Content
//    ) {
//        self.spacing = spacing
//        self.sections = TurboList.parse(content())
//    }
//
//    public var body: some View {
//        TurboListRepresentable(
//            spacing: spacing,
//            sections: sections
//        )
//    }
//}
//
//// MARK: - Parser
//
//extension TurboList {
//
//    static func parse<V: View>(_ view: V) -> [TurboSectionModel] {
//
//        let mirror = Mirror(reflecting: view)
//
//        if mirror.displayStyle == .tuple {
//
//            return mirror.children.flatMap {
//                parseItem($0.value)
//            }
//        }
//
//        return parseItem(view)
//    }
//
//    static func parseItem(_ value: Any) -> [TurboSectionModel] {
//
//        if let section = value as? AnyTurboSection {
//
//            return [
//                TurboSectionModel(
//                    header: section.headerView,
//                    items: section.items
//                )
//            ]
//        }
//
//        if let view = value as? any View {
//
//            return [
//                TurboSectionModel(
//                    header: nil,
//                    items: [AnyView(view)]
//                )
//            ]
//        }
//
//        return []
//    }
//}
//
//// MARK: - UIViewRepresentable
//
//struct TurboListRepresentable: UIViewRepresentable {
//
//    let spacing: CGFloat
//    let sections: [TurboSectionModel]
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(spacing: spacing, sections: sections)
//    }
//
//    func makeUIView(context: Context) -> UICollectionView {
//
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumLineSpacing = spacing
//        layout.estimatedItemSize = CGSize(width: 1, height: 1)
//
//        let cv = UICollectionView(
//            frame: .zero,
//            collectionViewLayout: layout
//        )
//
//        cv.dataSource = context.coordinator
//        cv.delegate = context.coordinator
//        cv.backgroundColor = .clear
//
//        cv.register(
//            TurboListCell.self,
//            forCellWithReuseIdentifier: "cell"
//        )
//
//        cv.register(
//            TurboHeaderView.self,
//            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//            withReuseIdentifier: "header"
//        )
//
//        return cv
//    }
//
//    func updateUIView(
//        _ uiView: UICollectionView,
//        context: Context
//    ) {
//        context.coordinator.sections = sections
//        uiView.reloadData()
//    }
//}
//
//// MARK: - Coordinator
//
//final class Coordinator: NSObject {
//
//    let spacing: CGFloat
//    var sections: [TurboSectionModel]
//
//    init(
//        spacing: CGFloat,
//        sections: [TurboSectionModel]
//    ) {
//        self.spacing = spacing
//        self.sections = sections
//    }
//}
//
//// MARK: - DataSource
//
//extension Coordinator: UICollectionViewDataSource {
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        sections.count
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        numberOfItemsInSection section: Int
//    ) -> Int {
//        sections[section].items.count
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        cellForItemAt indexPath: IndexPath
//    ) -> UICollectionViewCell {
//
//        let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: "cell",
//            for: indexPath
//        )
//
//        let view = sections[indexPath.section].items[indexPath.item]
//
//        cell.contentConfiguration = UIHostingConfiguration {
//            view.frame(maxWidth: .infinity)
//        }
//        .margins(.all, 0)
//
//        return cell
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        viewForSupplementaryElementOfKind kind: String,
//        at indexPath: IndexPath
//    ) -> UICollectionReusableView {
//
//        guard kind == UICollectionView.elementKindSectionHeader else {
//            return UICollectionReusableView()
//        }
//
//        let view = collectionView.dequeueReusableSupplementaryView(
//            ofKind: kind,
//            withReuseIdentifier: "header",
//            for: indexPath
//        ) as! TurboHeaderView
//
//        if let header = sections[indexPath.section].header {
//            view.configure(view: header)
//        }
//
//        return view
//    }
//}
//
//// MARK: - Layout
//
//extension Coordinator: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        referenceSizeForHeaderInSection section: Int
//    ) -> CGSize {
//
//        guard sections[section].header != nil else {
//            return .zero
//        }
//
//        return CGSize(
//            width: collectionView.bounds.width,
//            height: 44
//        )
//    }
//}
//
//// MARK: - Header View
//
//final class TurboHeaderView: UICollectionReusableView {
//
//    private var hostingController: UIHostingController<AnyView>?
//
//    func configure(view: AnyView) {
//
//        hostingController?.view.removeFromSuperview()
//
//        let hc = UIHostingController(rootView: view)
//        hc.view.translatesAutoresizingMaskIntoConstraints = false
//        hc.view.backgroundColor = .clear
//
//        addSubview(hc.view)
//
//        NSLayoutConstraint.activate([
//            hc.view.topAnchor.constraint(equalTo: topAnchor),
//            hc.view.leadingAnchor.constraint(equalTo: leadingAnchor),
//            hc.view.trailingAnchor.constraint(equalTo: trailingAnchor),
//            hc.view.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//
//        hostingController = hc
//    }
//}
//
//// MARK: - Cell
//
//final class TurboListCell: UICollectionViewCell {
//
//    override func preferredLayoutAttributesFitting(
//        _ layoutAttributes: UICollectionViewLayoutAttributes
//    ) -> UICollectionViewLayoutAttributes {
//
//        let attrs = super.preferredLayoutAttributesFitting(layoutAttributes)
//
//        if let cv = superview as? UICollectionView {
//            attrs.frame.size.width = cv.bounds.width
//        }
//
//        return attrs
//    }
//}
//
//struct TestView: View {
//    var body: some View {
//        TurboList(spacing: 20) {
//
//            TurboSection {
//
//                Text("Header 1")
//                    .font(.title)
//
//            } content: {
//
//                Text("Row 1")
//                Text("Row 2")
//            }
//
//            TurboSection {
//
//                Text("Header 2")
//
//            } content: {
//
//                Text("Row 3")
//                Text("Row 4")
//            }
//        }
//    }
//}
//
//#Preview {
//    TestView()
//}
