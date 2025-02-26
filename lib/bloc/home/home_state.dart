part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class SongsLoaded extends HomeState {
  final List<SongModel> songs;

  SongsLoaded(this.songs);
}

final class AlbumsLoaded extends HomeState {
  final List<AlbumModel> albums;

  AlbumsLoaded(this.albums);
}

final class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
