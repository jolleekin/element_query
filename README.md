# element_query

A polyfill for Element Query.

## Usage
- Use existing CSS syntax
- Elements/selectors must be registered through code
- Supported query types: `min-width`, `max-width`, `min-height`, `max-height`
- Supported units: `px`, `em`
- Queries are updated automatically when the window is resized.
  For other cases, a call to `update` is required.

### CSS
```` css
header[min-width~="500px"] {
    color: red;
}
header[max-width~="500px"] nav {
    clear: both;
}
header[min-width~="500px"] nav[min-height~="3em"] {
    color: white;
}
````
### Dart
```` dart
import 'package:element_query/element_query.dart' as eq;

main() {
  // Initialize Element Query.
  // This method is safe to be called multiple times.
  eq.init();

  // Register a selector with two checkpoints for min-width.
  eq.register('.main-pane', minWidths: ['600px', '1000px']);
  
  // Register an element with one checkpoint for max-height.
  eq.register(element, maxHeights: ['3em']);


  document.querySelector('.left-pane')
    ..onClick.listen((e) {
      e.target.classes.toggle('expanded');
    })
    ..onTransitionEnd.listen((_) {
      // Call `update` to trigger a refresh.
      eq.update();
    });
}
````
## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/jolleekin/element_query/issues
