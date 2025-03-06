import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nsound/app.dart';
import 'package:nsound/app/di/service_locator.dart';
import 'package:nsound/bloc/favorites/favorites_bloc.dart';
import 'package:nsound/bloc/home/home_bloc.dart';
import 'package:nsound/bloc/player/player_bloc.dart';
import 'package:nsound/bloc/playlists/playlists_cubit.dart';
import 'package:nsound/bloc/recents/recents_bloc.dart';
import 'package:nsound/bloc/search/search_bloc.dart';
import 'package:nsound/bloc/song/song_bloc.dart';
import 'package:nsound/bloc/theme/theme_bloc.dart';
import 'package:nsound/data/repositories/player_repository.dart';
import 'package:nsound/data/services/hive_box.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  init();

  if (!await Permission.mediaLibrary.isGranted) {
    await Permission.mediaLibrary.request();
  }

  await Hive.initFlutter();

  await Hive.openBox(HiveBox.boxName);

  await sl<MusicPlayer>().init();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => sl<HomeBloc>(),
      ),
      BlocProvider(
        create: (context) => sl<ThemeBloc>(),
      ),
      BlocProvider(
        create: (context) => sl<SongBloc>(),
      ),
      BlocProvider(
        create: (context) => sl<PlayerBloc>(),
      ),
      BlocProvider(
        create: (context) => sl<RecentsBloc>(),
      ),
      BlocProvider(
        create: (context) => sl<FavoritesBloc>(),
      ),
      BlocProvider(
        create: (context) => sl<PlaylistsCubit>(),
      ),
      BlocProvider(
        create: (context) => sl<SearchBloc>(),
      ),
    ],
    child: const MainApp(),
  ));
}
