// import 'package:blood_link/themes/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:khalti_flutter/khalti_flutter.dart';

// class DonationPage
//     extends StatefulWidget {
//   const DonationPage(
//       {super.key});

//   @override
//   State<DonationPage> createState() =>
//       _DonationPageState();
// }

// class _DonationPageState
//     extends State<DonationPage> {
//   final TextEditingController
//       _amountController =
//       TextEditingController();

//   void
//       _startPayment() {
//     final int?
//         amount =
//         int.tryParse(_amountController.text);

//     if (amount != null &&
//         amount > 0) {
//       KhaltiScope.of(context).pay(
//         config: PaymentConfig(
//           amount: amount * 100, // Convert to paisa
//           productIdentity: 'donation-001',
//           productName: 'Blood Donation',
//         ),
//         preferences: [
//           PaymentPreference.khalti
//         ],
//         onSuccess: (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Payment Successful! Token: ${success.token}')),
//           );
//         },
//         onFailure: (failure) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Payment Failed: ${failure.message}')),
//           );
//         },
//         onCancel: () {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Payment Cancelled')),
//           );
//         },
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Enter a valid amount')),
//       );
//     }
//   }

//   @override
//   Widget
//       build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: MyColors.backgroundColor,
//       appBar: AppBar(
//         title: const Text(
//           'Donate with Khalti',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: MyColors.primaryColor,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               TextField(
//                 controller: _amountController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(labelText: 'Enter amount in NPR'),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: MyColors.primaryColor,
//                 ),
//                 onPressed: _startPayment,
//                 child: const Text('Donate with Khalti', style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
