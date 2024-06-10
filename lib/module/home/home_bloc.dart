import 'package:bloc/bloc.dart';
import 'package:sunmolor_team/module/home/home_event.dart';
import 'package:sunmolor_team/module/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeLoadButton>((event, emit) async {
      emit(HomeLoading());
    });
  }
}
