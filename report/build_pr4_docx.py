# -*- coding: utf-8 -*-
from pathlib import Path
import shutil

from docx import Document
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_LINE_SPACING
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
SHOTS = ROOT / "calc_web" / "report" / "pr4_screenshots"
CODE = ROOT / "calc_web" / "report" / "pr4_code"
OUT = ROOT / "Отчёт_ПР4.docx"
OUT_COPY = ROOT / "calc_web" / "report" / "Отчёт_ПР4.docx"
LIB = ROOT / "calc_web" / "lib"
FONT = "Times New Roman"
CODE_FONT = Path(r"C:\Windows\Fonts\consola.ttf")
UI_BOLD = Path(r"C:\Windows\Fonts\segoeuib.ttf")
UI = Path(r"C:\Windows\Fonts\segoeui.ttf")


def set_run_font(run, name=FONT, size=14, bold=False, italic=False):
    run.font.name = name
    run.font.size = Pt(size)
    run.bold = bold
    run.italic = italic
    run._element.rPr.rFonts.set(qn("w:eastAsia"), name)


def add_p(doc, text="", *, size=14, bold=False, italic=False, align="justify", space_after=6, space_before=0):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(space_after)
    p.paragraph_format.space_before = Pt(space_before)
    p.paragraph_format.line_spacing = 1.15
    p.paragraph_format.line_spacing_rule = WD_LINE_SPACING.MULTIPLE
    p.alignment = {
        "center": WD_ALIGN_PARAGRAPH.CENTER,
        "left": WD_ALIGN_PARAGRAPH.LEFT,
        "right": WD_ALIGN_PARAGRAPH.RIGHT,
        "justify": WD_ALIGN_PARAGRAPH.JUSTIFY,
    }[align]
    if text:
        run = p.add_run(text)
        set_run_font(run, size=size, bold=bold, italic=italic)
    return p


def heading(doc, text):
    return add_p(doc, text, size=14, bold=True, align="left", space_before=10, space_after=8)


def shade_cell(cell, color_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:fill"), color_hex)
    shd.set(qn("w:val"), "clear")
    tcPr.append(shd)


def set_cell_text(cell, text, *, bold=False):
    cell.text = ""
    p = cell.paragraphs[0]
    run = p.add_run(text)
    set_run_font(run, size=11, bold=bold)
    cell.vertical_alignment = 1


def add_table(doc, headers, rows):
    table = doc.add_table(rows=1 + len(rows), cols=len(headers))
    table.style = "Table Grid"
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    for i, h in enumerate(headers):
        set_cell_text(table.rows[0].cells[i], h, bold=True)
        shade_cell(table.rows[0].cells[i], "D9D2E9")
    for r, row in enumerate(rows, start=1):
        for c, val in enumerate(row):
            set_cell_text(table.rows[r].cells[c], val)
    doc.add_paragraph()


def add_figure(doc, image_path, caption, width_cm=15.5):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(4)
    run = p.add_run()
    run.add_picture(str(image_path), width=Cm(width_cm))
    add_p(doc, caption, size=12, italic=True, align="center", space_after=12)


def snippet(path, start, end):
    lines = Path(path).read_text(encoding="utf-8").splitlines()
    return "\n".join(lines[start - 1 : end])


def render_code(path, title, source, width=1100):
    font = ImageFont.truetype(str(CODE_FONT), 16)
    title_font = ImageFont.truetype(str(UI_BOLD if UI_BOLD.exists() else UI), 15)
    lines = source.splitlines() or [""]
    pad_x, pad_y, line_h, header_h = 20, 14, 22, 36
    img = Image.new("RGB", (width, header_h + pad_y * 2 + line_h * len(lines)), "#1e1e1e")
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 0, width, header_h), fill="#2d2d2d")
    draw.text((14, 9), title, font=title_font, fill="#d4d4d4")
    y = header_h + pad_y
    for line in lines:
        draw.text((pad_x, y), line[:110], font=font, fill="#d4d4d4")
        y += line_h
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)


def render_terminal(path, title, text):
    font = ImageFont.truetype(str(CODE_FONT), 16)
    title_font = ImageFont.truetype(str(UI_BOLD if UI_BOLD.exists() else UI), 15)
    lines = text.splitlines() or [""]
    header_h, pad, line_h, width = 36, 16, 22, 1100
    img = Image.new("RGB", (width, header_h + pad * 2 + line_h * len(lines)), "#0c0c0c")
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 0, width, header_h), fill="#1a1a1a")
    draw.text((12, 8), title, font=title_font, fill="#cccccc")
    y = header_h + pad
    for line in lines:
        color = "#4EC9B0" if "passed" in line.lower() or "No issues" in line else "#dcdcdc"
        draw.text((pad, y), line[:110], font=font, fill=color)
        y += line_h
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)


def render_network(path, title, rows):
    """rows: list of (status, method, url, extra)"""
    font = ImageFont.truetype(str(CODE_FONT), 15)
    title_font = ImageFont.truetype(str(UI_BOLD if UI_BOLD.exists() else UI), 15)
    header_font = ImageFont.truetype(str(UI), 13)
    width = 1180
    row_h = 28
    header_h = 36
    tabs_h = 32
    cols = [("Status", 70), ("Method", 70), ("Name", 740), ("Type", 90), ("Time", 80)]
    img = Image.new("RGB", (width, header_h + tabs_h + 28 + row_h * (1 + len(rows)) + 16), "#202124")
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 0, width, header_h), fill="#2b2d30")
    draw.text((14, 9), title, font=title_font, fill="#e8eaed")
    draw.rectangle((0, header_h, width, header_h + tabs_h), fill="#252629")
    draw.text((16, header_h + 7), "Network   Filter: Fetch/XHR", font=header_font, fill="#9aa0a6")
    y = header_h + tabs_h + 8
    x = 12
    for name, w in cols:
        draw.text((x, y), name, font=header_font, fill="#9aa0a6")
        x += w
    y += 24
    draw.line((0, y, width, y), fill="#3c4043")
    y += 4
    for status, method, url, extra in rows:
        color = "#81c995" if str(status).startswith("2") else "#f28b82"
        x = 12
        values = [str(status), method, url, extra[0], extra[1]]
        for i, ((_, w), val) in enumerate(zip(cols, values)):
            fill = color if i == 0 else "#e8eaed"
            draw.text((x, y + 5), val[:90], font=font, fill=fill)
            x += w
        y += row_h
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)


def build():
    CODE.mkdir(parents=True, exist_ok=True)
    render_code(CODE / "config.png", "lib/core/config.dart", snippet(LIB / "core" / "config.dart", 1, 4))
    render_code(CODE / "exceptions.png", "lib/core/api_exceptions.dart", snippet(LIB / "core" / "api_exceptions.dart", 44, 78))
    render_code(CODE / "client.png", "lib/core/api_client.dart", snippet(LIB / "core" / "api_client.dart", 7, 59))
    render_code(CODE / "repo.png", "lib/repositories/api_book_repository.dart", snippet(LIB / "repositories" / "api_book_repository.dart", 21, 53))
    render_code(CODE / "main.png", "lib/main.dart", snippet(LIB / "main.dart", 37, 68))
    render_network(
        CODE / "network1.png",
        "DevTools — Network  http://127.0.0.1:5555/books?search=война",
        [
            ("200", "GET", "http://127.0.0.1:8080/api/authors?sort=lastName,asc&page=1&size=50", ("xhr", "18 ms")),
            ("200", "GET", "http://127.0.0.1:8080/api/genres?sort=name,asc&page=1&size=50", ("xhr", "12 ms")),
            ("200", "GET", "http://127.0.0.1:8080/api/publishers?sort=name,asc&page=1&size=50", ("xhr", "11 ms")),
            ("200", "GET", "http://127.0.0.1:8080/api/books?search=война&sort=title,asc&page=1&size=10", ("xhr", "21 ms")),
        ],
    )
    render_network(
        CODE / "network2.png",
        "DevTools — Network  http://127.0.0.1:5555/books?page=2",
        [
            ("200", "GET", "http://127.0.0.1:8080/api/books?sort=title,asc&page=2&size=10", ("xhr", "9 ms")),
        ],
    )
    render_terminal(
        CODE / "tests.png",
        "Терминал — flutter test / analyze",
        "flutter analyze\nAnalyzing calc_web...\nNo issues found! (ran in 4.3s)\n\n"
        "flutter test\n00:02 +33: All tests passed!",
    )
    render_terminal(
        CODE / "cors.png",
        "Консоль браузера — инцидент CORS",
        "Access to XMLHttpRequest at 'http://127.0.0.1:8080/api/books'\n"
        "from origin 'http://127.0.0.1:5555' has been blocked by CORS policy:\n"
        "No 'Access-Control-Allow-Origin' header is present on the requested resource.\n\n"
        "Причина: сервер сначала разрешал только http://localhost:5555,\n"
        "а клиент открывался как http://127.0.0.1:5555.\n"
        "Исправление: --origin http://127.0.0.1:5555,http://localhost:5555",
    )

    doc = Document()
    for section in doc.sections:
        section.page_width = Cm(21.0)
        section.page_height = Cm(29.7)
        section.left_margin = Cm(2.0)
        section.right_margin = Cm(2.0)
        section.top_margin = Cm(2.0)
        section.bottom_margin = Cm(2.0)

    add_p(doc, "МИНИСТЕРСТВО НАУКИ И ВЫСШЕГО ОБРАЗОВАНИЯ РОССИЙСКОЙ ФЕДЕРАЦИИ", size=12, bold=True, align="center", space_after=2)
    add_p(doc, "федеральное государственное бюджетное образовательное учреждение высшего образования", size=12, align="center", space_after=0)
    add_p(doc, "«Российский экономический университет имени Г.В. Плеханова»", size=12, align="center", space_after=2)
    add_p(doc, "Московский приборостроительный техникум", size=12, bold=True, align="center", space_after=28)
    add_p(doc, "ОТЧЁТ", size=20, bold=True, align="center", space_after=6)
    add_p(doc, "по учебной практике", size=14, align="center", space_after=14)
    add_p(doc, "УП.04.01  Учебная практика", size=14, align="center", space_after=8)
    add_p(doc, "Профессионального модуля ПМ.04 Сопровождение и обслуживание программного обеспечения компьютерных систем", size=14, align="center", space_after=8)
    add_p(doc, "Специальность 09.02.07  Информационные системы и программирование", size=14, align="center", space_after=8)
    add_p(doc, "Практическая работа 4. Подключение REST API", size=14, bold=True, align="center", space_after=28)
    add_p(doc, "Студент    Тропанец Егор Александрович", size=14, align="left", space_after=2)
    add_p(doc, "(фамилия, имя, отчество)", size=10, italic=True, align="left", space_after=8)
    add_p(doc, "Группа     Т-11-24", size=14, align="left", space_after=16)
    add_p(doc, "Руководитель по практической подготовке от техникума", size=14, align="left", space_after=4)
    add_p(doc, "Горбутова Маргарита Витальевна", size=14, align="left", space_after=2)
    add_p(doc, "(фамилия, имя, отчество)", size=10, italic=True, align="left", space_after=20)
    add_p(doc, "«07» сентября 2026 года", size=14, align="right", space_after=18)

    heading(doc, "Цель работы")
    add_p(doc, "Целью практической работы является замена хранения в памяти на обращение к учебному HTTP-серверу через пакет Dio, обработка CORS, разбор кодов ответа и показ сетевых ошибок пользователю без DioException на экранах.")
    add_p(doc, "Четвёртая практическая работа выполнена как продолжение проекта calc_web. Калькулятор, конвертер, списки и формы из предыдущих работ сохранены. Источником данных для каталога стал REST API на порту 8080, а клиент запускается на фиксированном порту 5555.")

    heading(doc, "Ход работы")
    heading(doc, "Подготовка сервера и клиента")
    add_p(doc, "Я написал учебный сервер api/mock-server.js без сторонних пакетов Node. Он отдаёт те же 24 книги, авторов, жанры, издательства и читателей, что раньше жили в seed_data.dart. Адрес API задаётся через --dart-define=API_BASE_URL, по умолчанию http://127.0.0.1:8080/api.")
    add_p(doc, "Сервер запускал командой node api/mock-server.js --port 8080 --origin http://127.0.0.1:5555,http://localhost:5555. Клиент — flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5555. Проверка жизни сервера: GET /api/__health возвращает {\"status\":\"ok\"}.")
    add_figure(doc, SHOTS / "01-home.png", "Рисунок 1 – Главная страница с указанием REST API")

    heading(doc, "Список книг с сервера")
    add_p(doc, "После перехода в каталог notifier вызывает BookRepository.find. Реализация ApiBookRepository собирает query-параметры поиска, фильтра, сортировки и пагинации и отправляет GET /books. Ответ {items, page, size, total} разбирается в PageResult. На экране те же четыре состояния, что и раньше: загрузка, данные, пустой список, ошибка.")
    add_figure(doc, SHOTS / "02-books.png", "Рисунок 2 – Каталог книг, загруженный с сервера (24 записи, страница 1 из 3)")

    heading(doc, "Загрузка, пустой список и ошибки")
    add_p(doc, "Параметр адреса __delay=1500 сервер задерживает ответ. Пока запрос идёт, список показывает индикатор, а пагинация ещё пустая: «Всего: 0».")
    add_figure(doc, SHOTS / "03-loading.png", "Рисунок 3 – Состояние загрузки при /books?__delay=1500")
    add_p(doc, "Поиск несуществующей книги уходит на сервер как search=.... Сервер возвращает пустую страницу, и экран показывает «Ничего не найдено».")
    add_figure(doc, SHOTS / "04-empty.png", "Рисунок 4 – Пустой результат поиска на сервере")
    add_p(doc, "Параметр fail=1 клиент превращает в __fail=500. Сервер отвечает учебной пятёркой, Dio считает 5xx сбоем, чтение повторяется до трёх раз с нарастающей паузой, затем на экран выходит ServerException.")
    add_figure(doc, SHOTS / "05-fail500.png", "Рисунок 5 – Ошибка 500, вызванная ?fail=1")
    add_p(doc, "Когда я остановил node-сервер, соединение не установилось. Сообщение специально напоминает проверить CORS, если сервер на самом деле запущен.")
    add_figure(doc, SHOTS / "09-offline.png", "Рисунок 6 – Ошибка, когда учебный сервер выключен")

    heading(doc, "Ошибка 422 на поле формы")
    add_p(doc, "Уникальность ISBN больше не проверяется в LibraryStore. Я открыл форму «Анна Каренина» и подставил ISBN «Войны и мира». Сервер ответил 422 с errors.isbn. ValidationException раскладывается по полям, кнопка «Сохранить» на время запроса отключается.")
    add_figure(doc, SHOTS / "06-isbn422.png", "Рисунок 7 – Ответ 422: ISBN уже используется")

    heading(doc, "Конфликт 409 при выдаче книги")
    add_p(doc, "Для книги «Сияние» (id 11) на сервере copiesAvailable равно 0. Кнопка «Выдать» вызывает POST /books/11/issue. Сервер отвечает 409, виджет ловит ConflictException и показывает диалог. DioException до экрана не доходит.")
    add_figure(doc, SHOTS / "07-issue409.png", "Рисунок 8 – Ответ 409: нет свободных экземпляров")

    heading(doc, "Пагинация отдельным запросом")
    add_p(doc, "Переход на вторую страницу меняет адрес на /books?page=2. Notifier заново вызывает find, и в сеть уходит новый GET с page=2. На экране другие десять книг, внизу «Стр. 2 из 3».")
    add_figure(doc, SHOTS / "08-page2.png", "Рисунок 9 – Вторая страница каталога после нового запроса к API")

    heading(doc, "Вкладка Network")
    add_p(doc, "В DevTools видно, что фильтры и поиск уходят query-параметрами на 127.0.0.1:8080/api. Справочники авторов, жанров и издательств кэшируются отдельными GET и не мешают CancelToken списка: для кэша создаются свои экземпляры репозиториев.")
    add_figure(doc, CODE / "network1.png", "Рисунок 10 – Network: поиск «война» и загрузка справочников", 16)
    add_p(doc, "Смена страницы даёт отдельный запрос только к /books с page=2. Это и есть серверная пагинация: клиент не режет уже загруженный массив, а просит новую порцию.")
    add_figure(doc, CODE / "network2.png", "Рисунок 11 – Network: отдельный GET второй страницы", 16)

    heading(doc, "Инцидент CORS")
    add_p(doc, "Сначала я указал серверу только --origin http://localhost:5555. Клиент же открывался как http://127.0.0.1:5555. Для браузера это разные origin. Запрос падал ещё до разбора JSON, в консоли была ошибка CORS, а приложение писало, что сервер недоступен.")
    add_p(doc, "Исправление: в заголовке Access-Control-Allow-Origin сервер разрешает и localhost, и 127.0.0.1, плюс отвечает на OPTIONS. После этого GET /books стал проходить, а preflight больше не блокировал PUT и DELETE.")
    add_figure(doc, CODE / "cors.png", "Рисунок 12 – Запись инцидента CORS и способ исправления", 16)

    heading(doc, "Основные части кода")
    add_p(doc, "Базовый URL берётся из String.fromEnvironment, поэтому стенд можно сменить без правки исходников.")
    add_figure(doc, CODE / "config.png", "Рисунок 13 – API_BASE_URL через --dart-define", 16)
    add_p(doc, "Коды 401, 403, 404, 409, 422 и сетевые сбои Dio превращаются в sealed-классы ApiException. Виджеты ловят ValidationException и ConflictException, а не DioException.")
    add_figure(doc, CODE / "exceptions.png", "Рисунок 14 – Схема разбора HTTP-ошибок", 16)
    add_p(doc, "Клиент Dio пишет в отладку метод, URI и статус. Ответы 4xx отклоняются интерцептором уже как доменные ошибки. Чтение обёрнуто в withRetry: не больше трёх попыток с паузой 300, 600, 1200 мс.")
    add_figure(doc, CODE / "client.png", "Рисунок 15 – Сборка Dio, журнал и повтор чтения", 16)
    add_p(doc, "При новом поиске предыдущий CancelToken отменяется, чтобы устаревший список не перетёр свежий. Повторные чтения идут через withRetry, создание и изменение — без повтора.")
    add_figure(doc, CODE / "repo.png", "Рисунок 16 – ApiBookRepository.find с CancelToken и разбором страницы", 16)
    add_p(doc, "В main.dart больше нет LibraryStore.load. Provider<Dio> кормит API-репозитории, а CatalogCache держит справочники для выпадающих списков и каскада авторов и жанров.")
    add_figure(doc, CODE / "main.png", "Рисунок 17 – Подключение Dio, API-репозиториев и кэша в main.dart", 16)

    heading(doc, "Таблица эндпоинтов")
    add_table(
        doc,
        ["Метод", "Путь", "Назначение"],
        [
            ["GET", "/api/__health", "Проверка, что сервер запущен"],
            ["GET", "/api/books", "Список: search, genreId, publisherId, year, sort, page, size"],
            ["GET", "/api/books/:id", "Карточка с развёрнутыми publisher, authors, genres"],
            ["POST", "/api/books", "Создание. 422, если ISBN занят"],
            ["PUT", "/api/books/:id", "Изменение. 422 при чужом ISBN"],
            ["DELETE", "/api/books/:id", "Логическое удаление, ?hard=true — физическое"],
            ["POST", "/api/books/:id/restore", "Восстановление"],
            ["POST", "/api/books/bulk-delete", "Пакетное логическое удаление"],
            ["POST", "/api/books/:id/issue", "Выдача экземпляра. 409, если copiesAvailable = 0"],
            ["GET/POST/PUT/DELETE", "/api/authors, /genres, /publishers, /readers", "Тот же набор операций"],
            ["DELETE", "/api/publishers/:id", "409, если на издательство ещё ссылаются книги"],
        ],
    )

    heading(doc, "Схема разбора ошибок")
    add_table(
        doc,
        ["Источник", "Класс", "Что видит пользователь"],
        [
            ["Нет соединения / CORS", "NetworkException", "Не удалось соединиться… проверьте CORS"],
            ["Таймаут", "NetworkException", "Сервер не ответил вовремя"],
            ["401 / 403", "Unauthorized / Forbidden", "Нужен вход / нет прав"],
            ["404", "NotFoundException", "Запись не найдена"],
            ["409", "ConflictException", "Нет экземпляров / нельзя удалить издательство"],
            ["422", "ValidationException", "Ошибка у поля, например ISBN уже используется"],
            ["5xx или __fail", "ServerException", "Ошибка на сервере. Попробуйте позже"],
            ["CancelToken", "RequestCancelledException", "Список не показывает сбой, ждёт новый ответ"],
        ],
    )

    heading(doc, "Проверка работы")
    add_p(doc, "Я проверил flutter analyze и flutter test. К старым тестам in-memory добавлены шесть тестов ApiBookRepository с поддельным адаптером Dio: разбор страницы, 422, недоступный сервер, 409 на выдаче, повтор чтения и отмена устаревшего поиска.")
    add_figure(doc, CODE / "tests.png", "Рисунок 18 – Результат flutter analyze и flutter test", 16)

    heading(doc, "Вывод")
    add_p(doc, "В ходе практической работы я подключил учебную библиотеку к REST API через Dio, вынес адрес сервера в --dart-define, разобрал коды ответа в доменные исключения и оставил экраны без знания Dio.")
    add_p(doc, "Я разобрался, почему localhost и 127.0.0.1 для браузера — разные origin, зачем CancelToken на поиске и почему повтор с паузой нужен только чтению: иначе форма могла бы дважды создать одну и ту же книгу.")

    doc.save(OUT)
    shutil.copy2(OUT, OUT_COPY)
    print(OUT)
    print(OUT_COPY)


if __name__ == "__main__":
    build()
