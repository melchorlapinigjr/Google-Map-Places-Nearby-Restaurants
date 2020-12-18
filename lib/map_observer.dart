import 'package:bloc/bloc.dart';

/// {@template counter_observer}
/// [BlocObserver] for the application which
/// observes all [Cubit] state changes.
/// {@endtemplate}

class MapBlocObserver extends BlocObserver {
  @override
  void onChange(Cubit cubit, Change change) {
    print('Cubit state change: ${cubit.runtimeType} $change');
    super.onChange(cubit, change);
  }

  @override
  onTransition(Bloc bloc, Transition transition) {
    print('onTransition $transition');
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    print('onError $error');
    super.onError(cubit, error, stackTrace);
  }
}
