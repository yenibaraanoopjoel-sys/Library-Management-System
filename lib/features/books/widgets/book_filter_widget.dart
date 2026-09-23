import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/book_provider.dart';

/// Book filter and category sorting bar
class BookFilterWidget extends StatelessWidget {
  const BookFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProv = Provider.of<BookProvider>(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Category chips
          ...bookProv.categories.map((category) {
            final isSelected = bookProv.selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                onSelected: (_) => bookProv.setCategory(category),
              ),
            );
          }),
          const SizedBox(width: 8),
          // Availability toggle chip
          FilterChip(
            avatar: Icon(
              bookProv.onlyAvailable ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: bookProv.onlyAvailable ? Colors.white : AppColors.success,
            ),
            label: const Text('Available Only'),
            selected: bookProv.onlyAvailable,
            selectedColor: AppColors.success,
            labelStyle: TextStyle(
              color: bookProv.onlyAvailable ? Colors.white : null,
              fontWeight: bookProv.onlyAvailable ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            onSelected: (_) => bookProv.toggleAvailableOnly(),
          ),
        ],
      ),
    );
  }
}
