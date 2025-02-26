part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class GetSongsEvent extends HomeEvent {}

class GetAlbumsEvent extends HomeEvent {}

class SortSongsEvent extends HomeEvent {
  final int songSortType;
  final int orderType;

  SortSongsEvent(this.songSortType, this.orderType);
}
