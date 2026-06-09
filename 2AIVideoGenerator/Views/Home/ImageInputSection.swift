import PhotosUI
import SwiftUI

struct ImageInputSection: View {
    @Bindable var viewModel: HomeViewModel

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showCameraUnavailableAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.createSelectImage)
                .font(.caption.weight(.semibold))
                .tracking(1)
                .foregroundStyle(AppColors.textSecondary)

            if let image = viewModel.selectedImage {
                selectedImagePreview(image)
            } else {
                emptyImagePicker
            }
        }
        .photosPicker(
            isPresented: $viewModel.showPhotoLibrary,
            selection: $selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task { await loadImage(from: newItem) }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraImagePicker(
                onImagePicked: { image in
                    viewModel.setSelectedImage(image)
                    showCamera = false
                },
                onCancel: {
                    showCamera = false
                }
            )
            .ignoresSafeArea()
        }
        .alert(L10n.createCameraUnavailable, isPresented: $showCameraUnavailableAlert) {
            Button(L10n.done, role: .cancel) {}
        } message: {
            Text(L10n.createCameraUnavailableMessage)
        }
    }

    private var emptyImagePicker: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 36))
                .foregroundStyle(AppColors.textSecondary.opacity(0.6))

            Text(L10n.createImagePickerHint)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                pickerButton(
                    title: L10n.createChooseFromLibrary,
                    icon: "photo.fill",
                    isPrimary: false
                ) {
                    viewModel.showPhotoLibrary = true
                }

                pickerButton(
                    title: L10n.createTakePhoto,
                    icon: "camera.fill",
                    isPrimary: true
                ) {
                    openCamera()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 16)
        .background(AppColors.surface)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .stroke(AppColors.border.opacity(0.4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous))
    }

    private func selectedImagePreview(_ image: UIImage) -> some View {
        VStack(spacing: 12) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous))

            HStack(spacing: 12) {
                pickerButton(
                    title: L10n.createChangeImage,
                    icon: "photo.fill",
                    isPrimary: false
                ) {
                    viewModel.showPhotoLibrary = true
                }

                pickerButton(
                    title: L10n.createTakePhoto,
                    icon: "camera.fill",
                    isPrimary: false
                ) {
                    openCamera()
                }

                Button {
                    viewModel.clearSelectedImage()
                    selectedPhotoItem = nil
                } label: {
                    Image(systemName: "trash")
                        .font(.body)
                        .foregroundStyle(.red.opacity(0.85))
                        .frame(width: 44, height: 44)
                        .background(AppColors.surfaceElevated)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func pickerButton(
        title: String,
        icon: String,
        isPrimary: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(isPrimary ? .white : AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isPrimary
                    ? AnyShapeStyle(AppColors.gradientPrimary)
                    : AnyShapeStyle(AppColors.surfaceElevated)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func openCamera() {
        guard CameraAvailability.isAvailable else {
            showCameraUnavailableAlert = true
            return
        }
        showCamera = true
    }

    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        viewModel.setSelectedImage(image)
    }
}
