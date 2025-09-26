import Foundation
import SwiftUI

struct MasonryLayout: Layout {

    let columns: Int
    let spacing: CGFloat

    init(columns: Int = 2, spacing: CGFloat = 8) {
        self.columns = columns
        self.spacing = spacing
    }

    struct Cache {
        var availableWidth: CGFloat = -1
        var columnWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var assignments: [Int: Int] = [:]
        var placements: [SubviewPlacement] = []
    }

    func makeCache(subviews: Subviews) -> Cache { Cache() }
    func updateCache(_ cache: inout Cache, subviews: Subviews) { /* no-op */ }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        let proposedWidth = proposal.width ?? cache.availableWidth
        guard proposedWidth > 0 else {
            return CGSize(width: proposal.width ?? 0, height: cache.totalHeight)
        }

        recomputeIfNeeded(width: proposedWidth, subviews: subviews, cache: &cache)
        return CGSize(width: proposedWidth, height: cache.totalHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        let width = bounds.width
        if width > 0, width != cache.availableWidth {
            recomputeIfNeeded(width: width, subviews: subviews, cache: &cache)
        }

        for placement in cache.placements {
            let origin = CGPoint(
                x: bounds.minX + placement.origin.x,
                y: bounds.minY + placement.origin.y
            )
            let subProposal = ProposedViewSize(width: cache.columnWidth, height: nil)
            placement.subview.place(at: origin, proposal: subProposal)
        }
    }

    private func recomputeIfNeeded(
        width: CGFloat,
        subviews: Subviews,
        cache: inout Cache
    ) {
        let columnCount = max(1, columns)
        let newColumnWidth = calculateColumnWidth(
            availableWidth: width,
            columns: columnCount,
            spacing: spacing
        )

        let mustResetAssignments = cache.availableWidth != width
        || cache.columnWidth != newColumnWidth
        || cache.assignments.isEmpty

        if mustResetAssignments {
            cache.assignments.removeAll()
        }

        var columnHeights = Array(repeating: CGFloat(0), count: columnCount)
        var placements: [SubviewPlacement] = []
        placements.reserveCapacity(subviews.count)

        for index in subviews.indices {
            let subview = subviews[index]

            let assignedColumn: Int
            if let existing = cache.assignments[index], existing < columnCount {
                assignedColumn = existing
            } else {
                assignedColumn = indexOfShortestColumn(columnHeights)
                cache.assignments[index] = assignedColumn
            }

            let subProposal = ProposedViewSize(width: newColumnWidth, height: nil)
            let measuredSize = subview.sizeThatFits(subProposal)

            let x = CGFloat(assignedColumn) * (newColumnWidth + spacing)
            let y = columnHeights[assignedColumn]
            placements.append(SubviewPlacement(subview: subview, size: measuredSize, origin: CGPoint(x: x, y: y)))

            columnHeights[assignedColumn] = y + measuredSize.height + spacing
        }

        var totalHeight = columnHeights.max() ?? 0
        if !subviews.isEmpty { totalHeight = max(0, totalHeight - spacing) }

        cache.availableWidth = width
        cache.columnWidth = newColumnWidth
        cache.totalHeight = totalHeight
        cache.placements = placements

        cache.assignments = cache.assignments.filter { $0.key < subviews.count }
    }

    private func calculateColumnWidth(availableWidth: CGFloat, columns: Int, spacing: CGFloat) -> CGFloat {
        let totalSpacing = CGFloat(max(0, columns - 1)) * spacing
        let usable = max(0, availableWidth - totalSpacing)
        return usable / CGFloat(max(1, columns))
    }

    private func indexOfShortestColumn(_ heights: [CGFloat]) -> Int {
        var minIndex = 0
        var minValue = CGFloat.greatestFiniteMagnitude
        for (i, h) in heights.enumerated() where h < minValue {
            minValue = h
            minIndex = i
        }
        return minIndex
    }

    struct SubviewPlacement {
        let subview: LayoutSubview
        let size: CGSize
        let origin: CGPoint
    }
}
