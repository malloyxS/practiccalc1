enum Role {
  reader(1, 'reader', 'Читатель'),
  librarian(2, 'librarian', 'Библиотекарь'),
  admin(3, 'admin', 'Администратор');

  final int level;
  final String id;
  final String title;

  const Role(this.level, this.id, this.title);

  static Role parse(String? value) {
    return Role.values.firstWhere(
      (role) => role.id == value || role.name == value,
      orElse: () => Role.reader,
    );
  }
}

enum Operation {
  viewCatalog,
  viewOwnLoans,
  extendLoan,
  manageBooks,
  manageCatalogs,
  manageReaders,
  issueLoan,
  closeLoan,
  hardDelete,
  restoreRecords,
  manageUsers,
  viewStats,
}

bool canPerform(Role role, Operation operation) {
  return switch (operation) {
    Operation.viewCatalog => true,
    Operation.viewOwnLoans || Operation.extendLoan => role == Role.reader,
    Operation.manageBooks ||
    Operation.manageCatalogs ||
    Operation.manageReaders ||
    Operation.issueLoan ||
    Operation.closeLoan =>
      role.level >= Role.librarian.level,
    Operation.hardDelete ||
    Operation.restoreRecords ||
    Operation.manageUsers ||
    Operation.viewStats =>
      role == Role.admin,
  };
}
