import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nsound/app/extensions/string_extensions.dart';
import 'package:nsound/presentation/widgets/buttons/song_list_title.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nsound/app/constants/assets.dart';
import 'package:nsound/app/di/service_locator.dart';
import 'package:nsound/bloc/home/home_bloc.dart';
import 'package:nsound/bloc/player/player_bloc.dart';
import 'package:nsound/data/repositories/player_repository.dart';
import 'package:nsound/data/services/hive_box.dart';

class SongsView extends StatefulWidget {
  const SongsView({super.key});

  @override
  State<SongsView> createState() => _SongsViewState();
}

class _SongsViewState extends State<SongsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final audioQuery = sl<OnAudioQuery>();
  final songs = <SongModel>[];
  bool isLoading = true;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(GetSongsEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) async {
        if (state is SongsLoaded) {
          setState(() {
            songs.clear();
            songs.addAll(state.songs);
            isLoading = false;
          });

          Fluttertoast.showToast(
            msg: '${state.songs.length} songs found',
          );
        }
      },
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(GetSongsEvent());
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // margin
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // number of songs
                          Text(
                            '${songs.length} Songs',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          // sort button
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => const SortBottomSheet(),
                              );
                            },
                            icon: const Icon(
                              Icons.swap_vert,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(32),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      Assets.shuffleSvg,
                                      width: 20,
                                      colorFilter: ColorFilter.mode(
                                        Colors.orange,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Shuffle',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // enable shuffle
                                  context.read<PlayerBloc>().add(
                                        PlayerSetShuffleModeEnabled(true),
                                      );
                                  // get random song
                                  final randomSong =
                                      songs[Random().nextInt(songs.length)];
                                  // play random song
                                  context.read<PlayerBloc>().add(
                                        PlayerLoadSongs(
                                          songs,
                                          sl<MusicPlayer>()
                                              .getMediaItemFromSong(randomSong),
                                        ),
                                      );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(32),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      Assets.playSvg,
                                      width: 20,
                                      colorFilter: ColorFilter.mode(
                                        Colors.orange,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Play',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // disable shuffle
                                  context.read<PlayerBloc>().add(
                                        PlayerSetShuffleModeEnabled(false),
                                      );
                                  // play first song
                                  context.read<PlayerBloc>().add(
                                        PlayerLoadSongs(
                                          songs,
                                          sl<MusicPlayer>()
                                              .getMediaItemFromSong(songs[0]),
                                        ),
                                      );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                  AnimationLimiter(
                    child: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = songs[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 500),
                            child: FlipAnimation(
                              child: SongListTile(
                                song: song,
                                songs: songs,
                              ),
                            ),
                          );
                        },
                        childCount: songs.length,
                      ),
                    ),
                  ),
                  // bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0.0, // Scroll to the top
      duration:
          const Duration(milliseconds: 500), // Duration of the scroll animation
      curve: Curves.easeInOut, // Animation curve
    );
  }
}

class SortBottomSheet extends StatefulWidget {
  const SortBottomSheet({super.key});

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  int currentSortType = Hive.box(HiveBox.boxName).get(
    HiveBox.songSortTypeKey,
    defaultValue: SongSortType.TITLE.index,
  );
  int currentOrderType = Hive.box(HiveBox.boxName).get(
    HiveBox.songOrderTypeKey,
    defaultValue: OrderType.ASC_OR_SMALLER.index,
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Sort by',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.orange,
              ),
            ),
          ),
          for (final songSortType in SongSortType.values)
            RadioListTile<int>(
              visualDensity: const VisualDensity(
                horizontal: 0,
                vertical: -4,
              ),
              value: songSortType.index,
              groupValue: currentSortType,
              activeColor: Colors.orange,
              title: Text(
                songSortType.name.capitalize().replaceAll('_', ' '),
                style: const TextStyle(color: Colors.orange),
              ),
              onChanged: (value) {
                setState(() {
                  currentSortType = value!;
                });
              },
            ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Order by',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.orange,
              ),
            ),
          ),
          for (final orderType in OrderType.values)
            RadioListTile<int>(
              visualDensity: const VisualDensity(
                horizontal: 0,
                vertical: -4,
              ),
              activeColor: Colors.orange,
              value: orderType.index,
              groupValue: currentOrderType,
              title: Text(
                orderType.name.capitalize().replaceAll('_', ' '),
                style: const TextStyle(color: Colors.orange),
              ),
              onChanged: (value) {
                setState(() {
                  currentOrderType = value!;
                });
              },
            ),
          const SizedBox(height: 16),
          // cancel, apply button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.read<HomeBloc>().add(
                            SortSongsEvent(
                              currentSortType,
                              currentOrderType,
                            ),
                          );
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
