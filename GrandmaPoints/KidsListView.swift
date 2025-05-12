import SwiftUI

struct KidsListView: View {
    @State private var kids: [String] = UserDefaults.standard.stringArray(forKey: "kids") ?? []
    @State private var newKidName: String = ""
    @State private var showingAddAnimation = false
    @State private var selectedKid: String? = nil
    @State private var isDeleteMode = false
    @State private var kidToDelete: String? = nil
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Kids' Expense Tracker")
                        .font(AppTheme.titleStyle)
                        .foregroundColor(AppTheme.primaryColor)
                        .padding(.top)
                    
                    // Add a new kid
                    HStack {
                        TextField("Enter kid's name", text: $newKidName)
                            .textFieldStyle(RoundedTextFieldStyle())
                        
                        Button(action: {
                            withAnimation {
                                showingAddAnimation = true
                                addKid()
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(AppTheme.primaryColor)
                        }
                        .disabled(newKidName.isEmpty)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                    .padding(.horizontal)
                    
                    // List of Kids
                    if kids.isEmpty {
                        Spacer()
                        VStack {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 70))
                                .foregroundColor(AppTheme.secondaryColor.opacity(0.6))
                                .padding()
                            
                            Text("Add a child to get started")
                                .font(AppTheme.headlineStyle)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(kids, id: \.self) { kid in
                                    if isDeleteMode {
                                        KidCardDeleteView(name: kid, onDelete: {
                                            kidToDelete = kid
                                            showingDeleteAlert = true
                                        })
                                        .transition(.scale.combined(with: .opacity))
                                    } else {
                                        NavigationLink(destination: CalculationView(kidName: kid)) {
                                            KidCardView(name: kid)
                                                .transition(.scale.combined(with: .opacity))
                                        }
                                    }
                                }
                            }
                            .padding()
                            .animation(.spring(), value: kids)
                        }
                        
                        Spacer()
                        
                        // Delete button at bottom
                        if !kids.isEmpty {
                            Button(action: {
                                withAnimation {
                                    isDeleteMode.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: isDeleteMode ? "xmark.circle.fill" : "trash.fill")
                                    Text(isDeleteMode ? "Cancel" : "Delete Child")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isDeleteMode ? Color.blue : Color.red)
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(
                    destination: selectedKid.map { CalculationView(kidName: $0) },
                    isActive: Binding(
                        get: { selectedKid != nil },
                        set: { if !$0 { selectedKid = nil } }
                    )
                ) {
                    EmptyView()
                }
            )
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Confirm Deletion"),
                    message: Text("Are you sure you want to delete \(kidToDelete ?? "")?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let kid = kidToDelete {
                            deleteKid(kid: kid)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    // Add a new kid
    func addKid() {
        guard !newKidName.isEmpty else { return }
        
        withAnimation {
            kids.append(newKidName)
            UserDefaults.standard.set(kids, forKey: "kids")
            
            // Set the selected kid to the newly added kid
            selectedKid = newKidName
            newKidName = ""
            
            // Reset animation flag after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingAddAnimation = false
            }
        }
    }
    
    // Delete a kid
    func deleteKid(kid: String) {
        if let index = kids.firstIndex(of: kid) {
            withAnimation {
                kids.remove(at: index)
                UserDefaults.standard.set(kids, forKey: "kids")
                
                // If no more kids, exit delete mode
                if kids.isEmpty {
                    isDeleteMode = false
                }
            }
        }
    }
}

// Kid Card View
struct KidCardView: View {
    var name: String
    
    var body: some View {
        VStack {
            Circle()
                .fill(AppTheme.secondaryColor)
                .frame(width: 70, height: 70)
                .overlay(
                    Text(String(name.prefix(1)).uppercased())
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                )
            
            Text(name)
                .font(AppTheme.headlineStyle)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.cardColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

// Kid Card Delete View
struct KidCardDeleteView: View {
    var name: String
    var onDelete: () -> Void
    
    var body: some View {
        VStack {
            Circle()
                .fill(AppTheme.secondaryColor)
                .frame(width: 70, height: 70)
                .overlay(
                    Text(String(name.prefix(1)).uppercased())
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                )
            
            Text(name)
                .font(AppTheme.headlineStyle)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Button(action: onDelete) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Delete")
                }
                .foregroundColor(.white)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(Color.red)
                .cornerRadius(8)
            }
            .padding(.top, 5)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.cardColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red, lineWidth: 2)
        )
    }
}

#Preview {
    KidsListView()
}
