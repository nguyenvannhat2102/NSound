import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nsound/app/constants/assets.dart';
import 'package:nsound/bloc/player/player_bloc.dart';

class PreviousButton extends StatelessWidget {
  const PreviousButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.read<PlayerBloc>().add(PlayerPrevious());
      },
      icon: SvgPicture.asset(Assets.previousSvg, width: 40),
      tooltip: 'Previous',
    );
  }
}
