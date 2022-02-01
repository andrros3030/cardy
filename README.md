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

- :white_check_mark: Мульти-аккаунт с <a href="https://cardy.atlassian.net/wiki/spaces/CRDY/pages/1868039">сохранением данных</a> для входа
- :white_check_mark: Создание карты с изображениями (до двух). Реализован <a href="https://cardy.atlassian.net/wiki/spaces/CRDY/pages/33332">экран добавления карты</a>, <a href="https://cardy.atlassian.net/wiki/spaces/CRDY/pages/1867847">экран просмотра/редактирования изображения</a>
- :white_check_mark: Поле для заметок при просмотре карты
- :white_check_mark: <a href="https://cardy.atlassian.net/wiki/spaces/CRDY/pages/1835073">Создание папки</a> с изображением/названием
- :white_check_mark: Рабочий счётчик карт (как внутри папок, так и неотсортированных)
- :white_check_mark: Перемещение карт и папок для изменения очередности
- :white_check_mark: Перетягивание карты в папку и удаление из папки смахиванием
- :white_check_mark: Пост-проверка email адреса в окне <a href="https://cardy.atlassian.net/wiki/spaces/CRDY/pages/1867836">"Аккаунт"</a>
- :white_square_button: Привязка телеграмма - реализована кнопка с генерацией ссылки
- :no_entry: Телеграмм бот и веб-сайт для просмотра карт - не в MVP
- :no_entry: Синхронизация одного и того же аккаунта с двух устройств - слишком большой пласт работ по интеграции контроля действий пользователя и разделению версий клиентских баз данных, вынесено из MVP
- :white_square_button: Onboarding - реализован флаг первого запуска
- :white_check_mark: Поиск по всем картам, по отдельной папке
- :white_square_button: Синхронизация базы данных по через интернет (при добавлении новой карты, при открытии приложения) - TODO: проверить существующую архитектуру
- :white_square_button: Поделиться данными карты (дать доступ на просмотр, отправить копию) с помощью ссылки на сайт (если есть приложение откроется в приложении) - TODO: проверить существующую архитектуру
- :no_entry: Хранить данные о сроке действия карты и напоминать об этих датах пользователю - в базе данных не существует соответствующее поле на стадии MVP






> <a href="https://cardy.atlassian.net/wiki/spaces/CRDY/overview">Более подробная документация в Confluence</a> опубликована для анонимного доступа, там же опубликовано <a href="https://cardy.atlassian.net/wiki/spaces/CRDY/pages/33239">пользовательское поведение</a> с последовательным описанием действий пользователя при взаимодействии с приложением.

## Скриншоты
### Главный экран
<div class="row">
<img alt="Главный экран 1" src="https://raw.githubusercontent.com/andrros3030/cardy/safe-commit/screenshots/Screenshot_1643742052.png" height="400"/>
<img alt="Главный экран 2" src="https://raw.githubusercontent.com/andrros3030/cardy/safe-commit/screenshots/Screenshot_1643742391.png" height="400"/>
</div>

### Добавление карты
<div class="row">
<img alt="До загрузки изображений" src="https://raw.githubusercontent.com/andrros3030/cardy/safe-commit/screenshots/Screenshot_1643742489.png" height="400"/>
<img alt="Загружены оба изображения" src="https://raw.githubusercontent.com/andrros3030/cardy/safe-commit/screenshots/Screenshot_1643742561.png" height="400"/>
<img alt="Добавить название" src="https://raw.githubusercontent.com/andrros3030/cardy/safe-commit/screenshots/Screenshot_1643742582.png" height="400"/>
<img alt="Модалка на две секунды" src="https://raw.githubusercontent.com/andrros3030/cardy/safe-commit/screenshots/Screenshot_1643742586.png" height="400"/>
</div>

### Просмотр карты
<div class="row">
<img alt="Просмотр оборотной стороны" src="https://raw.githubusercontent.com/andrros3030/cardy/safe-commit/screenshots/Screenshot_1643743192.png" height="400"/>
<img alt="Поле заметок" src="https://raw.githubusercontent.com/andrros3030/cardy/safe-commit/screenshots/Screenshot_1643743181.png" height="400"/>
</div>

### Создание папки
<div class="row">
<img alt="Выбор заставки" src="https://raw.githubusercontent.com/andrros3030/cardy/safe-commit/screenshots/Screenshot_1643743462.png" height="400"/>
<img alt="Название" src="https://raw.githubusercontent.com/andrros3030/cardy/safe-commit/screenshots/Screenshot_1643743477.png" height="400"/>
<img alt="Модалка на две секунды" src="https://raw.githubusercontent.com/andrros3030/cardy/safe-commit/screenshots/Screenshot_1643743480.png" height="400"/>
</div>

### Действия с картами
<div class="row">
<img alt="Поиск" src="https://raw.githubusercontent.com/andrros3030/cardy/safe-commit/screenshots/Screenshot_1643742066.png" height="400"/>
<img alt="Перенос в категорию" src="https://raw.githubusercontent.com/andrros3030/cardy/safe-commit/screenshots/screenshot_drag.png" height="400"/>
<img alt="Карты в папке" src="https://raw.githubusercontent.com/andrros3030/cardy/safe-commit/screenshots/Screenshot_1643742412.png" height="400"/>
</div>
