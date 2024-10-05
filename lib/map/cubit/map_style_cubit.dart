import 'package:bloc/bloc.dart';
import 'package:mission_planer/map/services/map_configuration.dart';

part 'map_style_state.dart';

enum MapStyle {
  standard,
  satellite;

  String getTemplateUrl() {
    switch (this) {
      case MapStyle.standard:
        return MapConfiguration.tileUrlTemplateStandard;
      case MapStyle.satellite:
        return MapConfiguration.tileUrlTemplateSatellite;
    }
  }
}

class MapStyleCubit extends Cubit<MapStyleState> {
  MapStyleCubit() : super(const MapStyleState(mapStyle: MapStyle.standard));

  void changeStyle() {
    emit(
      MapStyleState(
        mapStyle: state.mapStyle == MapStyle.standard
            ? MapStyle.satellite
            : MapStyle.standard,
      ),
    );
  }
}
