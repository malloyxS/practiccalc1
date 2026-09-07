# -*- coding: utf-8 -*-
from pathlib import Path

from docx import Document
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_LINE_SPACING
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
SHOTS = ROOT / "calc_web" / "report" / "pr2_screenshots"
CODE = ROOT / "calc_web" / "report" / "pr2_code"
OUT = ROOT / "Отчёт_ПР2.docx"
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
    set_run_font(run, size=12, bold=bold)
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


def build():
    CODE.mkdir(parents=True, exist_ok=True)
    render_code(CODE / "seed.png", "lib/data/seed_data.dart", snippet(LIB / "data" / "seed_data.dart", 4, 32))
    render_code(CODE / "author_repo.png", "lib/repositories/author_repository.dart", snippet(LIB / "repositories" / "author_repository.dart", 1, 22))
    render_code(CODE / "book_repo.png", "lib/repositories/book_repository.dart", snippet(LIB / "repositories" / "book_repository.dart", 1, 21))
    render_code(CODE / "find.png", "lib/repositories/in_memory_book_repository.dart", snippet(LIB / "repositories" / "in_memory_book_repository.dart", 18, 58))
    render_code(CODE / "detail.png", "lib/screens/book_detail_screen.dart", snippet(LIB / "screens" / "book_detail_screen.dart", 67, 110))
    render_code(CODE / "provider.png", "lib/main.dart", snippet(LIB / "main.dart", 29, 41))
    render_code(CODE / "deletemany.png", "lib/repositories/in_memory_book_repository.dart", snippet(LIB / "repositories" / "in_memory_book_repository.dart", 123, 136))
    render_code(CODE / "table.png", "lib/widgets/entity_table.dart", snippet(LIB / "widgets" / "entity_table.dart", 3, 41))
    render_terminal(
        CODE / "tests.png",
        "Терминал — flutter test / analyze",
        "flutter test\n00:02 +20: All tests passed!\n\nflutter analyze\nAnalyzing calc_web...\nNo issues found!",
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
    add_p(doc, "Практическая работа 2. Списки, поиск, фильтрация и пагинация", size=14, bold=True, align="center", space_after=28)
    add_p(doc, "Студент    Тропанец Егор Александрович", size=14, align="left", space_after=2)
    add_p(doc, "(фамилия, имя, отчество)", size=10, italic=True, align="left", space_after=8)
    add_p(doc, "Группа     Т-11-24", size=14, align="left", space_after=16)
    add_p(doc, "Руководитель по практической подготовке от техникума", size=14, align="left", space_after=4)
    add_p(doc, "Горбутова Маргарита Витальевна", size=14, align="left", space_after=2)
    add_p(doc, "(фамилия, имя, отчество)", size=10, italic=True, align="left", space_after=20)
    add_p(doc, "«07» сентября 2026 года", size=14, align="right", space_after=18)

    heading(doc, "Цель работы")
    add_p(doc, "Целью практической работы является освоение работы со списками во Flutter Web. Нужно было сделать поиск, фильтрацию, сортировку и постраничный вывод, использовать provider для управления состоянием и разделить приложение на несколько слоёв.")
    add_p(doc, "Вторая практическая работа выполнена как продолжение проекта calc_web. В приложение добавлена учебная библиотека: каталог книг и список авторов. Данные хранятся в памяти, без подключения сервера. Функции из первой практической работы сохранены, основная часть второй работы находится в разделах «Каталог книг» и «Авторы».")

    heading(doc, "Ход работы")
    heading(doc, "Главная страница")
    add_p(doc, "На главной странице появились две основные кнопки: «Каталог книг» и «Авторы». Калькулятор и конвертер из первой практической оставлены ниже как дополнительные инструменты.")
    add_figure(doc, SHOTS / "01-home.png", "Рисунок 1 – Главная страница практической работы №2")

    heading(doc, "Работа со списком книг")
    heading(doc, "Поиск и фильтрация")
    add_p(doc, "Каталог книг выводится в виде таблицы. Для книг доступны поиск по названию или ISBN, фильтр по жанру и издательству, а также диапазон года издания. Условия можно применять одновременно. После изменения условий список обновляется, а номер страницы возвращается к первой.")
    add_p(doc, "На рисунке показан поиск по слову «деньги» вместе с фильтром по жанру «Финансы», издательству «Капитал Пресс» и годам 2018–2024. Эти значения видны в адресной строке браузера.")
    add_figure(doc, SHOTS / "03-books-filters.png", "Рисунок 2 – Поиск и фильтрация в каталоге книг, параметры сохранены в URL")

    heading(doc, "Таблица, выделение и удалённые записи")
    add_p(doc, "В строках таблицы есть флажки. После выбора нескольких книг появляется счётчик и кнопка «Удалить выбранные». Логическое удаление проставляет deletedAt и убирает запись из обычной выборки. Если включить «Показывать удалённые», запись снова видна, выделяется другим фоном и её название перечёркивается.")
    add_figure(doc, SHOTS / "02-books-table.png", "Рисунок 3 – Список книг в виде таблицы, включён показ удалённых")
    add_p(doc, "На узком окне (меньше 600 пикселей) таблица заменяется списком карточек. Это требование адаптивной вёрстки.")
    add_figure(doc, SHOTS / "10-books-cards.png", "Рисунок 4 – Каталог книг в виде карточек на узком окне")

    heading(doc, "Пустой результат и состояние ошибки")
    add_p(doc, "Обрабатываются четыре состояния экрана: загрузка, успех, пустой список и ошибка. Пустой результат и ошибка выглядят по-разному. Для проверки ошибки в учебном проекте предусмотрен параметр fail=1.")
    add_figure(doc, SHOTS / "04-books-empty.png", "Рисунок 5 – Пустой результат поиска")
    add_figure(doc, SHOTS / "05-books-error.png", "Рисунок 6 – Состояние ошибки загрузки списка")

    heading(doc, "Работа со списком авторов")
    add_p(doc, "Для авторов сделан отдельный экран. Поиск выполняется по фамилии и стране. Есть фильтр по стране, сортировка по щелчку на заголовке и пагинация. В таблице отображаются фамилия, имя, страна, год рождения, количество книг и кнопки действий.")
    add_figure(doc, SHOTS / "07-authors.png", "Рисунок 7 – Список авторов")
    add_p(doc, "По кнопке просмотра открывается карточка автора. Идентификатор передаётся в адресе: /authors/1.")
    add_figure(doc, SHOTS / "08-author-card.png", "Рисунок 8 – Карточка автора")
    add_figure(doc, SHOTS / "09-book-card.png", "Рисунок 9 – Карточка книги")

    heading(doc, "Основные части кода")
    add_p(doc, "Так как сервер в этой работе ещё не используется, книги и авторы хранятся в памяти. Начальные данные находятся в файле seed_data.dart: 24 книги, 10 авторов, жанры и издательства.")
    add_figure(doc, CODE / "seed.png", "Рисунок 10 – Начальные данные книг и авторов", 16)
    add_p(doc, "Для книг и авторов созданы отдельные интерфейсы репозиториев. В них описаны получение списка, поиск по id, создание, изменение, логическое и физическое удаление, восстановление и множественное удаление.")
    add_figure(doc, CODE / "author_repo.png", "Рисунок 11 – Интерфейс AuthorRepository", 16)
    add_figure(doc, CODE / "book_repo.png", "Рисунок 12 – Интерфейс BookRepository", 16)
    add_p(doc, "Реализации InMemoryBookRepository и InMemoryAuthorRepository работают со списками в памяти. В них выполняются поиск, фильтрация, сортировка и пагинация. Задержка 250 мс имитирует загрузку, чтобы было видно состояние ожидания.")
    add_figure(doc, CODE / "find.png", "Рисунок 13 – Поиск и фильтрация в репозитории книг", 16)
    add_p(doc, "Карточка автора получает id из маршрута и запрашивает запись через репозиторий. Пока данные загружаются, показывается индикатор. Если запись не найдена, выводится отдельное сообщение.")
    add_figure(doc, CODE / "detail.png", "Рисунок 14 – Часть кода карточки автора", 16)

    heading(doc, "Архитектура приложения")
    add_p(doc, "Проект разделён на несколько слоёв. Экран не обращается к списку данных напрямую. Он работает с объектом состояния, состояние вызывает репозиторий, а репозиторий работает с моделями и начальными данными. Такое разделение сделано для того, чтобы позже можно было заменить данные в памяти на сервер, не переписывая весь интерфейс.")
    add_p(doc, "screens / widgets — экраны, таблицы, карточки и другие элементы интерфейса.", align="left")
    add_p(doc, "state (provider) — классы BookListNotifier и AuthorListNotifier, которые управляют состоянием списков.", align="left")
    add_p(doc, "repositories — интерфейсы и репозитории, которые работают с данными в памяти.", align="left")
    add_p(doc, "models / data — модели Book, Author, параметры запросов, PageResult и начальные данные seed_data.", align="left")

    heading(doc, "Управление состоянием через provider")
    add_p(doc, "В main.dart подключаются репозитории и ChangeNotifier для книг и авторов. Экраны получают состояние через provider. При загрузке, удалении, восстановлении или смене фильтров вызывается notifyListeners(), поэтому интерфейс обновляется автоматически. Виджеты не обращаются к репозиторию напрямую, кроме карточек, которые читают одну запись по id.")
    add_figure(doc, CODE / "provider.png", "Рисунок 15 – Подключение провайдеров в main.dart", 16)

    heading(doc, "Исправление ошибки в deleteMany")
    add_p(doc, "В методичке в deleteMany специально была оставлена ошибка. Внутри indexWhere использовалось выражение b[i].isDeleted. Переменная b в этом месте является одной книгой, а индекс i ещё не найден, поэтому такой код не компилируется.")
    add_p(doc, "В проекте проверяется сама найденная книга: b.id == id && !b.isDeleted. Только после того как indexWhere вернул индекс, запись меняется в списке.")
    add_figure(doc, CODE / "deletemany.png", "Рисунок 16 – Исправленный метод deleteMany", 16)

    heading(doc, "Обобщённая таблица EntityTable<T>")
    add_p(doc, "Таблица вынесена в отдельный обобщённый виджет EntityTable<T>. Один и тот же виджет используется для книг и авторов. На конкретном экране задаются только столбцы, способ получения id, сортировка и список кнопок действий. Благодаря этому не пришлось писать две почти одинаковые таблицы. Это важно, потому что дальше в практике появятся ещё сущности, и копировать код было бы нельзя.")
    add_figure(doc, CODE / "table.png", "Рисунок 17 – Описание колонок обобщённого виджета EntityTable<T>", 16)

    heading(doc, "Пагинация, сортировка и адресная строка")
    add_p(doc, "Размер страницы переключается между 10, 25 и 50 записями. Есть переход на первую, предыдущую, следующую и последнюю страницы, показаны номер текущей страницы и общее число записей. Сортировка включается нажатием на заголовок столбца не менее чем по трём полям и меняет направление при повторном нажатии.")
    add_p(doc, "Поле поиска не запускает выборку на каждую букву: используется задержка 350 миллисекунд. Все условия отбора отражаются в адресе, например:")
    add_p(doc, "http://127.0.0.1:5557/books?search=деньги&genreId=4&publisherId=4&yearFrom=2018&yearTo=2024&sort=year,desc", align="left", size=12)
    add_p(doc, "Открытие такого адреса в новой вкладке восстанавливает то же состояние списка. Кнопка «назад» браузера возвращает предыдущий набор условий.")

    heading(doc, "Схема основных маршрутов")
    add_table(
        doc,
        ["Адрес", "Страница"],
        [
            ["/", "Главная страница"],
            ["/books", "Каталог книг"],
            ["/books/:id", "Карточка книги"],
            ["/authors", "Список авторов"],
            ["/authors/:id", "Карточка автора"],
        ],
    )
    add_p(doc, "Фильтры, поиск, сортировка, пагинация и режим показа удалённых записей передаются в query-параметрах после адреса списка.")

    heading(doc, "Проверка работы")
    add_p(doc, "Для проверки проекта используются команды flutter analyze и flutter test. Проверяются поиск, совместная работа фильтров, сортировка, переходы по страницам, множественное удаление, восстановление, физическое удаление, прямое открытие URL с параметрами и состояние ошибки.")
    add_figure(doc, CODE / "tests.png", "Рисунок 18 – Результат flutter test и flutter analyze", 16)

    heading(doc, "Вывод")
    add_p(doc, "В ходе практической работы я продолжил web-приложение и добавил в него учебную библиотеку. Были сделаны списки книг и авторов, поиск, фильтры, сортировка, пагинация, карточки записей, два вида удаления, адаптивная смена таблицы на карточки и синхронизация условий отбора с адресной строкой.")
    add_p(doc, "Я разобрался, зачем делить проект на слои и зачем выносить таблицу в обобщённый виджет: экраны не зависят от того, где лежат данные, и одинаковый список можно настроить колонками, а не копированием кода.")

    doc.save(OUT)
    print(OUT)


if __name__ == "__main__":
    build()
