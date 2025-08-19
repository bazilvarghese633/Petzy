import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';
import 'package:petzy/features/presentation/bloc/buy_now_bloc.dart';
import 'package:petzy/features/presentation/bloc/buy_now_event.dart';
import 'package:petzy/features/presentation/bloc/buy_now_state.dart';
import 'package:petzy/features/presentation/screens/buy_now/widgets/buy_now_payment_button.dart';
import 'package:petzy/features/presentation/screens/buy_now/widgets/buy_now_price_summary.dart';
import 'package:petzy/features/presentation/screens/buy_now/widgets/buy_now_product_card.dart';
import 'package:petzy/features/presentation/screens/buy_now/widgets/buy_now_quantity_selector.dart';
import 'package:petzy/features/presentation/screens/buy_now/widgets/buy_now_dialogs.dart'; // Add this import
import 'package:razorpay_flutter/razorpay_flutter.dart';

class BuyNowScreen extends StatefulWidget {
  final ProductEntity product;
  final int quantity;

  const BuyNowScreen({
    super.key,
    required this.product,
    required this.quantity,
  });

  @override
  State<BuyNowScreen> createState() => _BuyNowScreenState();
}

class _BuyNowScreenState extends State<BuyNowScreen> {
  late final Razorpay razorpay;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<BuyNowBloc>();
    razorpay = bloc.razorpay;
    razorpay
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    bloc.add(InitializeBuyNow(widget.product, widget.quantity));
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final bloc = context.read<BuyNowBloc>();
    final orderId = bloc.currentOrderId ?? response.orderId!;
    bloc.add(PaymentSuccess(response.paymentId!, orderId));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    context.read<BuyNowBloc>().add(
      PaymentFailed(response.message ?? 'Payment failed'),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Optional, handle if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'Buy Now',
          style: TextStyle(fontWeight: FontWeight.bold, color: secondaryColor),
        ),
        backgroundColor: whiteColor,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: secondaryColor,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<BuyNowBloc, BuyNowState>(
        listener: (context, state) {
          if (state is BuyNowPaymentSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => PaymentSuccessDialog(orderId: state.orderId),
            );
          } else if (state is BuyNowError) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => PaymentFailedDialog(message: state.message),
            );
          }
        },
        builder: (context, state) {
          if (state is BuyNowLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuyNowProductCard(product: state.product),
                  const SizedBox(height: 24),
                  BuyNowQuantitySelector(
                    product: state.product,
                    quantity: state.quantity,
                    onQuantityChanged:
                        (q) =>
                            context.read<BuyNowBloc>().add(UpdateQuantity(q)),
                  ),
                  const SizedBox(height: 24),
                  BuyNowPriceSummary(
                    product: state.product,
                    quantity: state.quantity,
                    totalAmount: state.totalAmount,
                  ),
                  const SizedBox(height: 32),
                  BuyNowPaymentButton(
                    onPressed:
                        () => context.read<BuyNowBloc>().add(
                          const ProcessPayment(),
                        ),
                    totalAmount: state.totalAmount,
                  ),
                ],
              ),
            );
          } else if (state is BuyNowProcessing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Processing payment...',
                    style: TextStyle(fontSize: 16, color: secondaryColor),
                  ),
                ],
              ),
            );
          }
          return Center(child: CircularProgressIndicator(color: primaryColor));
        },
      ),
    );
  }
}
