import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:nsound/bloc/player/player_bloc.dart' as bloc;
import 'package:nsound/app/di/service_locator.dart';
import 'package:nsound/app/router/app_router.dart';
import 'package:nsound/app/theme/themes.dart';
import 'package:nsound/bloc/theme/theme_bloc.dart';
import 'package:nsound/data/repositories/player_repository.dart';
import 'package:nsound/data/repositories/recents_repository.dart';
import 'package:nsound/presentation/widgets/buttons/next_button.dart';
import 'package:nsound/presentation/widgets/buttons/play_pause_button.dart';
import 'package:nsound/presentation/widgets/buttons/previous_button.dart';
import 'package:nsound/presentation/widgets/buttons/seek_bar.dart';
import 'package:nsound/presentation/widgets/spinning_disc_animation.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayerBottomAppBar extends StatefulWidget {
  const PlayerBottomAppBar({super.key});

  @override
  State<PlayerBottomAppBar> createState() => _PlayerBottomAppBarState();
}

class _PlayerBottomAppBarState extends State<PlayerBottomAppBar> {
  final player = sl<MusicPlayer>();
  bool isPlaying = false;
  bool isExpanded = false;

  List<SongModel> playlist = [];

  @override
  void initState() {
    super.initState();
    player.playing.listen((playing) {
      setState(() {
        isPlaying = playing;
      });
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _getPlaylist() async {
    playlist = await player.loadPlaylist();
    if (playlist.isEmpty) {
      return;
    }
    // get last played song
    SongModel? lastPlayedSong = await sl<RecentsRepository>().fetchLastPlayed();
    if (lastPlayedSong != null) {
      await player.setSequenceFromPlaylist(playlist, lastPlayedSong);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return StreamBuilder<SequenceState?>(
            stream: player.sequenceState,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                // if no sequence is loaded, load from hive
                if (player.playlist.isEmpty) {
                  _getPlaylist();
                }
                return const SizedBox();
              }

              var sequence = snapshot.data;
              MediaItem mediaItem =
                  sequence?.sequence[sequence.currentIndex].tag;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  Navigator.of(context).pushNamed(
                    AppRouter.playerRoute,
                  );
                },
                // slide up to show player
                onVerticalDragUpdate: (details) {
                  bool previousIsExpanded = isExpanded;
                  if (details.delta.dy > 0) {
                    isExpanded = false;
                  } else {
                    isExpanded = true;
                  }
                  if (previousIsExpanded != isExpanded) {
                    setState(() {});
                  }
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(32),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: isExpanded ? 216 : 60,
                    color:
                        Themes.getTheme().primaryColor.withValues(alpha: 0.5),
                    child: isExpanded
                        ? _buildExpanded(sequence!, mediaItem)
                        : _buildCollapsed(sequence!, mediaItem),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  _buildExpanded(SequenceState sequence, MediaItem mediaItem) {
    return Stack(
      children: [
        QueryArtworkWidget(
          keepOldArtwork: true,
          artworkHeight: double.infinity,
          artworkWidth: double.infinity,
          id: int.parse(mediaItem.id),
          type: ArtworkType.AUDIO,
          size: 10000,
          artworkBorder: BorderRadius.circular(0),
          nullArtworkWidget: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(0),
            ),
            child: const Icon(
              Icons.music_note_outlined,
              size: 100,
              color: Colors.orange,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(0),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                Row(
                  children: [
                    // disc
                    SpinningDisc(
                      id: int.parse(mediaItem.id),
                    ),
                    const SizedBox(width: 16),
                    // song info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mediaItem.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mediaItem.artist ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 20),
                SeekBar(player: player),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PreviousButton(),
                    const SizedBox(width: 20),
                    PlayPauseButton(),
                    const SizedBox(width: 20),
                    NextButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildCollapsed(SequenceState sequence, MediaItem mediaItem) {
    return Row(
      children: [
        const SizedBox(width: 20),
        // song info with swiping
        Expanded(
          child: SwipeSong(
            sequence: sequence,
            mediaItem: mediaItem,
          ),
        ),
        PlayPauseButton(
          width: 20,
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              AppRouter.queueRoute,
            );
          },
          icon: const Icon(Icons.queue_music_outlined, color: Colors.orange),
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}

class SwipeSong extends StatefulWidget {
  const SwipeSong({
    super.key,
    required this.sequence,
    required this.mediaItem,
  });

  final SequenceState? sequence;
  final MediaItem mediaItem;

  @override
  State<SwipeSong> createState() => _SwipeSongState();
}

class _SwipeSongState extends State<SwipeSong> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: widget.sequence?.currentIndex ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
      stream: sl<MusicPlayer>().currentIndex,
      builder: (context, snapshot) {
        if (snapshot.hasData && pageController.hasClients) {
          pageController.jumpToPage(snapshot.data!);
        }
        return PageView.builder(
          itemCount: widget.sequence?.sequence.length ?? 0,
          controller: pageController,
          onPageChanged: (index) {
            if (widget.sequence?.currentIndex != index) {
              context.read<bloc.PlayerBloc>().add(
                    bloc.PlayerSeek(
                      Duration.zero,
                      index: index,
                    ),
                  );
            }
          },
          itemBuilder: (context, index) {
            MediaItem mediaItem = widget.sequence?.sequence[index].tag;
            return Row(
              children: [
                SpinningDisc(
                  id: int.parse(mediaItem.id),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        mediaItem.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        mediaItem.artist ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Themes.getTheme().colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            );
          },
        );
      },
    );
  }
}
