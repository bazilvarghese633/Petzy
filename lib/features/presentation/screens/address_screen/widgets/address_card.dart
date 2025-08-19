import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/address.dart';
import 'package:petzy/features/presentation/bloc/address_bloc.dart';
import 'package:petzy/features/presentation/bloc/address_event.dart';

class AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;

  const AddressCard({super.key, required this.address, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: whiteColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (address.isSelected)
              Row(
                children: const [
                  Text(
                    "Default:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.verified, color: primaryColor, size: 18),
                ],
              ),
            const SizedBox(height: 6),
            Text(
              address.name.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: appTitleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              address.houseName,
              style: const TextStyle(color: Colors.black87),
            ),
            Text(
              '${address.town}, ${address.district}',
              style: const TextStyle(color: Colors.black87),
            ),
            Text(
              '${address.state}, ${address.country} ${address.pincode}',
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              'Phone: ${address.phone}',
              style: const TextStyle(color: Colors.black54),
            ),
            if (address.instructions.isEmpty)
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(foregroundColor: primaryColor),
                child: const Text("Add delivery instructions"),
              )
            else
              Text(
                'Instructions: ${address.instructions}',
                style: const TextStyle(color: Colors.black87),
              ),
            const Divider(thickness: 0.8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                  ),
                  onPressed: onEdit,
                  child: const Text("Edit"),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  onPressed:
                      () => context.read<AddressBloc>().add(
                        DeleteAddress(address.id),
                      ),
                  child: const Text("Remove"),
                ),
                if (!address.isSelected)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                    ),
                    onPressed:
                        () => context.read<AddressBloc>().add(
                          SelectAddress(address.id),
                        ),
                    child: const Text("Set as Default"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
