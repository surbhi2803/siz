import 'package:flutter/material.dart';

class AvatarData {
  final String id;
  final int row;
  final int col;
  
  const AvatarData(this.id, this.row, this.col);
}

class AvatarPicker {
  // Avatar positions in the 3x3 grid
  static const List<AvatarData> avatars = [
    AvatarData('avatar_1', 0, 0), // Top-left: NY cap girl
    AvatarData('avatar_2', 0, 1), // Top-middle: Checkered shirt
    AvatarData('avatar_3', 0, 2), // Top-right: Orange cap boy
    AvatarData('avatar_4', 1, 0), // Middle-left: Curly hair girl
    AvatarData('avatar_5', 1, 1), // Middle-middle: Beanie boy
    AvatarData('avatar_6', 1, 2), // Middle-right: Yellow stripe girl
    AvatarData('avatar_7', 2, 0), // Bottom-left: Short hair girl (wink)
    AvatarData('avatar_8', 2, 1), // Bottom-middle: Glasses person
    AvatarData('avatar_9', 2, 2), // Bottom-right: Ponytail girl
  ];
}

class AvatarWidget extends StatelessWidget {
  final String avatarId;
  final double size;
  final BorderRadius? borderRadius;
  
  const AvatarWidget({
    super.key,
    required this.avatarId,
    this.size = 60,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    // Find the avatar data
    final avatar = AvatarPicker.avatars.firstWhere(
      (a) => a.id == avatarId,
      orElse: () => AvatarPicker.avatars[0],
    );
    
    // The image is a 3x3 grid, each cell is approximately 360x360 pixels
    // Total image: 1080x1080
    final double cellWidth = 1080 / 3;
    final double cellHeight = 1080 / 3;
    
    // Calculate the position to crop from
    final double left = avatar.col * cellWidth;
    final double top = avatar.row * cellHeight;
    
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: cellWidth,
            height: cellHeight,
            child: OverflowBox(
              minWidth: 1080,
              maxWidth: 1080,
              minHeight: 1080,
              maxHeight: 1080,
              child: Transform.translate(
                offset: Offset(-left, -top),
                child: Image.asset(
                  'assets/images/avatars.jpg',
                  width: 1080,
                  height: 1080,
                  fit: BoxFit.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Avatar selector widget for onboarding
class AvatarSelector extends StatelessWidget {
  final String? selectedAvatarId;
  final Function(String) onAvatarSelected;
  final bool includeCustomPhoto;
  
  const AvatarSelector({
    super.key,
    required this.selectedAvatarId,
    required this.onAvatarSelected,
    this.includeCustomPhoto = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final List<Widget> avatarWidgets = [];
    
    // Add custom photo option first if enabled
    if (includeCustomPhoto) {
      avatarWidgets.add(
        GestureDetector(
          onTap: () => onAvatarSelected('custom_photo'),
          child: Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: selectedAvatarId == 'custom_photo'
                  ? const Color(0xFFC8FF00)
                  : const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: selectedAvatarId == 'custom_photo'
                    ? const Color(0xFFC8FF00)
                    : const Color(0xFFE5E5E5),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(Icons.add_photo_alternate, size: 30, color: Color(0xFF666666)),
            ),
          ),
        ),
      );
    }
    
    // Add all avatar options
    for (final avatar in AvatarPicker.avatars) {
      final isSelected = selectedAvatarId == avatar.id;
      
      avatarWidgets.add(
        GestureDetector(
          onTap: () => onAvatarSelected(avatar.id),
          child: Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFC8FF00)
                    : const Color(0xFFE5E5E5),
                width: isSelected ? 3 : 2,
              ),
            ),
            child: AvatarWidget(
              avatarId: avatar.id,
              size: 60,
              borderRadius: BorderRadius.circular(13),
            ),
          ),
        ),
      );
    }
    
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: avatarWidgets,
      ),
    );
  }
}

