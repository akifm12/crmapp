import 'package:flutter_test/flutter_test.dart';

import 'package:bluearrow_app/widgets/anim.dart';

void main() {
  test('dueText phrases days correctly', () {
    expect(dueText(0), 'Due today');
    expect(dueText(1), 'Due tomorrow');
    expect(dueText(12), 'In 12 days');
    expect(dueText(-1), '1 day overdue');
    expect(dueText(-5), '5 days overdue');
  });

  test('urgencyColor escalates as the date approaches', () {
    expect(urgencyColor(-1), isNot(urgencyColor(60)));
    expect(urgencyColor(3), isNot(urgencyColor(20)));
    expect(urgencyColor(20), isNot(urgencyColor(60)));
  });
}
