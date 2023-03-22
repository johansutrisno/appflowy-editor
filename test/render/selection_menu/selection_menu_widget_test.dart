import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../infra/test_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('selection_menu_widget.dart', () {
    // const i = defaultSelectionMenuItems.length;
    //
    // Because the `defaultSelectionMenuItems` uses localization,
    // and the MaterialApp has not been initialized at the time of getting the value,
    // it will crash.
    //
    // Use const value temporarily instead.
    const i = 7;
    testWidgets('Selects number.$i item in selection menu with keyboard',
        (tester) async {
      final editor = await _prepare(tester);
      for (var j = 0; j < i; j++) {
        await editor.pressLogicKey(LogicalKeyboardKey.arrowDown);
      }

      await editor.pressLogicKey(LogicalKeyboardKey.enter);
      expect(
        find.byType(SelectionMenuWidget, skipOffstage: false),
        findsNothing,
      );
      if (defaultSelectionMenuItems[i].name != 'Image') {
        await _testDefaultSelectionMenuItems(i, editor);
      }
    });

    testWidgets('Selects number.$i item in selection menu with clicking',
        (tester) async {
      final editor = await _prepare(tester);
      await tester.tap(find.byType(SelectionMenuItemWidget).at(i));
      await tester.pumpAndSettle();
      expect(
        find.byType(SelectionMenuWidget, skipOffstage: false),
        findsNothing,
      );
      if (defaultSelectionMenuItems[i].name != 'Image') {
        await _testDefaultSelectionMenuItems(i, editor);
      }
    });

    testWidgets('Search item in selection menu util no results',
        (tester) async {
      final editor = await _prepare(tester);
      await editor.pressLogicKey(LogicalKeyboardKey.keyT);
      await editor.pressLogicKey(LogicalKeyboardKey.keyE);
      expect(
        find.byType(SelectionMenuItemWidget, skipOffstage: false),
        findsNWidgets(3),
      );
      await editor.pressLogicKey(LogicalKeyboardKey.backspace);
      expect(
        find.byType(SelectionMenuItemWidget, skipOffstage: false),
        findsNWidgets(5),
      );
      await editor.pressLogicKey(LogicalKeyboardKey.keyE);
      expect(
        find.byType(SelectionMenuItemWidget, skipOffstage: false),
        findsNWidgets(3),
      );
      await editor.pressLogicKey(LogicalKeyboardKey.keyX);
      expect(
        find.byType(SelectionMenuItemWidget, skipOffstage: false),
        findsNWidgets(1),
      );
      await editor.pressLogicKey(LogicalKeyboardKey.keyT);
      expect(
        find.byType(SelectionMenuItemWidget, skipOffstage: false),
        findsNWidgets(1),
      );
      await editor.pressLogicKey(LogicalKeyboardKey.keyT);
      expect(
        find.byType(SelectionMenuItemWidget, skipOffstage: false),
        findsNothing,
      );
    });

    testWidgets('Search item in selection menu and presses esc',
        (tester) async {
      final editor = await _prepare(tester);
      await editor.pressLogicKey(LogicalKeyboardKey.keyT);
      await editor.pressLogicKey(LogicalKeyboardKey.keyE);
      expect(
        find.byType(SelectionMenuItemWidget, skipOffstage: false),
        findsNWidgets(3),
      );
      await editor.pressLogicKey(LogicalKeyboardKey.escape);
      expect(
        find.byType(SelectionMenuItemWidget, skipOffstage: false),
        findsNothing,
      );
    });

    testWidgets('Search item in selection menu and presses backspace',
        (tester) async {
      final editor = await _prepare(tester);
      await editor.pressLogicKey(LogicalKeyboardKey.keyT);
      await editor.pressLogicKey(LogicalKeyboardKey.keyE);
      expect(
        find.byType(SelectionMenuItemWidget, skipOffstage: false),
        findsNWidgets(3),
      );
      await editor.pressLogicKey(LogicalKeyboardKey.backspace);
      await editor.pressLogicKey(LogicalKeyboardKey.backspace);
      await editor.pressLogicKey(LogicalKeyboardKey.backspace);
      expect(
        find.byType(SelectionMenuItemWidget, skipOffstage: false),
        findsNothing,
      );
    });
  });
}

Future<EditorWidgetTester> _prepare(WidgetTester tester) async {
  const text = 'Welcome to Appflowy 😁';
  const lines = 3;
  final editor = tester.editor;
  for (var i = 0; i < lines; i++) {
    editor.insertTextNode(text);
  }
  await editor.startTesting();
  await editor.updateSelection(Selection.single(path: [1], startOffset: 0));
  await editor.pressLogicKey(LogicalKeyboardKey.slash);

  await tester.pumpAndSettle(const Duration(milliseconds: 1000));

  expect(
    find.byType(SelectionMenuWidget, skipOffstage: false),
    findsOneWidget,
  );

  for (final item in defaultSelectionMenuItems) {
    expect(find.text(item.name), findsOneWidget);
  }

  return Future.value(editor);
}

Future<void> _testDefaultSelectionMenuItems(
    int index, EditorWidgetTester editor) async {
  expect(editor.documentLength, 4);
  expect(editor.documentSelection, Selection.single(path: [2], startOffset: 0));
  expect((editor.nodeAtPath([0]) as TextNode).toPlainText(),
      'Welcome to Appflowy 😁');
  expect((editor.nodeAtPath([1]) as TextNode).toPlainText(),
      'Welcome to Appflowy 😁');
  final node = editor.nodeAtPath([2]);
  final item = defaultSelectionMenuItems[index];
  if (item.name == 'Text') {
    expect(node?.subtype == null, true);
    expect(node?.toString(), null);
  } else if (item.name == 'Heading 1') {
    expect(node?.subtype, BuiltInAttributeKey.heading);
    expect(node?.attributes.heading, BuiltInAttributeKey.h1);
    expect(node?.toString(), null);
  } else if (item.name == 'Heading 2') {
    expect(node?.subtype, BuiltInAttributeKey.heading);
    expect(node?.attributes.heading, BuiltInAttributeKey.h2);
    expect(node?.toString(), null);
  } else if (item.name == 'Heading 3') {
    expect(node?.subtype, BuiltInAttributeKey.heading);
    expect(node?.attributes.heading, BuiltInAttributeKey.h3);
    expect(node?.toString(), null);
  } else if (item.name == 'Bulleted list') {
    expect(node?.subtype, BuiltInAttributeKey.bulletedList);
  } else if (item.name == 'Checkbox') {
    expect(node?.subtype, BuiltInAttributeKey.checkbox);
    expect(node?.attributes.check, false);
  }
}
