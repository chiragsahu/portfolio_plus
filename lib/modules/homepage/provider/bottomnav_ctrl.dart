import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bottomnav_ctrl.g.dart';

@riverpod
class BottomNavState extends _$BottomNavState {
  void updateBottomBar(PageModel pageModel) {
    print('updateBottomBar: ${pageModel.page}');
    state = pageModel;
  }

  @override
  PageModel build() {
    return const PageModel(NavigationBarEvent.HOME, 0);
  }
}

class PageModel {
  const PageModel(this.page, this.index);
  final NavigationBarEvent page;
  final int index;
}

enum NavigationBarEvent { HOME, PORTFOLIO, ASSETS, TOOLS, PROFILE }
