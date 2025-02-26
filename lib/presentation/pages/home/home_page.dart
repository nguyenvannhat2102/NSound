import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsound/app/constants/assets.dart';
import 'package:nsound/app/di/main_injection_container.dart';
import 'package:nsound/app/router/app_router.dart';
import 'package:nsound/app/theme/themes.dart';
import 'package:nsound/bloc/theme/theme_bloc.dart';
import 'package:nsound/presentation/pages/home/view/albums_view.dart';
import 'package:nsound/presentation/pages/home/view/playlists_view.dart';
import 'package:nsound/presentation/pages/home/view/songs_view.dart';
import 'package:nsound/presentation/widgets/player_bottom_app_bar.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final OnAudioQuery _audioQuery = sl<OnAudioQuery>();
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
          drawer: _buildDrawer(context),
          body: _buildBody(context),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Themes.getTheme().primaryColor,
      leading: IconButton(
        icon: SvgPicture.asset(
          Assets.menuSvg,
          width: 32,
          height: 32,
          colorFilter: ColorFilter.mode(
            // if theme is dark, invert the color
            Theme.of(context).textTheme.bodyMedium!.color!,
            BlendMode.srcIn,
          ),
        ),
        tooltip: 'Menu',
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      // search button
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRouter.searchRoute);
          },
          icon: const Icon(Icons.search_outlined),
          tooltip: 'Search',
        )
      ],
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 48, bottom: 16),
                decoration: BoxDecoration(
                  color: Themes.getTheme().primaryColor,
                ),
                child: Row(
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Image.asset(
                        Assets.logo,
                        height: 64,
                        width: 64,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
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
              );
            },
          ),
          Divider(
            color: Colors.grey,
            indent: 16,
            endIndent: 16,
          ),
          // themes
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Themes'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.themesRoute);
            },
          ),
          // settings
          ListTile(
            leading: SvgPicture.asset(
              Assets.settingsSvg,
              colorFilter: ColorFilter.mode(
                Theme.of(context).textTheme.bodyMedium!.color!,
                BlendMode.srcIn,
              ),
            ),
            title: const Text('Settings'),
            // onTap: () {
            //   Navigator.of(context).pushNamed(AppRouter.settingsRoute);
            // },
          )
        ],
      ),
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
                  dividerColor:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(
                            0.3,
                          ),
                  tabAlignment: TabAlignment.start,
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
                  child: const Text('Retry'),
                )
              ],
            ),
    );
  }
}
