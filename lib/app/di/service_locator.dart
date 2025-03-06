import 'package:get_it/get_it.dart';
import 'package:nsound/bloc/favorites/favorites_bloc.dart';
import 'package:nsound/bloc/home/home_bloc.dart';
import 'package:nsound/bloc/player/player_bloc.dart';
import 'package:nsound/bloc/playlists/playlists_cubit.dart';
import 'package:nsound/bloc/recents/recents_bloc.dart';
import 'package:nsound/bloc/search/search_bloc.dart';
import 'package:nsound/bloc/song/song_bloc.dart';
import 'package:nsound/bloc/theme/theme_bloc.dart';
import 'package:nsound/data/repositories/favorites_repository.dart';
import 'package:nsound/data/repositories/home_repository.dart';
import 'package:nsound/data/repositories/player_repository.dart';
import 'package:nsound/data/repositories/recents_repository.dart';
import 'package:nsound/data/repositories/search_repository.dart';
import 'package:nsound/data/repositories/song_repository.dart';
import 'package:nsound/data/repositories/theme_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';

final sl = GetIt.instance;

void init() {
  //bloc
  sl.registerFactory(() => ThemeBloc(repository: sl()));
  sl.registerFactory(() => HomeBloc(repository: sl()));
  sl.registerFactory(() => PlayerBloc(repository: sl()));
  sl.registerFactory(() => SongBloc(repository: sl()));
  sl.registerFactory(() => RecentsBloc(repository: sl()));
  sl.registerFactory(() => FavoritesBloc(repository: sl()));
  sl.registerFactory(() => SearchBloc(repository: sl()));

  // Cubit
  sl.registerFactory(() => PlaylistsCubit());

  // Repository
  sl.registerLazySingleton(() => ThemeRepository());
  sl.registerLazySingleton(() => HomeRepository());
  sl.registerLazySingleton<MusicPlayer>(
    () => JustAudioPlayer(),
  );
  sl.registerLazySingleton(() => SongRepository());
  sl.registerLazySingleton(() => RecentsRepository());
  sl.registerLazySingleton(() => FavoritesRepository());
  sl.registerLazySingleton(() => SearchRepository());

  // Third Party
  sl.registerLazySingleton(() => OnAudioQuery());
}
