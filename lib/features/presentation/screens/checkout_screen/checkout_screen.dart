import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/bloc/checkout_bloc.dart';
import 'package:petzy/features/presentation/screens/checkout_screen/widgets/checkout_body.dart';
import 'package:petzy/features/presentation/screens/checkout_screen/widgets/checkout_dialogs.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();

    final razorpay = context.read<CheckoutBloc>().razorpay;
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    final razorpay = context.read<CheckoutBloc>().razorpay;
    razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    context.read<CheckoutBloc>().add(PaymentSuccessMulti(response.paymentId!));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    context.read<CheckoutBloc>().add(
      PaymentFailedMulti(response.message ?? 'Payment failed'),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet: ${response.walletName}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'Checkout',
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
      body: BlocListener<CheckoutBloc, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutPaid) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => CheckoutSuccessDialog(orderIds: state.orderIds),
            );
          } else if (state is CheckoutError) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => CheckoutFailedDialog(message: state.message),
            );
          }
        },
        child: const CheckoutBody(),
      ),
    );
  }
}
