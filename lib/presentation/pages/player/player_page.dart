import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee/marquee.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:nsound/app/di/service_locator.dart';
import 'package:nsound/bloc/song/song_bloc.dart';
import 'package:nsound/data/repositories/player_repository.dart';
import 'package:nsound/data/repositories/song_repository.dart';
import 'package:nsound/presentation/widgets/buttons/animated_favorite_button.dart';
import 'package:nsound/presentation/widgets/buttons/next_button.dart';
import 'package:nsound/presentation/widgets/buttons/play_pause_button.dart';
import 'package:nsound/presentation/widgets/buttons/previous_button.dart';
import 'package:nsound/presentation/widgets/buttons/repeat_button.dart';
import 'package:nsound/presentation/widgets/buttons/seek_bar.dart';
import 'package:nsound/presentation/widgets/buttons/shuffle_button.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({
    super.key,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final player = sl<MusicPlayer>();
  SequenceState? sequence;

  @override
  void initState() {
    super.initState();

    player.sequenceState.listen((state) {
      setState(() {
        sequence = state;
      });
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.white,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: StreamBuilder<SequenceState?>(
        stream: player.sequenceState,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }
          final sequence = snapshot.data;
          MediaItem? mediaItem = sequence!.sequence[sequence.currentIndex].tag;
          return Stack(
            children: [
              QueryArtworkWidget(
                keepOldArtwork: true,
                artworkHeight: double.infinity,
                id: int.parse(mediaItem!.id),
                type: ArtworkType.AUDIO,
                size: 10000,
                artworkWidth: double.infinity,
                artworkBorder: BorderRadius.circular(0),
                nullArtworkWidget: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: const Icon(
                    Icons.music_note_outlined,
                    size: 100,
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  32,
                  MediaQuery.of(context).padding.top + 16,
                  32,
                  16,
                ),
                child: LayoutBuilder(builder: (context, constraints) {
                  // large screen
                  if (constraints.maxWidth > 600) {
                    // large screen divided in 2 columns
                    // 1: artwork
                    // 2: info
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // artwork
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              QueryArtworkWidget(
                                keepOldArtwork: true,
                                id: int.parse(mediaItem.id),
                                type: ArtworkType.AUDIO,
                                size: 10000,
                                artworkWidth: double.infinity,
                                nullArtworkWidget: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Icon(
                                    Icons.music_note_outlined,
                                    size:
                                        MediaQuery.of(context).size.height / 10,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: BlocBuilder<SongBloc, SongState>(
                                  builder: (context, state) {
                                    return AnimatedFavoriteButton(
                                      isFavorite: sl<SongRepository>()
                                          .isFavorite(mediaItem.id),
                                      mediaItem: mediaItem,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 32),

                        // info
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              // title and artist
                              StreamBuilder<SequenceState?>(
                                stream: player.sequenceState,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox.shrink();
                                  }
                                  final sequence = snapshot.data;

                                  MediaItem? mediaItem = sequence!
                                      .sequence[sequence.currentIndex].tag;

                                  return Column(
                                    children: [
                                      SizedBox(
                                        height: 30,
                                        child: AutoSizeText(
                                          mediaItem!.title,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          minFontSize: 20,
                                          overflowReplacement: Marquee(
                                            text: mediaItem.title,
                                            blankSpace: 100,
                                            startAfter:
                                                const Duration(seconds: 3),
                                            pauseAfterRound:
                                                const Duration(seconds: 3),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30,
                                        child: AutoSizeText(
                                          mediaItem.artist ?? 'Unknown',
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.orange,
                                          ),
                                          minFontSize: 16,
                                          overflowReplacement: Marquee(
                                            text: mediaItem.artist ?? 'Unknown',
                                            blankSpace: 100,
                                            startAfter:
                                                const Duration(seconds: 3),
                                            pauseAfterRound:
                                                const Duration(seconds: 3),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const Spacer(),
                              // seek bar
                              SeekBar(player: player),
                              const Spacer(),
                              // shuffle, previous, play/pause, next, repeat
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ShuffleButton(),
                                  PreviousButton(),
                                  PlayPauseButton(),
                                  NextButton(),
                                  RepeatButton(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // small screen
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // artwork
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width - 64,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            QueryArtworkWidget(
                              keepOldArtwork: true,
                              id: int.parse(mediaItem.id),
                              type: ArtworkType.AUDIO,
                              size: 10000,
                              artworkWidth: double.infinity,
                              nullArtworkWidget: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  Icons.music_note_outlined,
                                  size: MediaQuery.of(context).size.height / 10,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: BlocBuilder<SongBloc, SongState>(
                                builder: (context, state) {
                                  return AnimatedFavoriteButton(
                                    isFavorite: sl<SongRepository>()
                                        .isFavorite(mediaItem.id),
                                    mediaItem: mediaItem,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // title and artist
                      StreamBuilder<SequenceState?>(
                        stream: player.sequenceState,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          final sequence = snapshot.data;
                          MediaItem? mediaItem =
                              sequence!.sequence[sequence.currentIndex].tag;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 30,
                                child: AutoSizeText(
                                  mediaItem!.title,
                                  maxLines: 1,
                                  minFontSize: 20,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflowReplacement: Marquee(
                                    text: mediaItem.title,
                                    blankSpace: 100,
                                    startAfter: const Duration(seconds: 3),
                                    pauseAfterRound: const Duration(seconds: 3),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                                child: AutoSizeText(
                                  mediaItem.artist ?? 'Unknown',
                                  maxLines: 1,
                                  minFontSize: 15,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.orange,
                                  ),
                                  overflowReplacement: Marquee(
                                    text: mediaItem.artist ?? 'Unknown',
                                    blankSpace: 100,
                                    startAfter: const Duration(seconds: 3),
                                    pauseAfterRound: const Duration(seconds: 3),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 64),
                      // seek bar
                      SeekBar(player: player),
                      const SizedBox(height: 16),
                      // shuffle, previous, play/pause, next, repeat
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ShuffleButton(),
                          PreviousButton(),
                          PlayPauseButton(),
                          NextButton(),
                          RepeatButton(),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
