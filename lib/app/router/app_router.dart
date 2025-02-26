import 'package:flutter/material.dart';
import 'package:nsound/presentation/pages/config/theme_page.dart';
import 'package:nsound/presentation/pages/details/album_page.dart';
import 'package:nsound/presentation/pages/home/home_page.dart';
import 'package:nsound/presentation/pages/home/search_page.dart';
import 'package:nsound/presentation/pages/player/player_page.dart';
import 'package:nsound/presentation/pages/player/queue_page.dart';
import 'package:nsound/presentation/pages/splash_page.dart';
import 'package:nsound/presentation/playlists/favorites_page.dart';
import 'package:nsound/presentation/playlists/playlist_details_page.dart';
import 'package:nsound/presentation/playlists/recents_page.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AppRouter {
  static const String splashRoute = '/';
  static const String homeRoute = '/home';
  static const String searchRoute = '/search';
  static const String themesRoute = '/themes';
  static const String playerRoute = '/player';
  static const String queueRoute = '/queue';
  static const String favoritesRoute = '/favorites';
  static const String recentsRoute = '/recents';
  static const String playlistDetailsRoute = '/playlist';
  static const String addSongToPlaylistRoute = '/addSongToPlaylist';
  static const String albumRoute = '/album';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute<dynamic>(builder: (_) => SplashPage());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => HomePage());
      case searchRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const SearchPage(),
        );
      case themesRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const ThemesPage(),
        );
      case playerRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const PlayerPage(),
        );
      case queueRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const QueuePage(),
        );
      case favoritesRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const FavoritesPage(),
        );
      case recentsRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const RecentsPage(),
        );
      case playlistDetailsRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => PlaylistDetailsPage(
            playlist: settings.arguments as PlaylistModel,
          ),
        );
      case addSongToPlaylistRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => AddSongToPlaylist(
            songs: (settings.arguments as Map)['songs'] as List<SongModel>,
            playlist: (settings.arguments as Map)['playlist'] as PlaylistModel,
          ),
        );
      case albumRoute:
        return MaterialPageRoute<dynamic>(
          builder: (_) => AlbumPage(
            album: settings.arguments as AlbumModel,
          ),
        );
      default:
        return MaterialPageRoute<dynamic>(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
