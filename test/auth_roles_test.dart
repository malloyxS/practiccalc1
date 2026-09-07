import 'package:flutter_test/flutter_test.dart';

import 'package:calc_web/core/validators.dart';
import 'package:calc_web/models/role.dart';

void main() {
  test('читатель видит каталог и свои выдачи', () {
    expect(canPerform(Role.reader, Operation.viewCatalog), isTrue);
    expect(canPerform(Role.reader, Operation.viewOwnLoans), isTrue);
    expect(canPerform(Role.reader, Operation.extendLoan), isTrue);
  });

  test('читатель не управляет книгами и пользователями', () {
    expect(canPerform(Role.reader, Operation.manageBooks), isFalse);
    expect(canPerform(Role.reader, Operation.hardDelete), isFalse);
    expect(canPerform(Role.reader, Operation.manageUsers), isFalse);
  });

  test('библиотекарь оформляет выдачи и ведёт справочники', () {
    expect(canPerform(Role.librarian, Operation.manageBooks), isTrue);
    expect(canPerform(Role.librarian, Operation.issueLoan), isTrue);
    expect(canPerform(Role.librarian, Operation.manageReaders), isTrue);
  });

  test('библиотекарь не меняет роли и не смотрит статистику', () {
    expect(canPerform(Role.librarian, Operation.manageUsers), isFalse);
    expect(canPerform(Role.librarian, Operation.viewStats), isFalse);
    expect(canPerform(Role.librarian, Operation.hardDelete), isFalse);
  });

  test('администратор удаляет физически и управляет учётками', () {
    expect(canPerform(Role.admin, Operation.hardDelete), isTrue);
    expect(canPerform(Role.admin, Operation.restoreRecords), isTrue);
    expect(canPerform(Role.admin, Operation.manageUsers), isTrue);
    expect(canPerform(Role.admin, Operation.viewStats), isTrue);
  });

  test('пароль на регистрации проверяется по мере ввода', () {
    expect(V.passwordRules('short').ok, isFalse);
    expect(V.passwordRules('longenough').ok, isFalse);
    expect(V.passwordRules('longenough1').ok, isFalse);
    expect(V.passwordRules('Reader1!').ok, isTrue);
    expect(V.password()('abc'), isNotNull);
    expect(V.password()('Admin123!'), isNull);
  });
}
