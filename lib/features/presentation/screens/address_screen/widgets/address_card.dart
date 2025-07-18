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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (address.isSelected)
              Row(
                children: const [
                  Text(
                    "Default:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.verified, color: primaryColor),
                ],
              ),
            const SizedBox(height: 6),
            Text(
              address.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(address.houseName),
            Text('${address.town}, ${address.district}'),
            Text('${address.state}, ${address.country} ${address.pincode}'),
            const SizedBox(height: 4),
            Text('Phone number: ${address.phone}'),
            if (address.instructions.isEmpty)
              TextButton(
                onPressed: onEdit,
                child: const Text("Add delivery instructions"),
              )
            else
              Text('Instructions: ${address.instructions}'),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(onPressed: onEdit, child: const Text("Edit")),
                OutlinedButton(
                  onPressed:
                      () => context.read<AddressBloc>().add(
                        DeleteAddress(address.id),
                      ),
                  child: const Text("Remove"),
                ),
                if (!address.isSelected)
                  OutlinedButton(
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
