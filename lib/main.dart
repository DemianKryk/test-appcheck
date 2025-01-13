import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScreenSizeBloc(),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return TestWidget(
                logText: 'LayoutBuilder REBUILD',
                isDesk: constraints.maxWidth > 700,
              );
            },
          ),
          const SizedBox(
            height: 100,
          ),
          BlocBuilder<ScreenSizeBloc, bool>(
            builder: (context, state) {
              return TestWidget(
                logText: 'BLOC REBUILD',
                isDesk: state,
              );
            },
          ),
        ],
      ),
    );
  }
}

class TestWidget extends StatelessWidget {
  const TestWidget({
    super.key,
    required this.logText,
    required this.isDesk,
  });
  final String logText;
  final bool isDesk;

  @override
  Widget build(BuildContext context) {
    print(logText);
    return Container(
      height: isDesk ? 200 : 100,
      width: isDesk ? 200 : 100,
      alignment: Alignment.center,
      color: Colors.black,
    );
  }
}

class ScreenSizeBloc extends Cubit<bool> {
  final ScreenSizeRepository _screenSizeStream;

  StreamSubscription<Size>? _subscription;

  ScreenSizeBloc()
      : _screenSizeStream = ScreenSizeRepository(),
        super(true) {
    _subscription = _screenSizeStream.sizeStream.listen((size) {
      emit(size.width > 700);
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class ScreenSizeRepository with WidgetsBindingObserver {
  ScreenSizeRepository() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = _getScreenSize();
      _sizeController.add(size);
    });
  }
  final StreamController<Size> _sizeController =
      StreamController<Size>.broadcast();

  Stream<Size> get sizeStream => _sizeController.stream;

  @override
  void didChangeMetrics() {
    final size = _getScreenSize();
    _sizeController.add(size);
  }

  Size _getScreenSize() {
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final view = platformDispatcher.views.first;
    return view.physicalSize / view.devicePixelRatio;
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sizeController.close();
  }
}
