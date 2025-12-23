import SwiftUI

struct AddTransactionView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: Category = .food
    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var date: Date = Date()
    
    var availableCategories: [Category] {
        selectedType == .income ? Category.incomeCategories : Category.expenseCategories
    }
    
    var body: some View {
        NavigationView {
            Form {
                // タイプ選択
                Section(header: Text("タイプ")) {
                    Picker("タイプ", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedType) { oldValue, newValue in
                        // タイプが変更されたら、最初のカテゴリを選択
                        selectedCategory = availableCategories.first ?? .food
                    }
                }
                
                // カテゴリ選択
                Section(header: Text("カテゴリ")) {
                    Picker("カテゴリ", selection: $selectedCategory) {
                        ForEach(availableCategories, id: \.self) { category in
                            HStack {
                                Text(category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // 金額入力
                Section(header: Text("金額")) {
                    HStack {
                        Text("¥")
                            .foregroundColor(.secondary)
                        TextField("0", text: $amount)
                            .keyboardType(.numberPad)
                            .font(.title2)
                    }
                }
                
                // 日付選択
                Section(header: Text("日付")) {
                    DatePicker("日付", selection: $date, displayedComponents: .date)
                }
                
                // メモ入力
                Section(header: Text("メモ（任意）")) {
                    TextEditor(text: $note)
                        .frame(height: 100)
                }
            }
            .navigationTitle("取引を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveTransaction()
                    }
                    .disabled(amount.isEmpty || Double(amount) == nil)
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            return
        }
        
        let transaction = Transaction(
            type: selectedType,
            category: selectedCategory,
            amount: amountValue,
            date: date,
            note: note
        )
        
        viewModel.addTransaction(transaction)
        dismiss()
    }
}

#Preview {
    AddTransactionView(viewModel: TransactionViewModel())
}
