import 'package:bloc/bloc.dart';
import 'package:sunmolor_team/module/home/home_event.dart';
import 'package:sunmolor_team/module/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeLoadButton>((event, emit) async {
      emit(HomeLoading());
      //   try {
      //     Response response = await ApiManager().getproduck(ApiUrl.produk);
      //     if (response.statusCode == 200) {
      //       List<ProductItem> products = (response.data as List)
      //           .map((item) => ProductItem.fromJson(item))
      //           .toList();
      //       emit(HomeLoaded(products));
      //     } else {
      //       Overlays.error(
      //         message: "API call failed with status code ${response.statusCode}",
      //       );
      //       emit(HomeError());
      //     }
      //   } catch (e, stackTrace) {
      //     print("Error: $e\nStack trace:\n$stackTrace");
      //     Overlays.error(
      //       message: "Ada sesuatu yang salah. Silahkan coba kembali beberapa saat kemudian",
      //     );
      //     emit(HomeError());
      //   }
      // });
    });
  }
}
