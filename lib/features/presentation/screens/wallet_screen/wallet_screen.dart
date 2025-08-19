import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/wallet_entity.dart';
import 'package:petzy/features/domain/repository/wallet_repository.dart';
import 'package:petzy/features/presentation/bloc/wallet_bloc.dart';
import 'package:petzy/features/presentation/screens/wallet_screen/widgets/transation_history_widget.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => WalletBloc(
            walletRepository: context.read<WalletRepository>(),
            firebaseAuth: FirebaseAuth.instance,
          )..add(LoadWallet()),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          leading: BackButton(),
          title: const Text(
            'My Wallet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: secondaryColor,
            ),
          ),
          backgroundColor: whiteColor,
          foregroundColor: appTitleColor,
          centerTitle: true,
          elevation: 1,
          actions: [
            BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                return IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: state is WalletLoading ? Colors.grey : primaryColor,
                  ),
                  onPressed:
                      state is WalletLoading
                          ? null
                          : () =>
                              context.read<WalletBloc>().add(RefreshWallet()),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            if (state is WalletLoading) {
              return Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            } else if (state is WalletLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<WalletBloc>().add(RefreshWallet());
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: _buildWalletContent(context, state.wallet),
              );
            } else if (state is WalletError) {
              return _buildErrorState(context, state.message);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildWalletContent(BuildContext context, WalletEntity wallet) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Wallet Balance Card
          _buildWalletBalanceCard(wallet),
          const SizedBox(height: 24),

          // Wallet Details Cards
          _buildWalletDetails(wallet),
          const SizedBox(height: 24),
          TransactionHistoryWidget(
            transactions:
                wallet.transactions ??
                [], // Assuming wallet entity has transactions
          ),
          const SizedBox(height: 24),
          // Quick Info Section
          _buildQuickInfo(),
        ],
      ),
    );
  }

  Widget _buildWalletBalanceCard(WalletEntity wallet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: whiteColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.wallet, color: whiteColor, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Wallet Balance',
                      style: TextStyle(
                        color: whiteColor.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '₹${wallet.balance.toStringAsFixed(2)}',
              style: TextStyle(
                color: whiteColor,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Available Balance',
              style: TextStyle(
                color: whiteColor.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: whiteColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.security, color: whiteColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Secure & Protected',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletDetails(WalletEntity wallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wallet Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDetailCard(
                'Wallet ID',
                '#${wallet.id.substring(wallet.id.length - 8).toUpperCase()}',
                Icons.credit_card,
                primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailCard(
                'User ID',
                '#${wallet.userId.substring(wallet.userId.length - 6).toUpperCase()}',
                Icons.person,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDetailCard(
                'Last Updated',
                _formatDate(wallet.lastUpdated),
                Icons.update,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailCard(
                'Status',
                'Active',
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: secondaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'How to use your wallet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            Icons.shopping_cart,
            'Use wallet balance to pay for orders instantly',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            Icons.refresh,
            'Get instant refunds when you cancel orders',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(Icons.security, 'Your wallet is secure and protected'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: redColor),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Wallet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: redColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: grey600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<WalletBloc>().add(LoadWallet());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: whiteColor,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
