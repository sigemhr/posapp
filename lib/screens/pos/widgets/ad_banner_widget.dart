import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/module_provider.dart';

class AdBannerWidget extends StatelessWidget {
  final VoidCallback? onRemoveAdsPressed;

  const AdBannerWidget({super.key, this.onRemoveAdsPressed});

  @override
  Widget build(BuildContext context) {
    final moduleProvider = context.watch<ModuleProvider>();

    if (!moduleProvider.hasAds) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        border: Border(top: BorderSide(color: Color(0xFFCBD5E1))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF94A3B8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'ANUNCIO',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '¡Surtidor de Abarrotes! Los mejores precios por mayoreo.',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRemoveAdsPressed,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Quitar (\$99)',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
