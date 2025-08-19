import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';

class TransactionHistoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const TransactionHistoryWidget({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length > 5 ? 5 : transactions.length,
            separatorBuilder:
                (context, index) =>
                    Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionTile(transaction);
            },
          ),
        ),
        if (transactions.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to full transaction history
                },
                child: Text(
                  'View All Transactions',
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> transaction) {
    final isCredit = transaction['type'] == 'credit';
    final amount = transaction['amount']?.toString() ?? '0';
    final description = transaction['description'] ?? 'Transaction';
    final createdAt = transaction['createdAt']; // This is now a DateTime object

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isCredit
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isCredit ? Icons.add : Icons.remove,
          color: isCredit ? Colors.green : Colors.red,
          size: 20,
        ),
      ),
      title: Text(
        description,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatTransactionDate(createdAt),
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
      trailing: Text(
        '${isCredit ? '+' : '-'}₹$amount',
        style: TextStyle(
          color: isCredit ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No Transactions Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  String _formatTransactionDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';

    try {
      DateTime date;
      if (timestamp is DateTime) {
        date = timestamp;
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return 'Unknown date';
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }
}
