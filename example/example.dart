// Copyright (c) 2016, Man Hoang. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:element_query/element_query.dart' as eq;

main() {
  // Initialize Element Query.
  // This method is safe to be called multiple times.
  eq.init();

  // Register a selector with two checkpoints for min-width.
  eq.register('.main-pane', minWidths: ['600px', '1000px']);

  // Alternatively, we can register an element.
  //eq.register(document.querySelector('.main-pane'),
  //    minWidths: ['500px', '1000px']);

  document.querySelector('.left-pane')
    ..onClick.listen((e) {
      (e.target as Element).classes.toggle('expanded');
    })
    ..onTransitionEnd.listen((_) {
      eq.update();
    });
}
