import SwiftUI

struct PhoneInputView: View {
    @Environment(AuthViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "paperplane.fill")
                .font(.system(size: 72))
                .foregroundStyle(.tint)
                .symbolEffect(.bounce, value: vm.isLoading)

            Text("AyuGram")
                .font(.largeTitle.bold())

            Text("Введите номер телефона")
                .foregroundStyle(.secondary)

            TextField("+7 999 000 00 00", text: $vm.phoneNumber)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .padding()
                .glassEffect(.regular.tint(.clear))
                .padding(.horizontal)

            if let error = vm.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Button {
                Task { await vm.sendPhone() }
            } label: {
                Group {
                    if vm.isLoading {
                        ProgressView()
                    } else {
                        Text("Далее")
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.phoneNumber.isEmpty || vm.isLoading)
            .padding(.horizontal)

            Spacer()
        }
        .navigationBarHidden(true)
    }
}
