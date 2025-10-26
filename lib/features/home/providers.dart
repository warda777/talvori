import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/home/application/home_controller.dart';
import 'package:talvori/features/home/application/home_state.dart';

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(() {
  return HomeController();
});
