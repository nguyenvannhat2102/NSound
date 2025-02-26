import 'package:flutter/material.dart';
import 'package:nsound/app/di/main_injection_container.dart';
import 'package:nsound/app/theme/themes.dart';
import 'package:nsound/data/repositories/player_repository.dart';
import 'package:nsound/presentation/widgets/buttons/song_list_title.dart';

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Themes.getTheme().primaryColor,
        elevation: 0,
        title: const Text('Queue'),
      ),
      body: Ink(
        decoration: BoxDecoration(
          gradient: Themes.getTheme().linearGradient,
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final playlist = sl<MusicPlayer>().playlist;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: playlist.length,
      itemBuilder: (context, index) {
        return SongListTile(
          song: playlist[index],
          songs: playlist,
          key: ValueKey(playlist[index].id),
        );
      },
    );
  }
}
