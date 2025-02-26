import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:nsound/data/repositories/home_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required HomeRepository repository}) : super(HomeInitial()) {
    on<GetSongsEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final songs = await repository.getSongs();
        emit(
          SongsLoaded(songs),
        );
      } catch (e, s) {
        debugPrintStack(label: e.toString(), stackTrace: s);
        emit(HomeError(e.toString()));
      }
    });
    on<GetAlbumsEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final albums = await repository.getAlbums();
        emit(
          AlbumsLoaded(albums),
        );
      } catch (e, s) {
        debugPrintStack(label: e.toString(), stackTrace: s);
        emit(HomeError(e.toString()));
      }
    });
    on<SortSongsEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        await repository.sortSongs(event.songSortType, event.orderType);
        final songs = await repository.getSongs();
        emit(
          SongsLoaded(songs),
        );
      } catch (e, s) {
        debugPrintStack(label: e.toString(), stackTrace: s);
        emit(HomeError(e.toString()));
      }
    });
  }
}
