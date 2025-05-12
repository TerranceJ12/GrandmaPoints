import SwiftUI

// Make sure this struct is defined at the top level, not inside the view
struct CalculationItem: Identifiable, Codable {
    var id = UUID()
    var label: String
    var price: Double
    var quantity: Int
    var date: String  // Stores date as "YYYY-MM-DD"

    var total: Double {
        price * Double(quantity)
    }
}

struct CalculationView: View {
    var kidName: String
    
    @State private var calculations: [CalculationItem] = []
    @State private var newLabel: String = ""
    @State private var newPrice: String = ""
    @State private var newQuantity: String = "1" // Default to 1
    @State private var selectedDate: Date = Date()
    @State private var expandedDays: Set<String> = []
    @State private var isAddingNew = false
    @State private var showDatePicker = false
    @State private var showingDeleteDayAlert = false
    @State private var dayToDelete: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var storageKey: String { "calculations_\(kidName)" }
    
    var groupedCalculations: [String: [CalculationItem]] {
        Dictionary(grouping: calculations) { $0.date }
    }
    
    var sortedDates: [String] {
        groupedCalculations.keys.sorted(by: >)
    }
    
    var totalPoints: Double {
        calculations.reduce(0) { $0 + $1.total }
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 5) {
                    Text(kidName)
                        .font(AppTheme.titleStyle)
                        .foregroundColor(AppTheme.primaryColor)
                    
                    Text("Total: $\(totalPoints, specifier: "%.2f")")
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundColor(AppTheme.secondaryColor)
                }
                .padding()
                
                // Add New Button
                Button(action: {
                    withAnimation {
                        isAddingNew.toggle()
                        if !isAddingNew {
                            // Reset date to today when closing form
                            selectedDate = Date()
                            showDatePicker = false
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: isAddingNew ? "xmark.circle.fill" : "plus.circle.fill")
                        Text(isAddingNew ? "Cancel" : "Add New Item")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isAddingNew ? Color.red.opacity(0.8) : AppTheme.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                .padding(.horizontal)
                
                // Input Form
                if isAddingNew {
                    VStack(spacing: 12) {
                        TextField("Label (e.g. 3-pointer, chores)", text: $newLabel)
                            .textFieldStyle(RoundedTextFieldStyle())
                        
                        HStack {
                            TextField("Price", text: $newPrice)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedTextFieldStyle())
                            
                            TextField("Qty", text: $newQuantity)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedTextFieldStyle())
                                .frame(width: 80)
                        }
                        
                        // Date selector button
                        Button(action: {
                            withAnimation {
                                showDatePicker.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "calendar")
                                Text(formatDate(selectedDate))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .rotationEffect(showDatePicker ? .degrees(180) : .degrees(0))
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Date picker
                        if showDatePicker {
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(10)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        Button("Add Item") {
                            addCalculation()
                        }
                        .buttonStyle(AppTheme.primaryButtonStyle())
                        .disabled(newLabel.isEmpty || newPrice.isEmpty)
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // List of Calculations
                if calculations.isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 70))
                            .foregroundColor(AppTheme.secondaryColor.opacity(0.6))
                            .padding()
                        
                        Text("No items yet")
                            .font(AppTheme.headlineStyle)
                            .foregroundColor(.gray)
                        
                        Text("Add an item to get started")
                            .font(AppTheme.bodyStyle)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(sortedDates, id: \.self) { date in
                            Section {
                                // Custom section header with expand/collapse and delete functionality
                                Button(action: {
                                    toggleSectionExpansion(date)
                                }) {
                                    HStack {
                                        Text(formatDateHeader(date))
                                            .font(.system(.headline, design: .rounded))
                                            .foregroundColor(AppTheme.primaryColor)
                                        
                                        Spacer()
                                        
                                        // Day total
                                        let dayTotal = groupedCalculations[date]?.reduce(0) { $0 + $1.total } ?? 0
                                        Text("$\(dayTotal, specifier: "%.2f")")
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(AppTheme.secondaryColor)
                                            .padding(.trailing, 8)
                                        
                                        // Expand/collapse indicator
                                        Image(systemName: expandedDays.contains(date) ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.gray)
                                        
                                        // Delete day button
                                        Button(action: {
                                            dayToDelete = date
                                            showingDeleteDayAlert = true
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.vertical, 5)
                                
                                // Show items only if section is expanded
                                if expandedDays.contains(date) {
                                    ForEach(groupedCalculations[date] ?? []) { item in
                                        CalculationItemView(item: item)
                                            .swipeActions {
                                                Button(role: .destructive) {
                                                    deleteCalculation(item)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
            .alert(isPresented: $showingDeleteDayAlert) {
                Alert(
                    title: Text("Delete Entire Day"),
                    message: Text("Are you sure you want to delete all items for \(formatDateHeader(dayToDelete))?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteDay(dayToDelete)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .onAppear(perform: loadStoredData)
    }
    
    // Toggle section expansion
    func toggleSectionExpansion(_ date: String) {
        withAnimation {
            if expandedDays.contains(date) {
                expandedDays.remove(date)
            } else {
                expandedDays.insert(date)
            }
        }
    }
    
    // Format date for DatePicker display
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // Format date for display in section headers
    func formatDateHeader(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: date)
        }
        return dateString
    }
    
    // Add a new calculation
    func addCalculation() {
        guard let price = Double(newPrice),
              let quantity = Int(newQuantity),
              !newLabel.isEmpty else { return }
        
        // Format the selected date to "YYYY-MM-DD"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        
        let newCalculation = CalculationItem(label: newLabel, price: price, quantity: quantity, date: dateString)
        
        withAnimation {
            calculations.append(newCalculation)
            saveData()
            
            // Make sure this day is expanded
            expandedDays.insert(dateString)
            
            // Clear input fields
            newLabel = ""
            newPrice = ""
            newQuantity = "1"
            
            // Close the form but keep date as is for possible next entry
            isAddingNew = false
            showDatePicker = false
        }
    }
    
    // Delete a calculation
    func deleteCalculation(_ item: CalculationItem) {
        if let index = calculations.firstIndex(where: { $0.id == item.id }) {
            withAnimation {
                calculations.remove(at: index)
                saveData()
                
                // If this was the last item for this day, close the section
                let date = item.date
                if groupedCalculations[date]?.isEmpty ?? true {
                    expandedDays.remove(date)
                }
            }
        }
    }
    
    // Delete an entire day of calculations
    func deleteDay(_ date: String) {
        withAnimation {
            calculations.removeAll(where: { $0.date == date })
            saveData()
            expandedDays.remove(date)
        }
    }
    
    // Save data
    func saveData() {
        if let encoded = try? JSONEncoder().encode(calculations) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    // Load stored data
    func loadStoredData() {
        if let savedData = UserDefaults.standard.data(forKey: storageKey) {
            // Fix the error by using explicit type annotation
            let decodedItems = try? JSONDecoder().decode([CalculationItem].self, from: savedData)
            calculations = decodedItems ?? []
        }
        
        // Expand today's section automatically
        expandedDays.insert(getCurrentDate())
    }
    
    // Get current date in "YYYY-MM-DD" format
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

// Calculation Item View Component
struct CalculationItemView: View {
    var item: CalculationItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.label)
                    .font(.system(.headline, design: .rounded))
                
                Text("Qty: \(item.quantity) × $\(item.price, specifier: "%.2f")")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(item.total, specifier: "%.2f")")
                .font(.system(.title3, design: .rounded).bold())
                .foregroundColor(AppTheme.primaryColor)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    CalculationView(kidName: "Sample Kid")
}
