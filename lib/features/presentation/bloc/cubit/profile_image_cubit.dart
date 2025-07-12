// lib/features/presentation/bloc/cubit/profile_image_cubit.dart
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileImageCubit extends Cubit<File?> {
  ProfileImageCubit() : super(null);

  void setImage(File? file) => emit(file);

  void clearImage() => emit(null);
}
