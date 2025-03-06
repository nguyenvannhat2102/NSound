import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nsound/app/constants/assets.dart';
import 'package:nsound/app/di/service_locator.dart';
import 'package:nsound/bloc/player/player_bloc.dart';
import 'package:nsound/data/repositories/player_repository.dart';

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({
    super.key,
    this.width = 40,
    this.color = Colors.orange,
  });

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final player = sl<MusicPlayer>();
    return StreamBuilder<bool>(
      stream: player.playing,
      builder: (context, snapshot) {
        final playing = snapshot.data ?? false;
        return IconButton(
          onPressed: () {
            if (playing) {
              context.read<PlayerBloc>().add(PlayerPause());
            } else {
              context.read<PlayerBloc>().add(PlayerPlay());
            }
          },
          icon: playing
              ? SvgPicture.asset(
                  Assets.pauseSvg,
                  colorFilter: ColorFilter.mode(
                    color,
                    BlendMode.srcIn,
                  ),
                  width: width,
                )
              : SvgPicture.asset(
                  Assets.playSvg,
                  colorFilter: ColorFilter.mode(
                    color,
                    BlendMode.srcIn,
                  ),
                  width: width,
                ),
          tooltip: 'Play/Pause',
        );
      },
    );
  }
}
