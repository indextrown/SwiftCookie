////
////  TurboList+Flow_Diff.swift
////  SwiftCookie
////
////  Created by 김동현 on 3/15/26.
////
//
//import SwiftUI
//import UIKit
//import DifferenceKit
//
//// MARK: - Item
//
//struct TurboItem: Differentiable {
//
//    let id: UUID
//    let view: AnyView
//
//    init(view: AnyView) {
//        self.id = UUID()
//        self.view = view
//    }
//
//    var differenceIdentifier: UUID {
//        id
//    }
//
//    func isContentEqual(to source: TurboItem) -> Bool {
//        false
//    }
//}
//
//// MARK: - TurboList
//
//public struct TurboList<Data, Content>: View
//where Data: RandomAccessCollection, Content: View {
//
//    private let items: [TurboItem]
//    private var spacing: CGFloat = 0
//
//    // ViewBuilder init
//    public init(
//        spacing: CGFloat = 0,
//        @ViewBuilder content: () -> Content
//    ) where Data == [Int] {
//
//        self.spacing = spacing
//
//        let views = TurboList.flatten(content())
//        self.items = views.map { TurboItem(view: $0) }
//    }
//
//    // Data 기반 init
//    public init(
//        _ data: Data,
//        spacing: CGFloat = 0,
//        @ViewBuilder content: (Data.Element) -> Content
//    ) {
//
//        self.spacing = spacing
//
//        self.items = data.map {
//            TurboItem(view: AnyView(content($0)))
//        }
//    }
//
//    public var body: some View {
//
//        TurboListRepresentable(
//            spacing: spacing,
//            items: items
//        )
//    }
//}
//
//// MARK: - Flatten
//
//extension TurboList {
//
//    static func flatten<V: View>(_ view: V) -> [AnyView] {
//
//        let mirror = Mirror(reflecting: view)
//
//        if mirror.displayStyle == .struct,
//           String(describing: type(of: view)).contains("TupleView") {
//
//            if let valueChild = mirror.children.first {
//
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
//// MARK: - UIViewRepresentable
//
//struct TurboListRepresentable: UIViewRepresentable {
//
//    let spacing: CGFloat
//    let items: [TurboItem]
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(spacing: spacing, items: items)
//    }
//
//    func makeUIView(context: Context) -> UICollectionView {
//
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumLineSpacing = spacing
//        layout.sectionInset = .zero
//        layout.itemSize = UICollectionViewFlowLayout.automaticSize
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//
//        let collectionView = UICollectionView(
//            frame: .zero,
//            collectionViewLayout: layout
//        )
//
//        collectionView.dataSource = context.coordinator
//        collectionView.delegate = context.coordinator
//
//        collectionView.backgroundColor = .clear
//        collectionView.alwaysBounceVertical = true
//        collectionView.showsVerticalScrollIndicator = false
//
//        collectionView.register(
//            TurboListCell.self,
//            forCellWithReuseIdentifier: "cell"
//        )
//
//        context.coordinator.collectionView = collectionView
//
//        return collectionView
//    }
//
//    func updateUIView(
//        _ uiView: UICollectionView,
//        context: Context
//    ) {
//
//        context.coordinator.apply(items: items)
//    }
//}
//
//// MARK: - Coordinator
//
//final class Coordinator: NSObject {
//
//    let spacing: CGFloat
//
//    var items: [TurboItem]
//    weak var collectionView: UICollectionView?
//
//    init(spacing: CGFloat, items: [TurboItem]) {
//        self.spacing = spacing
//        self.items = items
//    }
//
//    func apply(items newItems: [TurboItem]) {
//
//        guard let collectionView else { return }
//
//        let changeset = StagedChangeset(
//            source: items,
//            target: newItems
//        )
//
//        collectionView.reload(
//            using: changeset,
//            setData: { data in
//                self.items = data
//            }
//        )
//    }
//}
//
//// MARK: - DataSource
//
//extension Coordinator: UICollectionViewDataSource {
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        numberOfItemsInSection section: Int
//    ) -> Int {
//
//        items.count
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
//        let item = items[indexPath.item]
//
//        cell.contentConfiguration = UIHostingConfiguration {
//
//            item.view
//                .frame(maxWidth: .infinity)
//
//        }.margins(.all, 0)
//
//        return cell
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
//        minimumLineSpacingForSectionAt section: Int
//    ) -> CGFloat {
//
//        spacing
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
//        if let collectionView = superview as? UICollectionView {
//
//            attrs.frame.size.width = collectionView.bounds.width
//        }
//
//        return attrs
//    }
//}
//
//// MARK: - Example Cell
//
//struct TestUICellView: View {
//
//    var number: Int
//
//    var body: some View {
//
//        VStack {
//
//            Text("\(number)")
//                .font(.system(size: 30, weight: .bold))
//
//            Text("Hello, World!")
//
//        }
//        .frame(maxWidth: .infinity)
//        .border(.red)
//    }
//}
//
//// MARK: - Sample
//
//struct SampleView: View {
//
//    var body: some View {
//
//        TurboList(spacing: 10) {
//
//            TestUICellView(number: 1)
//            TestUICellView(number: 2)
//            TestUICellView(number: 3)
//
//            HStack {
//
//                TestUICellView(number: 4)
//                TestUICellView(number: 5)
//            }
//        }
//        .padding(10)
//    }
//}
//
//#Preview {
//    SampleView()
//}


/*
import SwiftUI
import UIKit
import DifferenceKit

// MARK: - TurboItem

public struct TurboItem: Differentiable {

    let id: UUID
    let view: AnyView

    init<V: View>(_ view: V) {
        self.id = UUID()
        self.view = AnyView(view)
    }

    public var differenceIdentifier: UUID {
        id
    }

    public func isContentEqual(to source: TurboItem) -> Bool {
        false
    }
}

//
// MARK: - ResultBuilder
//

@resultBuilder
public struct TurboListBuilder {

    public static func buildBlock(_ components: TurboItem...) -> [TurboItem] {
        components
    }

    public static func buildExpression<V: View>(_ expression: V) -> TurboItem {
        TurboItem(expression)
    }

    public static func buildArray(_ components: [[TurboItem]]) -> [TurboItem] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [TurboItem]?) -> [TurboItem] {
        component ?? []
    }
}

//
// MARK: - TurboList
//

public struct TurboList: View {

    private let items: [TurboItem]
    private let spacing: CGFloat

    public init(
        spacing: CGFloat = 0,
        @TurboListBuilder content: () -> [TurboItem]
    ) {

        self.spacing = spacing
        self.items = content()
    }

    public var body: some View {

        TurboListRepresentable(
            spacing: spacing,
            items: items
        )
    }
}

//
// MARK: - UIViewRepresentable
//

public struct TurboListRepresentable: UIViewRepresentable {

    let spacing: CGFloat
    let items: [TurboItem]

    public func makeCoordinator() -> Coordinator {
        Coordinator(spacing: spacing, items: items)
    }

    public func makeUIView(context: Context) -> UICollectionView {

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let cv = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        cv.dataSource = context.coordinator
        cv.delegate = context.coordinator

        cv.backgroundColor = .clear
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = false

        cv.register(
            TurboListCell.self,
            forCellWithReuseIdentifier: "cell"
        )

        context.coordinator.collectionView = cv

        return cv
    }

    public func updateUIView(
        _ uiView: UICollectionView,
        context: Context
    ) {

        context.coordinator.apply(items: items)
    }
}

//
// MARK: - Coordinator
//

public final class Coordinator: NSObject {

    let spacing: CGFloat
    var items: [TurboItem]

    weak var collectionView: UICollectionView?

    init(spacing: CGFloat, items: [TurboItem]) {

        self.spacing = spacing
        self.items = items
    }

    func apply(items newItems: [TurboItem]) {

        guard let collectionView else { return }

        let changeset = StagedChangeset(
            source: items,
            target: newItems
        )

        print("changeset:", changeset)
        collectionView.reload(
            using: changeset,
            setData: { data in
                self.items = data
            }
        )
    }
}

//
// MARK: - DataSource
//

extension Coordinator: UICollectionViewDataSource {

    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        items.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath
        )

        let item = items[indexPath.item]

        cell.contentConfiguration = UIHostingConfiguration {

            item.view
                .frame(maxWidth: .infinity)

        }.margins(.all, 0)

        return cell
    }
}

//
// MARK: - Layout
//

extension Coordinator: UICollectionViewDelegateFlowLayout {

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {

        spacing
    }
}

//
// MARK: - Cell
//

final class TurboListCell: UICollectionViewCell {

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {

        let attrs = super.preferredLayoutAttributesFitting(layoutAttributes)

        if let cv = superview as? UICollectionView {
            attrs.frame.size.width = cv.bounds.width
        }

        return attrs
    }
}

//
// MARK: - Example
//

struct TestUICellView: View {

    let number: Int

    var body: some View {

        VStack {

            Text("\(number)")
                .font(.system(size: 30, weight: .bold))

            Text("Hello World")

        }
        .frame(maxWidth: .infinity)
        .border(.red)
    }
}

//
// MARK: - Sample
//

//struct SampleView: View {
//
//    var body: some View {
//
//        TurboList(spacing: 12) {
//
//            TestUICellView(number: 1)
//            TestUICellView(number: 2)
//            TestUICellView(number: 3)
//
//            HStack {
//
//                TestUICellView(number: 4)
//                TestUICellView(number: 5)
//            }
//        }
//        .padding()
//    }
//}
//
//#Preview {
//
//    SampleView()
//}


struct DiffTestView: View {

    @State
    private var numbers: [Int] = [1,2,3]

    var body: some View {

        VStack(spacing: 20) {

            TurboList(spacing: 10) {

                ForEach(numbers, id: \.self) { number in
                    TestUICellView(number: number)
                }

            }

            HStack {

                Button("Add") {
                    numbers.append(Int.random(in: 4...100))
                }

                Button("Remove") {
                    if !numbers.isEmpty {
                        numbers.removeLast()
                    }
                }

                Button("Shuffle") {
                    numbers.shuffle()
                }

            }

        }
        .padding()
    }
}

#Preview {
    DiffTestView()
}
*/

import SwiftUI
import UIKit
import DifferenceKit

// MARK: - TurboItem

public struct TurboItem: Differentiable {

    public let id: AnyHashable
    let view: AnyView

    public init<V: View>(id: AnyHashable, _ view: V) {
        self.id = id
        self.view = AnyView(view)
    }

    public var differenceIdentifier: AnyHashable {
        id
    }

    public func isContentEqual(to source: TurboItem) -> Bool {
        id == source.id
    }
}

//
// MARK: - ResultBuilder
//

@resultBuilder
public struct TurboListBuilder {

    public static func buildBlock(_ components: [TurboItem]...) -> [TurboItem] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: TurboItem) -> [TurboItem] {
        [expression]
    }

    public static func buildExpression<V: View>(_ expression: V) -> [TurboItem] {
        [
            TurboItem(
                id: UUID(),
                expression
            )
        ]
    }

    public static func buildOptional(_ component: [TurboItem]?) -> [TurboItem] {
        component ?? []
    }

    public static func buildArray(_ components: [[TurboItem]]) -> [TurboItem] {
        components.flatMap { $0 }
    }
}

//
// MARK: - TurboList
//

public struct TurboList: View {

    private let items: [TurboItem]
    private let spacing: CGFloat

    public init(
        spacing: CGFloat = 0,
        @TurboListBuilder content: () -> [TurboItem]
    ) {

        self.spacing = spacing
        self.items = content()
    }
    
    public init<Data, Content>(
        _ data: Data,
        spacing: CGFloat = 0,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) where Data: RandomAccessCollection,
            Data.Element: Identifiable,
            Content: View {

        self.spacing = spacing
        self.items = data.map {
            TurboItem(
                id: $0.id,
                content($0)
            )
        }
    }

    public var body: some View {

        TurboListRepresentable(
            spacing: spacing,
            items: items
        )
    }
}

//
// MARK: - UIViewRepresentable
//

public struct TurboListRepresentable: UIViewRepresentable {

    let spacing: CGFloat
    let items: [TurboItem]

    public func makeCoordinator() -> Coordinator {
        Coordinator(spacing: spacing, items: items)
    }

    public func makeUIView(context: Context) -> UICollectionView {

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator

        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false

        collectionView.register(
            TurboListCell.self,
            forCellWithReuseIdentifier: "cell"
        )

        context.coordinator.collectionView = collectionView

        return collectionView
    }

    public func updateUIView(
        _ uiView: UICollectionView,
        context: Context
    ) {

        context.coordinator.apply(items: items)
    }
}

//
// MARK: - Coordinator
//

public final class Coordinator: NSObject {

    let spacing: CGFloat
    var items: [TurboItem]

    weak var collectionView: UICollectionView?

    init(spacing: CGFloat, items: [TurboItem]) {
        self.spacing = spacing
        self.items = items
    }

    func apply(items newItems: [TurboItem]) {

        guard let collectionView else { return }

        let changeset = StagedChangeset(
            source: items,
            target: newItems
        )

        print("changeset:", changeset)

        collectionView.reload(
            using: changeset,
            setData: { data in
                self.items = data
            }
        )
    }
}

//
// MARK: - DataSource
//

extension Coordinator: UICollectionViewDataSource {

    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        items.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath
        )

        let item = items[indexPath.item]

        cell.contentConfiguration = UIHostingConfiguration {

            item.view
                .frame(maxWidth: .infinity)

        }.margins(.all, 0)

        return cell
    }
}

//
// MARK: - Layout
//

extension Coordinator: UICollectionViewDelegateFlowLayout {

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {

        spacing
    }
}

//
// MARK: - Cell
//

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

struct Item: Identifiable {
    let id = UUID()
    let name: String
}

struct ItemRowView: View {

    let item: Item

    var body: some View {
        Text(item.name)
            .frame(maxWidth: .infinity)
            .padding()
            .border(.red)
    }
}

struct SampleView: View {

    @State
    private var items: [Item] = [
        Item(name: "Apple"),
        Item(name: "Banana"),
        Item(name: "Cherry")
    ]

    var body: some View {

        VStack {

//            TurboList(spacing: 20) {
//
//                ForEach(items) { item in
//                    ItemRowView(item: item)
//                }
//
//            }
            
            TurboList(items, spacing: 30) { item in
                ItemRowView(item: item)
            }

            HStack {

                Button("Add") {
                    items.append(Item(name: "New Item"))
                }

                Button("Remove") {
                    if !items.isEmpty {
                        items.removeLast()
                    }
                }

                Button("Shuffle") {
                    items.shuffle()
                }

            }

        }
        .padding()
    }
}

#Preview {
    SampleView()
}
