import 'package:flutter/material.dart';
import 'package:ai_based_farmer_query_app/models/advisory_model.dart';
import 'package:ai_based_farmer_query_app/theme/app_colors.dart';

class AdvisoryCard extends StatelessWidget {
  final AdvisoryModel advisory;
  final VoidCallback onTap;

  const AdvisoryCard({
    super.key,
    required this.advisory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isAlert = advisory.title.toLowerCase().contains('alert');
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 4,
          height: double.infinity,
          decoration: BoxDecoration(
            color: isAlert ? Colors.redAccent : AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              advisory.cropType.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              advisory.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            advisory.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black54),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            advisory.weatherCondition,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
          ),
        ),
      ),
    );
  }
}