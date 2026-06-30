import 'package:flutter/material.dart';

class ActionCircleIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isLikeButton;

  const ActionCircleIcon({
    super.key,
    required this.icon,
    required this.onTap,
    this.isLikeButton = false,
  });

  @override
  State<ActionCircleIcon> createState() => _ActionCircleIconState();
}

class _ActionCircleIconState extends State<ActionCircleIcon>
    with SingleTickerProviderStateMixin {

  bool isLiked = false;
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(
      begin: 1.1, 
      end: 1.5,   
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  void _onTap() {
    if (widget.isLikeButton) {
      setState(() => isLiked = !isLiked);
      _controller.forward().then((_) => _controller.reverse());
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    const Color defaultColor = Color(0xFF0D47A1);
    final Color primaryColor = Colors.blue[900] ?? defaultColor;

    final Color iconColor = widget.isLikeButton
        ? (isLiked ? Colors.red : primaryColor)
        : primaryColor;

    final IconData iconData = widget.isLikeButton
        ? (isLiked ? Icons.favorite : Icons.favorite_border)
        : widget.icon;

    return GestureDetector(
      onTap: _onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ScaleTransition(
          scale: widget.isLikeButton ? _scale : const AlwaysStoppedAnimation(1.0),
          child: Icon(
            iconData,
            size: 20,
            color: iconColor,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}