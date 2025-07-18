import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/domain/entity/address.dart';
import 'package:petzy/features/presentation/bloc/address_bloc.dart';
import 'package:petzy/features/presentation/bloc/address_event.dart';

class AddressFormDialog extends StatelessWidget {
  final Address? address;
  AddressFormDialog({super.key, this.address});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final _name = TextEditingController(text: address?.name ?? '');
    final _house = TextEditingController(text: address?.houseName ?? '');
    final _town = TextEditingController(text: address?.town ?? '');
    final _district = TextEditingController(text: address?.district ?? '');
    final _state = TextEditingController(text: address?.state ?? '');
    final _country = TextEditingController(text: address?.country ?? '');
    final _pin = TextEditingController(text: address?.pincode ?? '');
    final _phone = TextEditingController(text: address?.phone ?? '');
    final _note = TextEditingController(text: address?.instructions ?? '');

    return AlertDialog(
      title: Text(address == null ? 'Add Address' : 'Edit Address'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field("Full Name", _name, patternValidation: _nameValidator),
              _field("House/Building", _house),
              _field("Town", _town, patternValidation: _nameValidator),
              _field("District", _district, patternValidation: _nameValidator),
              _field("State", _state, patternValidation: _nameValidator),
              _field("Country", _country, patternValidation: _nameValidator),
              _field(
                "Pincode",
                _pin,
                number: true,
                patternValidation: _pinValidator,
              ),
              _field(
                "Phone",
                _phone,
                number: true,
                patternValidation: _phoneValidator,
              ),
              _field("Instructions (optional)", _note, required: false),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newAddress = Address(
                id: address?.id ?? '',
                name: _name.text.trim(),
                houseName: _house.text.trim(),
                town: _town.text.trim(),
                district: _district.text.trim(),
                state: _state.text.trim(),
                country: _country.text.trim(),
                pincode: _pin.text.trim(),
                phone: _phone.text.trim(),
                instructions: _note.text.trim(),
                isSelected: address?.isSelected ?? false,
              );

              if (address == null) {
                context.read<AddressBloc>().add(AddAddress(newAddress));
              } else {
                context.read<AddressBloc>().add(UpdateAddress(newAddress));
              }

              Navigator.pop(context);
            }
          },
          child: Text(address == null ? "Add" : "Update"),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    bool number = false,
    bool required = true,
    String? Function(String?)? patternValidation,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: ctrl,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (val) {
          if (required && (val == null || val.trim().isEmpty)) {
            return 'Please enter $label';
          }

          if (patternValidation != null) {
            return patternValidation(val);
          }

          return null;
        },
      ),
    );
  }

  String? _nameValidator(String? value) {
    final val = value?.trim() ?? '';
    if (val.length < 2) return 'Must be at least 2 characters';
    final regex = RegExp(r'^[a-zA-Z\s]+$');
    if (!regex.hasMatch(val)) return 'Only alphabets and spaces allowed';
    return null;
  }

  String? _phoneValidator(String? value) {
    final val = value?.trim() ?? '';
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(val)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _pinValidator(String? value) {
    final val = value?.trim() ?? '';
    final pinRegex = RegExp(r'^\d{6}$');
    if (!pinRegex.hasMatch(val)) {
      return 'Enter a valid 6-digit pincode';
    }
    return null;
  }
}
