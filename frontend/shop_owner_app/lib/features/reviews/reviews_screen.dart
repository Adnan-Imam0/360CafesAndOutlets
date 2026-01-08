import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'review_provider.dart';
import '../shops/shop_provider.dart';
import 'package:intl/intl.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shop = context.read<ShopProvider>().shop;
      if (shop != null) {
        context.read<ReviewProvider>().fetchShopReviews(shop['shop_id']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();
    final shop = context.watch<ShopProvider>().shop;

    if (shop == null) {
      return const Center(child: Text('Please select a shop first.'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Reviews')),
      body: reviewProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Header
                _buildStatsHeader(context, reviewProvider),

                // Review List
                Expanded(
                  child: reviewProvider.reviews.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.rate_review_outlined,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No reviews yet',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: reviewProvider.reviews.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final review = reviewProvider.reviews[index];
                            return _buildReviewCard(context, review);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsHeader(BuildContext context, ReviewProvider provider) {
    final avgRating = provider.averageRating;
    final total = provider.reviews.length;

    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 8),
                child: Text(
                  '/ 5.0',
                  style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < avgRating.round() ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 28,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '$total Customer Reviews',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Map<String, dynamic> review) {
    final date =
        DateTime.tryParse(review['created_at'] ?? '') ?? DateTime.now();
    final formattedDate = DateFormat('MMM d, yyyy').format(date);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
                child: Text(
                  (review['customer_name'] ?? 'A')[0].toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review['customer_name'] ?? 'Anonymous',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (review['rating'] ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 14,
                      );
                    }),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                formattedDate,
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'] ?? '',
            style: TextStyle(color: Colors.grey[700], height: 1.5),
          ),
        ],
      ),
    );
  }
}
