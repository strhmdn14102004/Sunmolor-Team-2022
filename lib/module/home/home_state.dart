
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
 

  HomeLoaded();
}

class HomeError extends HomeState {}

class HomeFinished extends HomeState {}
