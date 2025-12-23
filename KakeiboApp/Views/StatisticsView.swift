import SwiftUI
import Charts

struct StatisticsView: View {
    @ObservedObject var viewModel: TransactionViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 今月のサマリー
                    VStack(spacing: 15) {
                        Text("今月の収支")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            StatCard(
                                title: "収入",
                                amount: viewModel.currentMonthIncome,
                                color: .green,
                                icon: "arrow.down.circle.fill"
                            )
                            
                            StatCard(
                                title: "支出",
                                amount: viewModel.currentMonthExpense,
                                color: .red,
                                icon: "arrow.up.circle.fill"
                            )
                        }
                        
                        StatCard(
                            title: "差額",
                            amount: viewModel.currentMonthIncome - viewModel.currentMonthExpense,
                            color: (viewModel.currentMonthIncome - viewModel.currentMonthExpense) >= 0 ? .green : .red,
                            icon: "equal.circle.fill"
                        )
                    }
                    .padding()
                    
                    // カテゴリ別支出
                    if !viewModel.expensesByCategory().isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("カテゴリ別支出")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            // 円グラフ
                            Chart(viewModel.expensesByCategory(), id: \.category) { item in
                                SectorMark(
                                    angle: .value("金額", item.amount),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 1.5
                                )
                                .foregroundStyle(by: .value("カテゴリ", item.category.rawValue))
                                .annotation(position: .overlay) {
                                    Text(item.category.icon)
                                        .font(.title3)
                                }
                            }
                            .frame(height: 300)
                            .padding()
                            
                            // カテゴリリスト
                            ForEach(viewModel.expensesByCategory(), id: \.category) { item in
                                CategoryExpenseRow(
                                    category: item.category,
                                    amount: item.amount,
                                    percentage: item.amount / viewModel.currentMonthExpense * 100
                                )
                            }
                        }
                        .padding(.vertical)
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "chart.pie")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            Text("今月の支出データがありません")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("統計")
        }
    }
}

struct StatCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("¥\(Int(amount))")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct CategoryExpenseRow: View {
    let category: Category
    let amount: Double
    let percentage: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(category.icon)
                    .font(.title3)
                
                Text(category.rawValue)
                    .font(.headline)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("¥\(Int(amount))")
                        .font(.headline)
                    Text("\(Int(percentage))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * (percentage / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
        .padding(.horizontal)
    }
}

#Preview {
    StatisticsView(viewModel: TransactionViewModel())
}
