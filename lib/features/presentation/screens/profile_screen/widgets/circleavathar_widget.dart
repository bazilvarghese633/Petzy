import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;

  const UserAvatar({super.key, this.photoUrl, this.radius = 30});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child:
          photoUrl == null
              ? const Icon(Icons.person, size: 30, color: Colors.grey)
              : null,
    );
  }
}
