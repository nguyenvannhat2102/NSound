import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsound/app/constants/assets.dart';
import 'package:nsound/app/di/service_locator.dart';
import 'package:nsound/app/router/app_router.dart';
import 'package:nsound/app/theme/themes.dart';
import 'package:nsound/bloc/theme/theme_bloc.dart';
import 'package:nsound/presentation/pages/home/view/albums_view.dart';
import 'package:nsound/presentation/pages/home/view/playlists_view.dart';
import 'package:nsound/presentation/pages/home/view/songs_view.dart';
import 'package:nsound/presentation/widgets/player_bottom_app_bar.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final _audioQuery = sl<OnAudioQuery>();
  late TabController _tabController;
  bool _hasPermission = false;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  final tabs = [
    'Songs',
    'Playlists',
    'Albums',
  ];

  Future checkAndRequestPermissions({bool retry = false}) async {
    // The param 'retryRequest' is false, by default.
    _hasPermission = await _audioQuery.checkAndRequest(
      retryRequest: retry,
    );
    // Only call update the UI if application has all required permissions.
    _hasPermission ? setState(() {}) : checkAndRequestPermissions(retry: true);
  }

  @override
  void initState() {
    super.initState();
    checkAndRequestPermissions();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          key: scaffoldKey,
          // current song, play/pause button, song progress bar, song queue button
          bottomNavigationBar: const PlayerBottomAppBar(),
          extendBody: true,
          backgroundColor: Themes.getTheme().secondaryColor,
          appBar: _buildAppBar(),
          body: _buildBody(context),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Image.asset(
            Assets.logo,
            height: 50,
            width: 50,
          ),
          const SizedBox(width: 8),
          const Text(
            'NSound',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
      backgroundColor: Themes.getTheme().primaryColor,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRouter.searchRoute);
          },
          icon: const Icon(
            Icons.search_outlined,
            color: Colors.orange,
          ),
          tooltip: 'Search',
        ),
        PopupMenuButton(
          icon: const Icon(
            Icons.more_vert,
            color: Colors.orange,
          ),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.themesRoute);
                  },
                  child: const Text(
                    'Themes',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  Ink _buildBody(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        gradient: Themes.getTheme().linearGradient,
      ),
      child: _hasPermission
          ? Column(
              children: [
                TabBar(
                  labelColor: Colors.orange,
                  indicatorColor: Colors.orange,
                  dividerColor: Theme.of(context).colorScheme.onPrimary,
                  tabAlignment: TabAlignment.center,
                  isScrollable: true,
                  controller: _tabController,
                  tabs: tabs
                      .map(
                        (e) => Tab(
                          text: e,
                        ),
                      )
                      .toList(),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      SongsView(),
                      PlaylistsView(),
                      AlbumsView(),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: Text('No permission to access library'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    // permission request
                    await Permission.storage.request();
                  },
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.orange,
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
