#!/usr/bin/env node
'use strict';

const http = require('http');
const crypto = require('crypto');
const { URL } = require('url');

function arg(name, fallback) {
  const i = process.argv.indexOf(name);
  return i >= 0 && process.argv[i + 1] ? process.argv[i + 1] : fallback;
}

const PORT = Number(arg('--port', '8080'));
const TTL = Number(arg('--ttl', '900'));
const SECRET = 'calc-web-pr5';
const ORIGINS = arg('--origin', 'http://localhost:5555,http://127.0.0.1:5555')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

function hashPassword(password) {
  return crypto.createHash('sha256').update(String(password)).digest('hex');
}

function signToken(payload) {
  const body = Buffer.from(JSON.stringify(payload)).toString('base64url');
  const sig = crypto.createHmac('sha256', SECRET).update(body).digest('base64url');
  return `${body}.${sig}`;
}

function readToken(token) {
  if (!token || !token.includes('.')) return null;
  const [body, sig] = token.split('.');
  const expected = crypto.createHmac('sha256', SECRET).update(body).digest('base64url');
  if (sig !== expected) return null;
  try {
    return JSON.parse(Buffer.from(body, 'base64url').toString('utf8'));
  } catch {
    return null;
  }
}

function publicUser(user) {
  return {
    id: user.id,
    username: user.username,
    displayName: user.displayName,
    role: user.role,
    readerId: user.readerId ?? null,
  };
}

function issueTokens(user) {
  const now = Math.floor(Date.now() / 1000);
  return {
    accessToken: signToken({ sub: user.id, role: user.role, typ: 'access', exp: now + TTL }),
    refreshToken: signToken({ sub: user.id, typ: 'refresh', exp: now + 7 * 24 * 3600 }),
    user: publicUser(user),
  };
}

const genres = [
  { id: 1, name: 'Художественная', description: '', deletedAt: null },
  { id: 2, name: 'Фантастика', description: '', deletedAt: null },
  { id: 3, name: 'История', description: '', deletedAt: null },
  { id: 4, name: 'Финансы', description: '', deletedAt: null },
  { id: 5, name: 'Программирование', description: '', deletedAt: null },
];

const publishers = [
  { id: 1, name: 'АСТ', city: 'Москва', foundedYear: 1990, deletedAt: null },
  { id: 2, name: 'Эксмо', city: 'Москва', foundedYear: 1991, deletedAt: null },
  { id: 3, name: 'Питер', city: 'Санкт-Петербург', foundedYear: 1991, deletedAt: null },
  { id: 4, name: 'Капитал Пресс', city: 'Москва', foundedYear: 2005, deletedAt: null },
  { id: 5, name: 'МИФ', city: 'Москва', foundedYear: 2005, deletedAt: null },
];

const authors = [
  { id: 1, lastName: 'Толстой', firstName: 'Лев', country: 'Россия', birthYear: 1828, deletedAt: null },
  { id: 2, lastName: 'Достоевский', firstName: 'Фёдор', country: 'Россия', birthYear: 1821, deletedAt: null },
  { id: 3, lastName: 'Булгаков', firstName: 'Михаил', country: 'Россия', birthYear: 1891, deletedAt: null },
  { id: 4, lastName: 'Оруэлл', firstName: 'Джордж', country: 'Великобритания', birthYear: 1903, deletedAt: null },
  { id: 5, lastName: 'Брэдбери', firstName: 'Рэй', country: 'США', birthYear: 1920, deletedAt: null },
  { id: 6, lastName: 'Кинг', firstName: 'Стивен', country: 'США', birthYear: 1947, deletedAt: null },
  { id: 7, lastName: 'Мартин', firstName: 'Роберт', country: 'США', birthYear: 1952, deletedAt: null },
  { id: 8, lastName: 'Фаулер', firstName: 'Мартин', country: 'Великобритания', birthYear: 1963, deletedAt: null },
  { id: 9, lastName: 'Глуховский', firstName: 'Дмитрий', country: 'Россия', birthYear: 1979, deletedAt: null },
  { id: 10, lastName: 'Пелевин', firstName: 'Виктор', country: 'Россия', birthYear: 1962, deletedAt: null },
];

const books = [
  { id: 1, title: 'Война и мир', isbn: '978-5-17-118365-1', year: 1869, pages: 1274, publisherId: 1, authorIds: [1], genreIds: [1, 3], copiesTotal: 8, copiesAvailable: 3, deletedAt: null },
  { id: 2, title: 'Анна Каренина', isbn: '978-5-17-090331-3', year: 1877, pages: 864, publisherId: 1, authorIds: [1], genreIds: [1], copiesTotal: 5, copiesAvailable: 2, deletedAt: null },
  { id: 3, title: 'Преступление и наказание', isbn: '978-5-17-082589-3', year: 1866, pages: 608, publisherId: 2, authorIds: [2], genreIds: [1], copiesTotal: 6, copiesAvailable: 1, deletedAt: null },
  { id: 4, title: 'Идиот', isbn: '978-5-17-098211-0', year: 1869, pages: 640, publisherId: 2, authorIds: [2], genreIds: [1], copiesTotal: 4, copiesAvailable: 4, deletedAt: null },
  { id: 5, title: 'Мастер и Маргарита', isbn: '978-5-17-087892-8', year: 1967, pages: 480, publisherId: 1, authorIds: [3], genreIds: [1, 2], copiesTotal: 10, copiesAvailable: 4, deletedAt: null },
  { id: 6, title: 'Собачье сердце', isbn: '978-5-17-112004-5', year: 1925, pages: 160, publisherId: 1, authorIds: [3], genreIds: [1, 2], copiesTotal: 7, copiesAvailable: 5, deletedAt: null },
  { id: 7, title: '1984', isbn: '978-5-17-080115-6', year: 1949, pages: 320, publisherId: 2, authorIds: [4], genreIds: [2], copiesTotal: 9, copiesAvailable: 2, deletedAt: null },
  { id: 8, title: 'Скотный двор', isbn: '978-5-17-090990-2', year: 1945, pages: 112, publisherId: 2, authorIds: [4], genreIds: [1, 2], copiesTotal: 5, copiesAvailable: 5, deletedAt: null },
  { id: 9, title: '451 градус по Фаренгейту', isbn: '978-5-17-083001-9', year: 1953, pages: 256, publisherId: 2, authorIds: [5], genreIds: [2], copiesTotal: 6, copiesAvailable: 3, deletedAt: null },
  { id: 10, title: 'Вино из одуванчиков', isbn: '978-5-17-104332-2', year: 1957, pages: 320, publisherId: 1, authorIds: [5], genreIds: [1], copiesTotal: 4, copiesAvailable: 1, deletedAt: null },
  { id: 11, title: 'Сияние', isbn: '978-5-17-086541-6', year: 1977, pages: 544, publisherId: 2, authorIds: [6], genreIds: [1], copiesTotal: 5, copiesAvailable: 0, deletedAt: null },
  { id: 12, title: 'Оно', isbn: '978-5-17-102118-4', year: 1986, pages: 1116, publisherId: 2, authorIds: [6], genreIds: [1], copiesTotal: 3, copiesAvailable: 1, deletedAt: null },
  { id: 13, title: 'Чистый код', isbn: '978-5-4461-0960-9', year: 2008, pages: 464, publisherId: 3, authorIds: [7], genreIds: [5], copiesTotal: 8, copiesAvailable: 6, deletedAt: null },
  { id: 14, title: 'Идеальный программист', isbn: '978-5-459-01044-2', year: 2011, pages: 224, publisherId: 3, authorIds: [7], genreIds: [5], copiesTotal: 5, copiesAvailable: 4, deletedAt: null },
  { id: 15, title: 'Рефакторинг', isbn: '978-5-4461-0772-8', year: 2019, pages: 448, publisherId: 3, authorIds: [8], genreIds: [5], copiesTotal: 6, copiesAvailable: 3, deletedAt: null },
  { id: 16, title: 'Шаблоны корпоративных приложений', isbn: '978-5-4461-0994-4', year: 2002, pages: 544, publisherId: 3, authorIds: [8], genreIds: [5], copiesTotal: 4, copiesAvailable: 2, deletedAt: null },
  { id: 17, title: 'Метро 2033', isbn: '978-5-17-056106-1', year: 2005, pages: 384, publisherId: 1, authorIds: [9], genreIds: [2], copiesTotal: 7, copiesAvailable: 2, deletedAt: null },
  { id: 18, title: 'Текст', isbn: '978-5-17-112441-8', year: 2017, pages: 320, publisherId: 1, authorIds: [9], genreIds: [1], copiesTotal: 5, copiesAvailable: 5, deletedAt: null },
  { id: 19, title: 'Generation «П»', isbn: '978-5-17-080234-4', year: 1999, pages: 336, publisherId: 2, authorIds: [10], genreIds: [1], copiesTotal: 6, copiesAvailable: 3, deletedAt: null },
  { id: 20, title: 'Чапаев и Пустота', isbn: '978-5-17-098765-8', year: 1996, pages: 400, publisherId: 2, authorIds: [10], genreIds: [1, 2], copiesTotal: 4, copiesAvailable: 1, deletedAt: null },
  { id: 21, title: 'Деньги как инструмент', isbn: '978-5-9614-1234-7', year: 2018, pages: 288, publisherId: 4, authorIds: [8], genreIds: [4], copiesTotal: 5, copiesAvailable: 4, deletedAt: null },
  { id: 22, title: 'Личные финансы', isbn: '978-5-9614-2222-1', year: 2021, pages: 256, publisherId: 4, authorIds: [7], genreIds: [4], copiesTotal: 6, copiesAvailable: 6, deletedAt: null },
  { id: 23, title: 'Капитал для начинающих', isbn: '978-5-00146-333-0', year: 2020, pages: 312, publisherId: 5, authorIds: [8], genreIds: [4], copiesTotal: 4, copiesAvailable: 2, deletedAt: null },
  { id: 24, title: 'История денег', isbn: '978-5-17-134001-2', year: 2014, pages: 400, publisherId: 5, authorIds: [1], genreIds: [3, 4], copiesTotal: 3, copiesAvailable: 3, deletedAt: null },
];

const readers = [
  { id: 1, lastName: 'Иванов', firstName: 'Пётр', email: 'ivanov@mail.test', phone: '+7 900 111-22-33', card: { number: 'LC-1001', issuedAt: '2024-01-10', expiresAt: '2027-01-10', active: true }, deletedAt: null },
  { id: 2, lastName: 'Петрова', firstName: 'Анна', email: 'petrova@mail.test', phone: '+7 900 222-33-44', card: { number: 'LC-1002', issuedAt: '2024-03-02', expiresAt: '2026-03-02', active: true }, deletedAt: null },
  { id: 3, lastName: 'Сидоров', firstName: 'Илья', email: 'sidorov@mail.test', phone: '+7 900 333-44-55', card: { number: 'LC-1003', issuedAt: '2023-09-01', expiresAt: '2026-09-01', active: true }, deletedAt: null },
  { id: 4, lastName: 'Кузнецова', firstName: 'Мария', email: 'kuznetsova@mail.test', phone: '+7 900 444-55-66', card: { number: 'LC-1004', issuedAt: '2025-02-14', expiresAt: '2028-02-14', active: true }, deletedAt: null },
  { id: 5, lastName: 'Орлов', firstName: 'Никита', email: 'orlov@mail.test', phone: '+7 900 555-66-77', card: { number: 'LC-1005', issuedAt: '2024-06-20', expiresAt: '2027-06-20', active: false }, deletedAt: null },
  { id: 6, lastName: 'Морозова', firstName: 'Елена', email: 'morozova@mail.test', phone: '+7 900 666-77-88', card: { number: 'LC-1006', issuedAt: '2022-11-05', expiresAt: '2025-11-05', active: true }, deletedAt: null },
  { id: 7, lastName: 'Волков', firstName: 'Артём', email: 'volkov@mail.test', phone: '+7 900 777-88-99', card: { number: 'LC-1007', issuedAt: '2025-01-08', expiresAt: '2028-01-08', active: true }, deletedAt: null },
  { id: 8, lastName: 'Соколова', firstName: 'Дарья', email: 'sokolova@mail.test', phone: '+7 900 888-99-00', card: { number: 'LC-1008', issuedAt: '2024-08-19', expiresAt: '2027-08-19', active: true }, deletedAt: null },
];

const users = [
  { id: 1, username: 'reader', passwordHash: hashPassword('Reader1!'), displayName: 'Анна Читатель', role: 'reader', readerId: 2 },
  { id: 2, username: 'librarian', passwordHash: hashPassword('Librarian1!'), displayName: 'Игорь Библиотекарь', role: 'librarian', readerId: null },
  { id: 3, username: 'admin', passwordHash: hashPassword('Admin123!'), displayName: 'Мария Админ', role: 'admin', readerId: null },
];

const loans = [
  { id: 1, bookId: 7, readerId: 2, userId: 1, issuedAt: '2026-08-10', dueAt: '2026-09-10', returnedAt: null, extended: false },
  { id: 2, bookId: 5, readerId: 2, userId: 1, issuedAt: '2026-07-01', dueAt: '2026-08-01', returnedAt: '2026-07-28', extended: false },
];

const db = { books, authors, genres, publishers, readers, users, loans };
const nextId = {
  books: 25,
  authors: 11,
  genres: 6,
  publishers: 6,
  readers: 9,
  users: 4,
  loans: 3,
};

function expandLoan(loan) {
  const book = byId(books, loan.bookId);
  const reader = byId(readers, loan.readerId);
  return {
    ...loan,
    bookTitle: book ? book.title : `книга ${loan.bookId}`,
    readerName: reader ? `${reader.lastName} ${reader.firstName}` : `читатель ${loan.readerId}`,
  };
}

function actorFrom(req) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : '';
  const payload = readToken(token);
  if (!payload) return { error: 401, message: 'Требуется вход в систему.' };
  if (payload.exp && payload.exp < Date.now() / 1000) {
    return { error: 401, message: 'Срок действия токена истёк.' };
  }
  const user = byId(users, payload.sub);
  if (!user) return { error: 401, message: 'Требуется вход в систему.' };
  return { user };
}

function deny(res, origin, actor) {
  send(res, origin, actor.error || 403, { message: actor.message || 'Недостаточно прав для этого действия.' });
}

function send(res, origin, status, body) {
  const headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': origin || ORIGINS[0],
    'Access-Control-Allow-Methods': 'GET,POST,PUT,PATCH,DELETE,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Credentials': 'true',
  };
  res.writeHead(status, headers);
  res.end(body == null ? '' : JSON.stringify(body));
}

function readBody(req) {
  return new Promise((resolve) => {
    const chunks = [];
    req.on('data', (c) => chunks.push(c));
    req.on('end', () => {
      if (!chunks.length) return resolve({});
      try {
        resolve(JSON.parse(Buffer.concat(chunks).toString('utf8')));
      } catch {
        resolve({});
      }
    });
  });
}

function byId(list, id) {
  return list.find((item) => item.id === id);
}

function expandBook(book) {
  return {
    ...book,
    publisher: byId(publishers, book.publisherId) || { id: book.publisherId, name: String(book.publisherId) },
    authors: book.authorIds.map((id) => byId(authors, id)).filter(Boolean),
    genres: book.genreIds.map((id) => byId(genres, id)).filter(Boolean),
  };
}

function paginate(rows, page, size) {
  const total = rows.length;
  const from = (page - 1) * size;
  return { items: rows.slice(from, from + size), page, size, total };
}

function sortRows(rows, sort, fallback) {
  const [field, dir] = (sort || `${fallback},asc`).split(',');
  const mul = dir === 'desc' ? -1 : 1;
  return [...rows].sort((a, b) => {
    const av = a[field];
    const bv = b[field];
    if (typeof av === 'number' && typeof bv === 'number') return (av - bv) * mul;
    return String(av ?? '').localeCompare(String(bv ?? ''), 'ru') * mul;
  });
}

function visible(list, includeDeleted) {
  return includeDeleted ? list : list.filter((item) => !item.deletedAt);
}

function collection(name) {
  return db[name];
}

async function handle(req, res) {
  const origin = ORIGINS.includes(req.headers.origin) ? req.headers.origin : ORIGINS[0];
  if (req.method === 'OPTIONS') {
    send(res, origin, 204, null);
    return;
  }

  const url = new URL(req.url, `http://127.0.0.1:${PORT}`);
  if (!url.pathname.startsWith('/api')) {
    send(res, origin, 404, { message: 'Не найден префикс /api' });
    return;
  }

  const delay = Number(url.searchParams.get('__delay') || 0);
  if (delay > 0) await new Promise((r) => setTimeout(r, delay));
  const fail = Number(url.searchParams.get('__fail') || 0);
  if (fail) {
    send(res, origin, fail, { message: `Учебная ошибка ${fail}` });
    return;
  }

  const path = url.pathname.replace(/^\/api/, '') || '/';
  const parts = path.split('/').filter(Boolean);
  const q = Object.fromEntries(url.searchParams.entries());
  const page = Number(q.page || 1);
  const size = Number(q.size || 10);
  const includeDeleted = q.includeDeleted === '1' || q.includeDeleted === 'true';

  if (req.method === 'GET' && path === '/__health') {
    send(res, origin, 200, { status: 'ok' });
    return;
  }

  if (parts[0] === 'auth' && req.method === 'POST' && parts[1] === 'login') {
    const body = await readBody(req);
    const user = users.find((u) => u.username === body.username && u.passwordHash === hashPassword(body.password));
    if (!user) return send(res, origin, 401, { message: 'Неверный логин или пароль.' });
    send(res, origin, 200, issueTokens(user));
    return;
  }

  if (parts[0] === 'auth' && req.method === 'POST' && parts[1] === 'register') {
    const body = await readBody(req);
    if (!body.username || !body.password || !body.displayName) {
      return send(res, origin, 422, { message: 'Ошибка валидации', errors: { username: 'Заполните все поля' } });
    }
    if (users.some((u) => u.username === body.username)) {
      return send(res, origin, 422, { message: 'Ошибка валидации', errors: { username: 'Логин уже занят' } });
    }
    const created = {
      id: nextId.users++,
      username: body.username,
      passwordHash: hashPassword(body.password),
      displayName: body.displayName,
      role: 'reader',
      readerId: null,
    };
    users.push(created);
    send(res, origin, 201, issueTokens(created));
    return;
  }

  if (parts[0] === 'auth' && req.method === 'POST' && parts[1] === 'refresh') {
    const body = await readBody(req);
    const payload = readToken(body.refreshToken);
    if (!payload || payload.typ !== 'refresh') {
      return send(res, origin, 401, { message: 'Токен обновления недействителен.' });
    }
    if (payload.exp && payload.exp < Date.now() / 1000) {
      return send(res, origin, 401, { message: 'Токен обновления истёк.' });
    }
    const user = byId(users, payload.sub);
    if (!user) return send(res, origin, 401, { message: 'Требуется вход в систему.' });
    send(res, origin, 200, issueTokens(user));
    return;
  }

  if (parts[0] === 'auth' && req.method === 'GET' && parts[1] === 'me') {
    const actor = actorFrom(req);
    if (actor.error) return deny(res, origin, actor);
    send(res, origin, 200, publicUser(actor.user));
    return;
  }

  const actor = actorFrom(req);
  if (actor.error) return deny(res, origin, actor);
  const role = actor.user.role;
  const isAdmin = role === 'admin';
  const isLibrarian = role === 'librarian' || isAdmin;
  const isReader = role === 'reader';

  if (parts[0] === 'loans' && parts[1] === 'mine' && req.method === 'GET') {
    if (!isReader) return send(res, origin, 403, { message: 'Мои выдачи доступны только читателю.' });
    const rows = loans.filter((l) => l.userId === actor.user.id);
    send(res, origin, 200, paginate(rows.map(expandLoan), page, size));
    return;
  }

  if (parts[0] === 'loans' && req.method === 'GET' && parts.length === 1) {
    if (!isLibrarian) return send(res, origin, 403, { message: 'Недостаточно прав для этого действия.' });
    send(res, origin, 200, paginate(loans.map(expandLoan), page, size));
    return;
  }

  if (parts[0] === 'loans' && req.method === 'POST' && parts.length === 1) {
    if (!isLibrarian) return send(res, origin, 403, { message: 'Недостаточно прав для этого действия.' });
    const body = await readBody(req);
    const book = byId(books, Number(body.bookId));
    const reader = byId(readers, Number(body.readerId));
    if (!book || !reader) return send(res, origin, 404, { message: 'Запись не найдена.' });
    if (book.copiesAvailable <= 0) return send(res, origin, 409, { message: 'Нет свободных экземпляров' });
    book.copiesAvailable -= 1;
    const created = {
      id: nextId.loans++,
      bookId: book.id,
      readerId: reader.id,
      userId: actor.user.id,
      issuedAt: new Date().toISOString().slice(0, 10),
      dueAt: new Date(Date.now() + 14 * 86400000).toISOString().slice(0, 10),
      returnedAt: null,
      extended: false,
    };
    loans.push(created);
    send(res, origin, 201, expandLoan(created));
    return;
  }

  if (parts[0] === 'loans' && parts[2] === 'extend' && req.method === 'POST') {
    const loan = byId(loans, Number(parts[1]));
    if (!loan) return send(res, origin, 404, { message: 'Запись не найдена.' });
    if (!isReader || loan.userId !== actor.user.id) {
      return send(res, origin, 403, { message: 'Продлить можно только свою выдачу.' });
    }
    if (loan.returnedAt) return send(res, origin, 409, { message: 'Выдача уже закрыта.' });
    if (loan.extended) return send(res, origin, 409, { message: 'Срок уже продлевали.' });
    const due = new Date(loan.dueAt);
    due.setDate(due.getDate() + 14);
    loan.dueAt = due.toISOString().slice(0, 10);
    loan.extended = true;
    send(res, origin, 200, expandLoan(loan));
    return;
  }

  if (parts[0] === 'loans' && parts[2] === 'return' && req.method === 'POST') {
    if (!isLibrarian) return send(res, origin, 403, { message: 'Недостаточно прав для этого действия.' });
    const loan = byId(loans, Number(parts[1]));
    if (!loan) return send(res, origin, 404, { message: 'Запись не найдена.' });
    if (!loan.returnedAt) {
      loan.returnedAt = new Date().toISOString().slice(0, 10);
      const book = byId(books, loan.bookId);
      if (book) book.copiesAvailable += 1;
    }
    send(res, origin, 200, expandLoan(loan));
    return;
  }

  if (parts[0] === 'users' && req.method === 'GET' && parts.length === 1) {
    if (!isAdmin) return send(res, origin, 403, { message: 'Управление пользователями доступно только администратору.' });
    send(res, origin, 200, { items: users.map(publicUser), page: 1, size: users.length, total: users.length });
    return;
  }

  if (parts[0] === 'users' && req.method === 'PUT' && parts.length === 2) {
    if (!isAdmin) return send(res, origin, 403, { message: 'Управление пользователями доступно только администратору.' });
    const user = byId(users, Number(parts[1]));
    if (!user) return send(res, origin, 404, { message: 'Запись не найдена.' });
    const body = await readBody(req);
    if (body.role && ['reader', 'librarian', 'admin'].includes(body.role)) user.role = body.role;
    send(res, origin, 200, publicUser(user));
    return;
  }

  if (parts[0] === 'stats' && req.method === 'GET') {
    if (!isAdmin) return send(res, origin, 403, { message: 'Статистика доступна только администратору.' });
    send(res, origin, 200, {
      books: books.filter((b) => !b.deletedAt).length,
      authors: authors.filter((a) => !a.deletedAt).length,
      readers: readers.filter((r) => !r.deletedAt).length,
      activeLoans: loans.filter((l) => !l.returnedAt).length,
      users: users.length,
    });
    return;
  }

  const write = req.method !== 'GET';
  if (includeDeleted && !isAdmin) {
    return send(res, origin, 403, { message: 'Просмотр удалённых записей доступен только администратору.' });
  }
  if (write && !isLibrarian) {
    return send(res, origin, 403, { message: 'Недостаточно прав для этого действия.' });
  }
  if ((q.hard === 'true' || parts[2] === 'restore') && !isAdmin) {
    return send(res, origin, 403, { message: 'Физическое удаление и восстановление доступны только администратору.' });
  }

  if (parts[0] === 'books' && parts[1] === 'bulk-delete' && req.method === 'POST') {
    const body = await readBody(req);
    const ids = body.ids || [];
    let deleted = 0;
    for (const id of ids) {
      const item = byId(books, id);
      if (item && !item.deletedAt) {
        item.deletedAt = new Date().toISOString();
        deleted += 1;
      }
    }
    send(res, origin, 200, { deleted });
    return;
  }

  if (parts[0] === 'books' && parts[2] === 'issue' && req.method === 'POST') {
    const item = byId(books, Number(parts[1]));
    if (!item) return send(res, origin, 404, { message: 'Запись не найдена.' });
    if (item.copiesAvailable <= 0) {
      return send(res, origin, 409, { message: 'Нет свободных экземпляров' });
    }
    item.copiesAvailable -= 1;
    send(res, origin, 200, expandBook(item));
    return;
  }

  if (parts[0] === 'books') {
    if (req.method === 'GET' && parts.length === 1) {
      let rows = visible(books, includeDeleted);
      const search = (q.search || '').trim().toLowerCase();
      if (search) rows = rows.filter((b) => b.title.toLowerCase().includes(search) || b.isbn.toLowerCase().includes(search));
      if (q.genreId) rows = rows.filter((b) => b.genreIds.includes(Number(q.genreId)));
      if (q.publisherId) rows = rows.filter((b) => b.publisherId === Number(q.publisherId));
      if (q.yearFrom) rows = rows.filter((b) => b.year >= Number(q.yearFrom));
      if (q.yearTo) rows = rows.filter((b) => b.year <= Number(q.yearTo));
      rows = sortRows(rows, q.sort, 'title');
      const result = paginate(rows, page, size);
      result.items = result.items.map(expandBook);
      send(res, origin, 200, result);
      return;
    }
    if (req.method === 'GET' && parts.length === 2) {
      const item = byId(books, Number(parts[1]));
      if (!item) return send(res, origin, 404, { message: 'Запись не найдена.' });
      send(res, origin, 200, expandBook(item));
      return;
    }
    if (req.method === 'POST' && parts.length === 1) {
      const body = await readBody(req);
      if (books.some((b) => b.isbn === body.isbn)) {
        return send(res, origin, 422, { message: 'Ошибка валидации', errors: { isbn: 'ISBN уже используется' } });
      }
      const created = {
        id: nextId.books++,
        title: body.title,
        isbn: body.isbn,
        year: Number(body.year),
        pages: Number(body.pages),
        publisherId: Number(body.publisherId),
        authorIds: body.authorIds || [],
        genreIds: body.genreIds || [],
        copiesTotal: Number(body.copiesTotal || 1),
        copiesAvailable: Number(body.copiesAvailable ?? body.copiesTotal ?? 1),
        deletedAt: null,
      };
      books.push(created);
      send(res, origin, 201, expandBook(created));
      return;
    }
    if (req.method === 'PUT' && parts.length === 2) {
      const item = byId(books, Number(parts[1]));
      if (!item) return send(res, origin, 404, { message: 'Запись не найдена.' });
      const body = await readBody(req);
      if (books.some((b) => b.isbn === body.isbn && b.id !== item.id)) {
        return send(res, origin, 422, { message: 'Ошибка валидации', errors: { isbn: 'ISBN уже используется' } });
      }
      Object.assign(item, {
        title: body.title,
        isbn: body.isbn,
        year: Number(body.year),
        pages: Number(body.pages),
        publisherId: Number(body.publisherId),
        authorIds: body.authorIds || item.authorIds,
        genreIds: body.genreIds || item.genreIds,
        copiesTotal: Number(body.copiesTotal),
        copiesAvailable: Number(body.copiesAvailable),
      });
      send(res, origin, 200, expandBook(item));
      return;
    }
    if (req.method === 'DELETE' && parts.length === 2) {
      const item = byId(books, Number(parts[1]));
      if (!item) return send(res, origin, 404, { message: 'Запись не найдена.' });
      if (q.hard === 'true') {
        const i = books.indexOf(item);
        books.splice(i, 1);
      } else {
        item.deletedAt = new Date().toISOString();
      }
      send(res, origin, 204, null);
      return;
    }
    if (req.method === 'POST' && parts[2] === 'restore') {
      const item = byId(books, Number(parts[1]));
      if (!item) return send(res, origin, 404, { message: 'Запись не найдена.' });
      item.deletedAt = null;
      send(res, origin, 200, expandBook(item));
      return;
    }
  }

  const name = parts[0];
  if (!['authors', 'genres', 'publishers', 'readers'].includes(name)) {
    send(res, origin, 404, { message: 'Неизвестный ресурс' });
    return;
  }
  const list = collection(name);

  if (req.method === 'POST' && parts[1] === 'bulk-delete') {
    const body = await readBody(req);
    let deleted = 0;
    for (const id of body.ids || []) {
      const item = byId(list, id);
      if (name === 'publishers' && item) {
        const linked = books.filter((b) => b.publisherId === item.id && !b.deletedAt).length;
        if (linked > 0) {
          return send(res, origin, 409, {
            message: `Нельзя удалить издательство: на него ссылаются ${linked} книг(и).`,
          });
        }
      }
      if (item && !item.deletedAt) {
        item.deletedAt = new Date().toISOString();
        deleted += 1;
      }
    }
    send(res, origin, 200, { deleted });
    return;
  }

  if (req.method === 'GET' && parts.length === 1) {
    let rows = visible(list, includeDeleted);
    const search = (q.search || '').trim().toLowerCase();
    if (search) {
      rows = rows.filter((item) =>
        Object.values(item).some((v) => String(v).toLowerCase().includes(search)),
      );
    }
    if (q.country) rows = rows.filter((item) => item.country === q.country);
    const fallback = name === 'authors' || name === 'readers' ? 'lastName' : 'name';
    rows = sortRows(rows, q.sort, fallback);
    send(res, origin, 200, paginate(rows, page, size));
    return;
  }

  if (req.method === 'GET' && parts.length === 2) {
    const item = byId(list, Number(parts[1]));
    if (!item) return send(res, origin, 404, { message: 'Запись не найдена.' });
    send(res, origin, 200, item);
    return;
  }

  if (req.method === 'POST' && parts.length === 1) {
    const body = await readBody(req);
    if (name === 'readers' && list.some((r) => r.email === body.email)) {
      return send(res, origin, 422, { message: 'Ошибка валидации', errors: { email: 'Email уже используется' } });
    }
    const created = { ...body, id: nextId[name]++, deletedAt: null };
    list.push(created);
    send(res, origin, 201, created);
    return;
  }

  if (req.method === 'PUT' && parts.length === 2) {
    const item = byId(list, Number(parts[1]));
    if (!item) return send(res, origin, 404, { message: 'Запись не найдена.' });
    const body = await readBody(req);
    if (name === 'readers' && list.some((r) => r.email === body.email && r.id !== item.id)) {
      return send(res, origin, 422, { message: 'Ошибка валидации', errors: { email: 'Email уже используется' } });
    }
    Object.assign(item, body, { id: item.id });
    send(res, origin, 200, item);
    return;
  }

  if (req.method === 'DELETE' && parts.length === 2) {
    const item = byId(list, Number(parts[1]));
    if (!item) return send(res, origin, 404, { message: 'Запись не найдена.' });
    if (name === 'publishers') {
      const linked = books.filter((b) => b.publisherId === item.id && !b.deletedAt).length;
      if (linked > 0) {
        return send(res, origin, 409, {
          message: `Нельзя удалить издательство: на него ссылаются ${linked} книг(и).`,
        });
      }
    }
    if (q.hard === 'true') {
      list.splice(list.indexOf(item), 1);
    } else {
      item.deletedAt = new Date().toISOString();
    }
    send(res, origin, 204, null);
    return;
  }

  if (req.method === 'POST' && parts[2] === 'restore') {
    const item = byId(list, Number(parts[1]));
    if (!item) return send(res, origin, 404, { message: 'Запись не найдена.' });
    item.deletedAt = null;
    send(res, origin, 200, item);
    return;
  }

  send(res, origin, 404, { message: 'Маршрут не найден' });
}

http.createServer((req, res) => {
  handle(req, res).catch((err) => {
    console.error(err);
    send(res, ORIGINS[0], 500, { message: 'Ошибка на сервере.' });
  });
}).listen(PORT, () => {
  console.log(`mock API http://127.0.0.1:${PORT}/api/__health`);
  console.log(`CORS origins: ${ORIGINS.join(', ')}`);
  console.log(`access token TTL: ${TTL}s`);
});
