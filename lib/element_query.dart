// Copyright (c) 2016, Man Hoang. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library element_query;

import 'dart:html';

bool _initialized = false;
final _regExp = new RegExp(r'^(\d*\.?\d+)(px|em)$');
final _queryDataMap = <Object, _QueryData>{};

class _Length {
  final num value;

  /// 'px' or 'em'.
  final String unit;

  _Length(this.value, this.unit);

  String toString() => '$value$unit';

  int compareTo(num other, num fontSize) {
    if (unit == 'px') {
      return value.compareTo(other);
    } else {
      return (value / fontSize).compareTo(other);
    }
  }

  static _Length parse(String s) {
    var match = _regExp.firstMatch(s);
    var g1 = match[1];
    var value = g1.contains('.') ? double.parse(g1) : int.parse(g1);
    return new _Length(value, match[2]);
  }
}

class _QueryData {
  final List<_Length> maxHeights;
  final List<_Length> maxWidths;
  final List<_Length> minHeights;
  final List<_Length> minWidths;
  _QueryData(this.maxHeights, this.maxWidths, this.minHeights, this.minWidths);
}

List<_Length> _convert(List<String> values) {
  if (values == null) return null;
  return values.map((e) => _Length.parse(e)).toList();
}

void _update(Element element, _QueryData data) {
  if (element.offsetWidth == 0 || element.offsetHeight == 0) return;

  var fontSize = _Length.parse(element.getComputedStyle().fontSize).value;

  void updateAttribute(String name, List<_Length> checkpoints, num dimension) {
    var value = name.startsWith('max')
        ? checkpoints
            .where((e) => e.compareTo(dimension, fontSize) >= 0)
            .join(' ')
        : checkpoints
            .where((e) => e.compareTo(dimension, fontSize) <= 0)
            .join(' ');
    if (value.isEmpty) {
      element.attributes.remove(name);
    } else {
      element.attributes[name] = value;
    }
  }

  if (data.maxHeights != null) {
    updateAttribute('max-height', data.maxHeights, element.offsetHeight);
  }
  if (data.maxWidths != null) {
    updateAttribute('max-width', data.maxWidths, element.offsetWidth);
  }
  if (data.minHeights != null) {
    updateAttribute('min-height', data.minHeights, element.offsetHeight);
  }
  if (data.minWidths != null) {
    updateAttribute('min-width', data.minWidths, element.offsetWidth);
  }
}

/// Initializes the element query.
///
/// It's safe to call this method multiple times.
void init() {
  if (_initialized) return;
  _initialized = true;
  window.onResize.listen((_) => update());
}

/// Registers [elementOrSelector].
///
/// [elementOrSelector] can be an [Element] or a selector string.
///
/// Each item of [minWidths], [maxWidths], [minHeights], and [maxHeights] is a
/// string representing a length in px or em.
///
/// Examples:
///     register(element, minWidths: ['500px', '1000px']);
///     register('header', minWidths: ['10em'], maxWidths: ['20em']);
void register(elementOrSelector,
    {List<String> minWidths,
    List<String> maxWidths,
    List<String> minHeights,
    List<String> maxHeights}) {
  var data = _queryDataMap[elementOrSelector] = new _QueryData(
      _convert(maxHeights),
      _convert(maxWidths),
      _convert(minHeights),
      _convert(minWidths));
  var elements = elementOrSelector is String
      ? document.querySelectorAll(elementOrSelector)
      : [elementOrSelector];
  for (var e in elements) {
    _update(e, data);
  }
}

/// Updates the state of registered elements.
///
/// If [parent] is `null`, all registered elements are updated, otherwise only
/// elements that are children of [parent] or [parent] itself are updated.
void update([Element parent]) {
  _queryDataMap.forEach((key, data) {
    var elements = key is String ? document.querySelectorAll(key) : [key];
    for (var e in elements) {
      if (parent == null || parent == e || parent.contains(e)) {
        _update(e, data);
      }
    }
  });
}

/// Unregisters [elementOrSelector].
///
/// [elementOrSelector] can be an [Element] or a selector string.
void unregister(elementOrSelector) {
  _queryDataMap.remove(elementOrSelector);
}
