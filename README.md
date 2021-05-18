# card_app_bsk

Приложение для хранения данных ваших бонусных карт

## Getting Started

Кейсы приложения (основные проблемы пользователя, которое оно решает):
1) У пользователя должна быть возможность хранить все бонусные карты (штрихкоды и/или nfc метки) в одном месте с удобным и быстрым доступом, для того чтобы избавиться от толстых кардхолдеров в реальности.
2) Доступ к этим данным любым удобным способом: мобильное приложение (вход в аккаунт) / телеграмм-бот или сайт (авторизация с помощью смс-кода?)
3) Пользователь должен иметь возможность привязать один аккаунт к нескольким устройствам с синхронизацией базы (режим приоритета устройства, синхронизация при запуске приложения) или пользоваться из тг и сайта никак не привязывая (просто сессия, телеграмм бот и сайт не будут давать доступ редактировать или удалять карты - только просматривать)
4) Пользователь хочет поделиться определенной картой посредством ссылки на приложение, отправив копию
5) Пользователь хочет дать доступ к карте или категории другому пользователю (с выбором привилегий), например члену семьи


Функциональности:
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

