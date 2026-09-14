import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAvatar extends StatefulWidget {
  final String userKey;
  final String name;
  final String? networkPhotoUrl;

  final double radius;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  final bool editable;

  final Future<void> Function(File)? onImagePicked;

  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.userKey,
    required this.name,
    this.networkPhotoUrl,
    this.radius = 18,
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFF10B981),
    this.fontSize = 14,
    this.editable = false,
    this.onTap,
    this.onImagePicked,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  File? _localImage;
  bool _loading = true;
  bool _uploading = false;

  String get _prefsKey =>
      'profile_image_${widget.userKey}';

  @override
  void initState() {
    super.initState();
    _loadLocalImage();
  }

  @override
  void didUpdateWidget(
    covariant UserAvatar oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userKey != widget.userKey) {
      _localImage = null;
      _loading = true;
      _loadLocalImage();
    }
  }

  Future<void> _loadLocalImage() async {
    final prefs =
        await SharedPreferences.getInstance();

    final path = prefs.getString(_prefsKey);

    if (path != null && File(path).existsSync()) {
      _localImage = File(path);
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    if (_uploading) return;

    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );

    if (picked == null) return;

    final file = File(picked.path);

    if (mounted) {
      setState(() {
        _localImage = file;
        _uploading = true;
      });
    }

    try {
      if (widget.onImagePicked != null) {
        await widget.onImagePicked!(file);
      }

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        _prefsKey,
        picked.path,
      );
    } catch (e) {
      // Si l'upload échoue, on peut retirer
      // l'image locale temporaire.
      if (mounted) {
        setState(() {
          _localImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Impossible d'envoyer la photo : $e",
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }

  ImageProvider? get _imageProvider {
    if (_localImage != null) {
      return FileImage(_localImage!);
    }

    if (widget.networkPhotoUrl != null &&
        widget.networkPhotoUrl!.isNotEmpty) {
      return NetworkImage(
        widget.networkPhotoUrl!,
      );
    }

    return null;
  }

  String get _initial {
    if (widget.name.trim().isEmpty) {
      return '?';
    }

    return widget.name
        .trim()
        .substring(0, 1)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _imageProvider;

    final avatar = CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.backgroundColor,
      backgroundImage: imageProvider,
      child: _loading
          ? SizedBox(
              width: widget.radius * 0.6,
              height: widget.radius * 0.6,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : imageProvider == null
              ? Text(
                  _initial,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.bold,
                    color: widget.textColor,
                  ),
                )
              : null,
    );

    if (!widget.editable) {
      return GestureDetector(
        onTap: widget.onTap,
        child: avatar,
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,

          if (_uploading)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}