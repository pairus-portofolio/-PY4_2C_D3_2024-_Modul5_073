import 'package:flutter/material.dart';

class LogEmptyState extends StatelessWidget {
  final bool isSearching;

  const LogEmptyState({super.key, required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LogIllustrationWidget(isSearching: isSearching),
            const SizedBox(height: 28),
            Text(
              isSearching ? 'Catatan Tidak Ditemukan' : 'Belum Ada Catatan',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              isSearching
                  ? 'Coba gunakan kata kunci yang berbeda.'
                  : 'Tekan tombol "Tambah" di bawah untuk membuat catatan pertamamu!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class LogIllustrationWidget extends StatelessWidget {
  final bool isSearching;

  const LogIllustrationWidget({super.key, required this.isSearching});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withValues(alpha: 0.07),
          ),
        ),
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withValues(alpha: 0.12),
          ),
        ),
        Icon(
          isSearching ? Icons.search_off_rounded : Icons.edit_note_rounded,
          size: 80,
          color: primary.withValues(alpha: 0.55),
        ),
      ],
    );
  }
}
