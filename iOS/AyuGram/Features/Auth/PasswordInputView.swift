import SwiftUI

struct PasswordInputView: View {
    @Environment(AuthViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "key.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            Text("Двухфакторная аутентификация")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            SecureField("Пароль", text: $vm.password)
                .textContentType(.password)
                .padding()
                .glassEffect(.regular.tint(.clear))
                .padding(.horizontal)

            if let error = vm.errorMessage {
                Text(error).foregroundStyle(.red).font(.caption)
            }

            Button {
                Task { await vm.sendPassword() }
            } label: {
                Group {
                    if vm.isLoading { ProgressView() }
                    else { Text("Войти").frame(maxWidth: .infinity) }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.password.isEmpty || vm.isLoading)
            .padding(.horizontal)

            Spacer()
        }
    }
}
