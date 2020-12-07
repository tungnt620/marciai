import SwiftUI
import ModelKit

struct GroupListCell: View {
  typealias CommitHandler = (String, String) -> Void
  let name: String
  let color: String
  let symbol: String
  let count: Int
  let editAction: () -> Void
  @State private var isHovering: Bool = false

  var body: some View {
    HStack {
      icon
      text
      Spacer()
      if isHovering {
        editButton(editAction)
      }
      numberOfWorkflows
    }
    .onHover(perform: { hovering in
      isHovering = hovering
    })
    .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
    .frame(minHeight: 36)
  }
}

// MARK: - Subviews

private extension GroupListCell {
  var icon: some View {
    Circle()
      .fill(Color(hex: color))
      .frame(width: 24, height: 24, alignment: .center)
      .overlay(
        Image(systemName: symbol)
          .renderingMode(.template)
          .foregroundColor(.white)
      )
  }

  var text: some View {
    Text(name)
      .foregroundColor(.primary)
      .lineSpacing(-2.0)
  }

  func editButton(_ action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Image(systemName: "ellipsis.circle")
        .foregroundColor(Color(.secondaryLabelColor))
    }
    .buttonStyle(PlainButtonStyle())
  }

  var numberOfWorkflows: some View {
    Text("\(count)")
      .foregroundColor(.secondary)
      .padding(.vertical, 2)
  }
}

// MARK: - Previews

struct GroupListCell_Previews: PreviewProvider, TestPreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    let group = ModelFactory().groupListCell()
    return GroupListCell(name: group.name,
                         color: group.color,
                         symbol: group.symbol,
                         count: group.workflows.count,
                         editAction: {})
      .frame(width: 300)
  }
}
