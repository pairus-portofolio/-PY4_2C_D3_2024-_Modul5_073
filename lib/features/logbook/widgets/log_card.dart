import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logbook_app_073/features/logbook/models/log_model.dart';
import 'package:logbook_app_073/features/logbook/widgets/log_constants.dart';

class AnimatedLogCard extends StatefulWidget {
  final LogModel log;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final int index;

  final bool canEdit;
  final bool canDelete;

  const AnimatedLogCard({
    super.key,
    required this.log,
    required this.onTap,
    required this.onDelete,
    required this.index,
    this.canEdit = true,
    this.canDelete = true,
  });

  @override
  State<AnimatedLogCard> createState() => _AnimatedLogCardState();
}

class _AnimatedLogCardState extends State<AnimatedLogCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDateTime(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'baru saja';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} menit yang lalu';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari yang lalu';
      } else {
        return DateFormat('dd MMM yyyy', 'id_ID').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color =
        kCategoryColors[widget.log.category] ?? const Color(0xFF27AE60);
    final bgColor =
        kCategoryBgColors[widget.log.category] ?? const Color(0xFFEAFAF1);
    final icon = kCategoryIcons[widget.log.category] ?? Icons.note_outlined;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, bgColor.withOpacity(0.3)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: widget.onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Enhanced Icon Container
                        Hero(
                          tag: 'icon_${widget.log.id}',
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [color.withOpacity(0.8), color],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  spreadRadius: 0,
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(icon, color: Colors.white, size: 28),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Animated Badge
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 600),
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            widget.log.category.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: color,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const Spacer(),
                                  // Time and Sync status
                                  Row(
                                    children: [
                                      // 👁️ Visibility Icon
                                      Icon(
                                        widget.log.isPublic
                                            ? Icons.public_rounded
                                            : Icons.lock_outline_rounded,
                                        size: 14,
                                        color: widget.log.isPublic
                                            ? Colors.blue[400]
                                            : Colors.grey[500],
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        widget.log.isSynced
                                            ? Icons.cloud_done_rounded
                                            : Icons.cloud_off_rounded,
                                        size: 14,
                                        color: widget.log.isSynced
                                            ? Colors.blue[300]
                                            : Colors.orange[300],
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDateTime(widget.log.date),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.log.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.log.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Delete button
                        Visibility(
                          visible: widget.canDelete,
                          child: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.red[400],
                                size: 20,
                              ),
                            ),
                            onPressed: widget.onDelete,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
