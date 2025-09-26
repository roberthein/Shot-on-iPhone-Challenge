import Foundation
import SwiftUI

struct FlowLayout: Layout {

    enum RowAlignment {
        case leading
        case center
        case trailing
    }

    let spacing: CGFloat
    let rowAlignment: RowAlignment
    init(spacing: CGFloat = 8, rowAlignment: RowAlignment = .leading) {
        self.spacing = spacing
        self.rowAlignment = rowAlignment
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        let availableWidth = proposal.width ?? 0
        let calculatedHeight = calculateTotalHeight(
            proposal: proposal,
            subviews: subviews,
            availableWidth: availableWidth
        )

        return CGSize(width: availableWidth, height: calculatedHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        let organizedRows = organizeSubviewsIntoRows(
            proposal: proposal,
            subviews: subviews,
            availableWidth: bounds.width
        )

        placeRowsInBounds(
            rows: organizedRows,
            bounds: bounds,
            proposal: proposal
        )
    }

    private func calculateTotalHeight(
        proposal: ProposedViewSize,
        subviews: Subviews,
        availableWidth: CGFloat
    ) -> CGFloat {
        let rows = organizeSubviewsIntoRows(
            proposal: proposal,
            subviews: subviews,
            availableWidth: availableWidth
        )

        let totalRowHeights = rows.reduce(0) { accumulatedHeight, row in
            let maxRowHeight = row.map { $0.size.height }.max() ?? 0
            return accumulatedHeight + maxRowHeight
        }

        let totalSpacingHeight = calculateVerticalSpacing(for: rows.count)

        return totalRowHeights + totalSpacingHeight
    }

    private func organizeSubviewsIntoRows(
        proposal: ProposedViewSize,
        subviews: Subviews,
        availableWidth: CGFloat
    ) -> [[SubviewLayoutInfo]] {
        var organizedRows: [[SubviewLayoutInfo]] = []
        var currentRow: [SubviewLayoutInfo] = []
        var currentRowWidth: CGFloat = 0

        for subview in subviews {
            let subviewSize = subview.sizeThatFits(proposal)
            let subviewInfo = SubviewLayoutInfo(subview: subview, size: subviewSize)

            let wouldBeRowWidth = calculateRowWidthIfAddingSubview(
                currentRowWidth: currentRowWidth,
                subviewWidth: subviewSize.width,
                isFirstSubview: currentRow.isEmpty
            )

            if canFitSubviewInCurrentRow(
                wouldBeRowWidth: wouldBeRowWidth,
                availableWidth: availableWidth,
                isFirstSubview: currentRow.isEmpty
            ) {
                currentRow.append(subviewInfo)
                currentRowWidth = wouldBeRowWidth
            } else {
                if !currentRow.isEmpty {
                    organizedRows.append(currentRow)
                }
                currentRow = [subviewInfo]
                currentRowWidth = subviewSize.width
            }
        }

        if !currentRow.isEmpty {
            organizedRows.append(currentRow)
        }

        return organizedRows
    }

    private func placeRowsInBounds(
        rows: [[SubviewLayoutInfo]],
        bounds: CGRect,
        proposal: ProposedViewSize
    ) {
        var currentYPosition = bounds.origin.y

        for row in rows {
            let rowWidth = calculateRowWidth(row: row)
            let rowStartX = calculateRowStartX(
                rowWidth: rowWidth,
                bounds: bounds
            )

            placeRow(
                row: row,
                startX: rowStartX,
                yPosition: currentYPosition,
                proposal: proposal
            )

            let maxRowHeight = row.map { $0.size.height }.max() ?? 0
            currentYPosition += maxRowHeight + spacing
        }
    }

    private func placeRow(
        row: [SubviewLayoutInfo],
        startX: CGFloat,
        yPosition: CGFloat,
        proposal: ProposedViewSize
    ) {
        var currentXPosition = startX

        for subviewInfo in row {
            let position = CGPoint(x: currentXPosition, y: yPosition)
            subviewInfo.subview.place(at: position, proposal: proposal)
            currentXPosition += subviewInfo.size.width + spacing
        }
    }

    private func calculateRowWidthIfAddingSubview(
        currentRowWidth: CGFloat,
        subviewWidth: CGFloat,
        isFirstSubview: Bool
    ) -> CGFloat {
        let spacingForNewSubview = isFirstSubview ? 0 : spacing
        return currentRowWidth + spacingForNewSubview + subviewWidth
    }

    private func canFitSubviewInCurrentRow(
        wouldBeRowWidth: CGFloat,
        availableWidth: CGFloat,
        isFirstSubview: Bool
    ) -> Bool {
        return wouldBeRowWidth <= availableWidth || isFirstSubview
    }

    private func calculateRowWidth(row: [SubviewLayoutInfo]) -> CGFloat {
        let subviewsWidth = row.reduce(0) { $0 + $1.size.width }
        let spacingWidth = CGFloat(max(0, row.count - 1)) * spacing
        return subviewsWidth + spacingWidth
    }

    private func calculateRowStartX(rowWidth: CGFloat, bounds: CGRect) -> CGFloat {
        switch rowAlignment {
        case .leading:
            return bounds.minX
        case .center:
            return bounds.minX + (bounds.width - rowWidth) / 2
        case .trailing:
            return bounds.maxX - rowWidth
        }
    }

    private func calculateVerticalSpacing(for rowCount: Int) -> CGFloat {
        let spacingBetweenRows = CGFloat(max(0, rowCount - 1))
        return spacingBetweenRows * spacing
    }

    private struct SubviewLayoutInfo {
        let subview: LayoutSubview
        let size: CGSize
    }
}
