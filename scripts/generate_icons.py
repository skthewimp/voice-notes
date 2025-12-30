#!/usr/bin/env python3
"""
Generate app icons for NotesServer (macOS) and VoiceNotes (iOS)
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_icon(size, output_path):
    """Create a single app icon with microphone and sound waves design"""
    # Create image with gradient background
    img = Image.new('RGB', (size, size), '#1E3A8A')  # Deep blue
    draw = ImageDraw.Draw(img)

    # Add gradient effect
    for i in range(size):
        alpha = i / size
        color = (
            int(30 + (59 - 30) * alpha),    # R: 30 -> 59
            int(58 + (130 - 58) * alpha),   # G: 58 -> 130
            int(138 + (246 - 138) * alpha)  # B: 138 -> 246
        )
        draw.rectangle([(0, i), (size, i+1)], fill=color)

    # Draw microphone
    center_x = size // 2
    center_y = size // 2

    # Microphone body (rounded rectangle)
    mic_width = size // 4
    mic_height = size // 3
    mic_x = center_x - mic_width // 2
    mic_y = center_y - mic_height // 2 - size // 10

    draw.rounded_rectangle(
        [mic_x, mic_y, mic_x + mic_width, mic_y + mic_height],
        radius=mic_width // 3,
        fill='#FFFFFF',
        outline='#E5E7EB',
        width=max(1, size // 100)
    )

    # Microphone base
    base_width = mic_width // 2
    base_height = size // 12
    base_x = center_x - base_width // 2
    base_y = mic_y + mic_height + size // 30

    draw.rectangle(
        [base_x, base_y, base_x + base_width, base_y + base_height],
        fill='#FFFFFF'
    )

    # Microphone stand
    stand_width = size // 40
    stand_height = size // 8
    stand_x = center_x - stand_width // 2
    stand_y = base_y + base_height

    draw.rectangle(
        [stand_x, stand_y, stand_x + stand_width, stand_y + stand_height],
        fill='#FFFFFF'
    )

    # Sound waves (arcs on both sides)
    wave_color = '#60A5FA'  # Light blue
    wave_width = max(2, size // 50)

    # Left waves
    for i in range(2):
        offset = (i + 1) * size // 8
        y_offset = i * size // 16
        draw.arc(
            [mic_x - offset, mic_y + y_offset, mic_x, mic_y + mic_height - y_offset],
            start=90,
            end=270,
            fill=wave_color,
            width=wave_width
        )

    # Right waves
    for i in range(2):
        offset = (i + 1) * size // 8
        y_offset = i * size // 16
        draw.arc(
            [mic_x + mic_width, mic_y + y_offset, mic_x + mic_width + offset, mic_y + mic_height - y_offset],
            start=270,
            end=90,
            fill=wave_color,
            width=wave_width
        )

    # Save image
    img.save(output_path, 'PNG')
    print(f"✅ Created {size}x{size} icon: {output_path}")


def main():
    # Create output directories
    os.makedirs('/Users/Karthik/Documents/work/NotesAgent/icons/macos', exist_ok=True)
    os.makedirs('/Users/Karthik/Documents/work/NotesAgent/icons/ios', exist_ok=True)

    # macOS icon sizes for .icns
    macos_sizes = [16, 32, 64, 128, 256, 512, 1024]

    print("🎨 Generating macOS icons...")
    for size in macos_sizes:
        output_path = f'/Users/Karthik/Documents/work/NotesAgent/icons/macos/icon_{size}x{size}.png'
        create_icon(size, output_path)

        # Also create @2x versions
        if size <= 512:
            output_path_2x = f'/Users/Karthik/Documents/work/NotesAgent/icons/macos/icon_{size}x{size}@2x.png'
            create_icon(size * 2, output_path_2x)

    # iOS icon sizes
    ios_sizes = [
        (20, 1), (20, 2), (20, 3),      # Notification
        (29, 1), (29, 2), (29, 3),      # Settings
        (40, 1), (40, 2), (40, 3),      # Spotlight
        (60, 2), (60, 3),                # App Icon (iPhone)
        (76, 1), (76, 2),                # App Icon (iPad)
        (83.5, 2),                       # App Icon (iPad Pro)
        (1024, 1)                        # App Store
    ]

    print("\n🎨 Generating iOS icons...")
    for base_size, scale in ios_sizes:
        actual_size = int(base_size * scale)
        output_path = f'/Users/Karthik/Documents/work/NotesAgent/icons/ios/icon_{base_size}x{base_size}@{scale}x.png'
        create_icon(actual_size, output_path)

    print("\n✅ All icons generated!")
    print("\n📦 Next steps:")
    print("1. Create macOS .icns file:")
    print("   cd /Users/Karthik/Documents/work/NotesAgent/icons/macos")
    print("   iconutil -c icns -o AppIcon.icns .")
    print("\n2. Add icons to Xcode projects")


if __name__ == "__main__":
    main()
