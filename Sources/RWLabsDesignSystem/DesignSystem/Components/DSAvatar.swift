//
//  DSAvatar.swift
//  RWLDesignSystem
//
//  User avatar with initials fallback and status indicator
//

import SwiftUI

// MARK: - DSAvatar

public struct DSAvatar: View {
    let imageURL: URL?
    let imageName: String?
    let initials: String?
    let size: AvatarSize
    let status: StatusIndicator?
    let aspectRatio: ContentMode

    public init(
        imageURL: URL? = nil,
        imageName: String? = nil,
        initials: String? = nil,
        size: AvatarSize = .medium,
        status: StatusIndicator? = nil,
        aspectRatio: ContentMode = .fit
    ) {
        self.imageURL = imageURL
        self.imageName = imageName
        self.initials = initials
        self.size = size
        self.status = status
        self.aspectRatio = aspectRatio
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Avatar content
            Group {
                if let imageURL = imageURL {
                    CachedAsyncImage(url: imageURL, aspectRatio: aspectRatio) {
                            initialsView
                        }
                }
                else if let imageName = imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .aspectRatio(contentMode: .fit)
                }
                else {
                    initialsView
                }
            }
            .frame(width: size.diameter, height: size.diameter)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.Border.default, lineWidth: 1)
            )

            // Status indicator
            if let status = status {
                Circle()
                    .fill(status.color)
                    .frame(width: size.statusSize, height: size.statusSize)
                    .overlay(
                        Circle()
                            .stroke(Color.Background.primary, lineWidth: 2)
                    )
                    .offset(x: 2, y: 2)
            }
        }
    }

    private var initialsView: some View {
        ZStack {
            Circle()
                .fill(Color.Text.brand.opacity(0.1))

            Text(initials ?? "?")
                .font(.system(size: size.fontSize, weight: .medium))
                .foregroundColor(Color.Text.brand)
        }
    }

    public enum AvatarSize {
        case small
        case medium
        case large
        case xlarge

        var diameter: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 40
            case .large: return 56
            case .xlarge: return 80
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 20
            case .xlarge: return 28
            }
        }

        var statusSize: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 10
            case .large: return 12
            case .xlarge: return 16
            }
        }
    }

    public enum StatusIndicator {
        case online 
        case offline
        case away
        case busy

        @MainActor
        var color: Color {
            switch self {
            case .online: return Color.Semantic.success
            case .offline: return Color.Background.secondary
            case .away: return Color.Semantic.warning
            case .busy: return Color.Semantic.error
            }
        }
    }
}

// MARK: - Avatar Group

public struct DSAvatarGroup: View {
    let avatars: [AvatarData]
    let size: DSAvatar.AvatarSize
    let maxVisible: Int
    let spacing: CGFloat

    public init(
        avatars: [AvatarData],
        size: DSAvatar.AvatarSize = .medium,
        maxVisible: Int = 3,
        spacing: CGFloat = -8
    ) {
        self.avatars = avatars
        self.size = size
        self.maxVisible = maxVisible
        self.spacing = spacing
    }

    private var visibleAvatars: [AvatarData] {
        Array(avatars.prefix(maxVisible))
    }

    private var remainingCount: Int {
        max(0, avatars.count - maxVisible)
    }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(Array(visibleAvatars.enumerated()), id: \.offset) { _, avatar in
                DSAvatar(
                    imageURL: avatar.imageURL,
                    imageName: avatar.imageName,
                    initials: avatar.initials,
                    size: size
                )
            }

            if remainingCount > 0 {
                ZStack {
                    Circle()
                        .fill(Color.Background.secondary)

                    Text("+\(remainingCount)")
                        .font(.system(size: size.fontSize, weight: .medium))
                        .foregroundColor(Color.Text.primary)
                }
                .frame(width: size.diameter, height: size.diameter)
                .overlay(
                    Circle()
                        .stroke(Color.Border.default, lineWidth: 1)
                )
            }
        }
    }

    public struct AvatarData {
        public let imageURL: URL?
        public let imageName: String?
        public let initials: String?

        public init(imageURL: URL? = nil, imageName: String? = nil, initials: String? = nil) {
            self.imageURL = imageURL
            self.imageName = imageName
            self.initials = initials
        }
    }
}

// MARK: - Helper Extension

public extension String {
    var avatarInitials: String {
        let components = self.split(separator: " ")
        let initials = components.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }
}

// MARK: - Preview

#Preview("Avatar Sizes") {
    VStack(spacing: .xl) {
        HStack(spacing: .lg) {
            DSAvatar(initials: "JD", size: .small)
            DSAvatar(initials: "JD", size: .medium)
            DSAvatar(initials: "JD", size: .large)
            DSAvatar(initials: "JD", size: .xlarge)
        }

        Text("Sizes: Small, Medium, Large, XLarge")
            .fontStyle(.caption)
            .foregroundColor(Color.Text.secondary)
    }
    .padding()
}

#Preview("Avatar Status") {
    VStack(spacing: .xl) {
        HStack(spacing: .lg) {
            VStack {
                DSAvatar(initials: "JD", size: .large, status: .online)
                Text("Online")
                    .fontStyle(.caption)
            }

            VStack {
                DSAvatar(initials: "SM", size: .large, status: .offline)
                Text("Offline")
                    .fontStyle(.caption)
            }

            VStack {
                DSAvatar(initials: "KL", size: .large, status: .away)
                Text("Away")
                    .fontStyle(.caption)
            }

            VStack {
                DSAvatar(initials: "RM", size: .large, status: .busy)
                Text("Busy")
                    .fontStyle(.caption)
            }
        }
    }
    .padding()
}

#Preview("Avatar Group") {
    VStack(spacing: .xl) {
        DSAvatarGroup(
            avatars: [
                .init(initials: "JD"),
                .init(initials: "SM"),
                .init(initials: "KL"),
                .init(initials: "RM"),
                .init(initials: "AB")
            ],
            size: .medium,
            maxVisible: 3
        )

        Text("5 members")
            .fontStyle(.caption)
            .foregroundColor(Color.Text.secondary)
    }
    .padding()
}

#Preview("Initials from Name") {
    VStack(spacing: .lg) {
        DSAvatar(initials: "John Doe".avatarInitials, size: .large)
        DSAvatar(initials: "Sarah Miller".avatarInitials, size: .large)
        DSAvatar(initials: "Kim Lee".avatarInitials, size: .large)

        Text("Initials extracted from names")
            .fontStyle(.caption)
            .foregroundColor(Color.Text.secondary)
    }
    .padding()
}

protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}


final class TemporaryImageCache: ImageCache {
    private let cache = NSCache<NSURL, UIImage>()

    subscript(_ url: URL) -> UIImage? {
        get { cache.object(forKey: url as NSURL) }
        set {
            if let image = newValue {
                cache.setObject(image, forKey: url as NSURL)
            } else {
                cache.removeObject(forKey: url as NSURL)
            }
        }
    }
}

@MainActor
final class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private let url: URL
    private var cache: ImageCache

    init(url: URL, cache: ImageCache = TemporaryImageCache()) {
        self.url = url
        self.cache = cache
    }

    func load() async {
        if let cached = cache[url] {
            image = cached
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                cache[url] = uiImage
                image = uiImage
            }
        } catch {
            image = nil
        }
    }
}

struct CachedAsyncImage<Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    let aspectRatio: ContentMode
    private let placeholder: Placeholder

    init(
        url: URL,
        aspectRatio: ContentMode = .fit,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.aspectRatio = aspectRatio
        self.placeholder = placeholder()
    }

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: aspectRatio)
            } else {
                placeholder
            }
        }
        .task {
            await loader.load()
        }
    }
}
