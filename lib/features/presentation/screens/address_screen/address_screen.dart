import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/address.dart';
import 'package:petzy/features/presentation/bloc/address_bloc.dart';
import 'package:petzy/features/presentation/bloc/address_state.dart';
import 'package:petzy/features/presentation/bloc/cubit/search_cubit.dart';
import 'package:petzy/features/presentation/screens/address_screen/widgets/address_card.dart';
import 'package:petzy/features/presentation/screens/address_screen/widgets/address_form_dialog.dart';
import 'package:petzy/features/presentation/screens/search_screen/widgets/search_field.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  List<Address> _filterAddresses(List<Address> addresses, String query) {
    final lowerQuery = query.toLowerCase();
    return query.isEmpty
        ? addresses
        : addresses.where((address) {
          return address.name.toLowerCase().contains(lowerQuery) ||
              address.town.toLowerCase().contains(lowerQuery) ||
              address.houseName.toLowerCase().contains(lowerQuery) ||
              address.phone.contains(query);
        }).toList();
  }

  void _showAddressDialog(BuildContext context, {Address? address}) {
    showDialog(
      context: context,
      builder: (_) => AddressFormDialog(address: address),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(),
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: const Text(
            "Your Addresses",
            style: TextStyle(fontWeight: FontWeight.bold, color: brownColr),
          ),
          backgroundColor: whiteColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              BlocBuilder<SearchCubit, String>(
                builder: (context, query) {
                  return SearchField(
                    controller: TextEditingController(text: query)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: query.length),
                      ),
                    onChanged:
                        (value) =>
                            context.read<SearchCubit>().updateQuery(value),
                    onClear: () => context.read<SearchCubit>().clearQuery(),
                  );
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<AddressBloc, AddressState>(
                  builder: (context, state) {
                    if (state is AddressLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AddressLoaded) {
                      return BlocBuilder<SearchCubit, String>(
                        builder: (context, query) {
                          final allAddresses = [...state.addresses]
                            ..sort((a, b) => b.isSelected ? 1 : -1);
                          final filtered = _filterAddresses(
                            allAddresses,
                            query,
                          );

                          if (filtered.isEmpty) {
                            return const Center(
                              child: Text("No addresses found."),
                            );
                          }

                          return ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder:
                                (_, i) => AddressCard(
                                  address: filtered[i],
                                  onEdit:
                                      () => _showAddressDialog(
                                        context,
                                        address: filtered[i],
                                      ),
                                ),
                          );
                        },
                      );
                    } else if (state is AddressError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: primaryColor,
          onPressed: () => _showAddressDialog(context),
          icon: const Icon(Icons.add),
          label: const Text("New Address"),
        ),
      ),
    );
  }
}
