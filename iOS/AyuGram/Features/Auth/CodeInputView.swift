import SwiftUI

struct CodeInputView: View {
    @Environment(AuthViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            Text("Код подтверждения")
                .font(.title2.bold())

            Text("Введите код из Telegram")
                .foregroundStyle(.secondary)

            TextField("12345", text: $vm.code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .multilineTextAlignment(.center)
                .font(.title.monospacedDigit())
                .padding()
                .glassEffect(.regular.tint(.clear))
                .padding(.horizontal)

            if let error = vm.errorMessage {
                Text(error).foregroundStyle(.red).font(.caption)
            }

            Button {
                Task { await vm.sendCode() }
            } label: {
                Group {
                    if vm.isLoading { ProgressView() }
                    else { Text("Подтвердить").frame(maxWidth: .infinity) }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.code.isEmpty || vm.isLoading)
            .padding(.horizontal)

            Spacer()
        }
    }
}
