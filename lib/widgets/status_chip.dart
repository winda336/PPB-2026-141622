import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/item_model.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.item});
  final ItemModel item;

  Color get _color {
    if (item.isSelesai) return AppTheme.selesai;
    return item.isHilang ? AppTheme.hilang : AppTheme.ditemukan;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        item.statusLabel,
        style: TextStyle(
            color: _color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}