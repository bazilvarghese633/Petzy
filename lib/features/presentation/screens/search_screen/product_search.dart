import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/bloc/cubit/price_slider_cubit.dart';
import 'package:petzy/features/presentation/bloc/filter_bloc.dart';
import 'package:petzy/features/presentation/bloc/filter_event.dart';
import 'package:petzy/features/presentation/bloc/product_bloc.dart';
import 'package:petzy/features/presentation/bloc/product_event.dart';
import 'package:petzy/features/presentation/screens/filter_screen/filter_screen.dart';
import 'package:petzy/features/presentation/screens/search_screen/widgets/search_field.dart';
import 'package:petzy/features/presentation/screens/search_screen/widgets/search_results.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProducts());
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _controller.text.trim();
    context.read<ProductBloc>().add(SearchProducts(query));
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Center(
                    child: Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      height: 30,
                      width: 50,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        border: Border.all(
                          color: const Color(0xFFFF9900),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.tune,
                          color: whiteColor,
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) {
                                final productBloc = context.read<ProductBloc>();
                                final maxPrice = productBloc.maxPrice;

                                final filterBloc = FilterBloc(
                                  absoluteMaxPrice: maxPrice,
                                );
                                filterBloc.add(SetInitialFilters(maxPrice));

                                return MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(value: filterBloc),
                                    BlocProvider(
                                      create:
                                          (_) => PriceSliderCubit(
                                            filterBloc.state.minPrice,
                                            filterBloc.state.maxPrice,
                                          ),
                                    ),
                                  ],
                                  child: const FilterScreen(),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            SearchField(controller: _controller),
            const SizedBox(height: 16),
            Expanded(child: SearchResults(controller: _controller)),
          ],
        ),
      ),
    );
  }
}
