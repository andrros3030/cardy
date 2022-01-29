TODO: добавить гиперссылки на файл с кодом для каждого упоминания окна, мб запарсить в питоне. Подключить архив из Confluence и дописать документацию из него
# _Cardy: приложение для хранения Ваших бонусных карт_
____

README подготовлен в рамках перевода проекта в Open Source (февраль 2022) и содержит информацию о предназначении приложения, о концепциях, которых мы придерживались во время разработки приложения, и о функциональностях, которые были заложены/реализованы, а также описывает существующую кодовую базу.

## О приложении
### Описание

Наше приложение должно позволить пользователям избавиться от толстых кардхолдеров и позволить хранить все данные в приложении. Приложение позволяет фотографировать карты со штрих-кодами и сохранять nfc-метки для карт и пропусков, для последующей эмуляции и их использования с помощью телефона. Карты можно будет удобно подписать, распределить по папкам и установить иконки. Картами можно поделиться, а для семейного использования предусмотрена возможность входа в один аккаунт с нескольких устройств.

Дополнительный функционал приложения включает в себя такие возможности:
- поделиться картой
- найти карту по её названию
- собрать все однотипные карты в папку
    - папку можно назвать или добавить заставку
    - внутри папок есть свой поиск
    - для каждой папки ведется подсчет количества карт
- поменять очередность папок или карт с помощью перетягиваний
- войти в аккаунт на другом устройстве
- сохранения срока действия карты с последующим уведомлением пользователя об истекающем сроке действия
- доступ к просмотру карт с помощью привязанного Telegram-аккаунта
### Концепции UX/UI

- Пользователь должен легко и интуитивно получать доступ к необходимым ему функциям
- Все кнопки должны либо трактоваться единственным способом, либо дополняться диалоговыми окнами
- Никакие всплывающие окна не должны мешать пользователю во время работы с приложением (например "оцените приложение" делаем push-уведомлением или небольшой подсказкой)
- Приложение должно быть доступно оффлайн всегда, за исключением регистрации и авторизации.


## О коде

Технологический стэк:
```
Язык мобильной разработки - Dart.
Фреймворк - Flutter (>=2.7.0 <3.0.0).
Библиотеки и их применение:
image_cropper - для обрезки изображений, когда пользователь загружает фотографии карт
photo_view - для просмотра изображений карты
image_picker - для получения изображений с камеры или из галереи
nfc_in_flutter - для работы с nfc, но не используется
fluttertoast - всплывающий пузырик, TODO: переписать на натив
fluttericon - библиотека с набором различных иконок
url_launcher - для перехода по ссылкам из приложения
sqflite - для работы с базой данных SQLite на мобильном устройстве
path_provider - для получения доступа для сохранения файлов
crypto - для получения хэша
hive - для сохранения данных для входа, для проверки факта первого запуска и других флагов
hive_flutter - зависимость hive
uuid - для генерации уникальных ID при создании новых записей в бд
```
Данный язык и фреймворк были выбраны поскольку позволяют писать один и тот же код для двух платформ (IOS, Android) с последующей компиляцией в нативный код.

При разработке использовался процедурный подход, базовый принцип - исключить повторяемость кода.
### О функциональностях
__:white_check_mark: - Это уже сделано,__ 

__:white_square_button: - Это ещё не сделано, но архитектурно подготовлено для реализации,__

__:no_entry: - Было принято решение отказаться и не вести разработку функциональности на этапе MVP__

- :white_check_mark: Мульти-аккаунт с сохранением данных для входа
- :white_check_mark: Создание карты с изображениями (до двух). Реализован экран добавления карты, экран просмотра/редактирования изображения
- :white_check_mark: Поле для заметок при просмотре карты
- :white_check_mark: Создание папки с изображением/названием
- :white_check_mark: Рабочий счётчик карт (как внутри папок, так и неотсортированных)
- :white_check_mark: Перемещение карт и папок для изменения очередности
- :white_check_mark: Перетягивание карты в папку и удаление из папки смахиванием
- :white_check_mark: Пост-проверка email адреса в окне "Пользователь"






















1) Создание аккаунта, авторизация, привязка телеграмма (TODO: авторизация пользователя при входе в приложение? Контакты для связи с техподдержкой? Доверительный код/адрес эл почты или телефон?)
2) Добавление категории карт, редактирование доступа к категории (TODO: объяснить пользователю что не стоит хранить банковские карты в нашем приложении)
3) Добавление карты, редактирование данных / названия / ключевых слов / доступа к карте, удаление карты, перемещение в другую категорию
4) Поиск по всем картам, по отдельной категории
5) Просмотр карты (просмотр штрихкода или включение nfc метки)
6) Синхронизация базы данных по через интернет (при добавлении новой карты, при открытии приложения)
7) Доступ к просмотру и добавлению карт/категорий через телеграмм, веб-сайт (TODO: сделать тайм-аут на сайте или блокировку окна, чтобы если вдруг юзер отошел данные залочились)
8) Полный или частичный доступ к данным через приложение на другом устройстве (при запуске приложения на исходном устройстве будет всплывать вопрос - удалить карты на устройстве или вернуть в базу?)
9) Поделиться данными карты (дать доступ на просмотр, отправить копию) с помощью ссылки на сайт (если есть приложение откроется в приложении)
10) Дать доступ к карте или категории (пользователь выбирает какой уровень доступа дать к объекту, НЕ к копии) с помощью модалки внутри приложения по адресу почты второго юзера
11) По возможности хранить данные о сроке действия карты и напоминать об этих датах пользователю

TODO: почитать https://github.com/GnuriaN/format-README#%D0%A0%D0%B0%D0%B7%D0%B4%D0%B5%D0%BB%D0%B8%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F-%D1%87%D0%B5%D1%80%D1%82%D0%B0
