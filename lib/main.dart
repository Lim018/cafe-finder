import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/app_theme.dart';
import 'core/cubit/theme_cubit.dart';
import 'core/di/injection.dart' as di;
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/categories/presentation/cubit/categories_cubit.dart';
import 'features/places/presentation/bloc/places_list_bloc.dart';
import 'features/places/presentation/bloc/place_detail_bloc.dart';
import 'features/map/presentation/bloc/map_bloc.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';
import 'features/reviews/presentation/bloc/reviews_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<CategoriesCubit>()),
        BlocProvider(create: (_) => di.sl<PlacesListBloc>()),
        BlocProvider(create: (_) => di.sl<MapBloc>()),
        BlocProvider(create: (_) => di.sl<PlaceDetailBloc>()),
        BlocProvider(create: (_) => di.sl<FavoritesBloc>()),
        BlocProvider(create: (_) => di.sl<ReviewsBloc>()),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Cafe Finder',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
