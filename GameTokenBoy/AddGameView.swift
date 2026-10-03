import SwiftUI

struct AddGameView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (String, URL, URL?) -> Void

    @State private var name = ""
    @State private var urlText = ""
    @State private var coverText = ""
    @State private var errorMessage: String?

    private var gameURL: URL? { Self.validHTTPSURL(urlText) }

    var body: some View {
        NavigationStack {
            Form {
                Section("ข้อมูลเกม") {
                    TextField("ชื่อเกม", text: $name)
                        .textInputAutocapitalization(.words)
                    TextField("ลิงก์เกม (HTTPS)", text: $urlText)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("ลิงก์รูปปก (ไม่บังคับ)", text: $coverText)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("เพิ่มเกม")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("ยกเลิก") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("บันทึก") { saveGame() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || gameURL == nil)
                }
            }
        }
    }

    private func saveGame() {
        guard let gameURL else {
            errorMessage = "กรุณาใส่ลิงก์เกมที่ขึ้นต้นด้วย https://"
            return
        }

        onAdd(
            name.trimmingCharacters(in: .whitespacesAndNewlines),
            gameURL,
            Self.validHTTPSURL(coverText)
        )
        dismiss()
    }

    private static func validHTTPSURL(_ value: String) -> URL? {
        guard let url = URL(string: value.trimmingCharacters(in: .whitespacesAndNewlines)),
              url.scheme?.lowercased() == "https",
              url.host != nil else { return nil }
        return url
    }
}
