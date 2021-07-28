import sqlite3


def new_user(id):
    with sqlite3.connect('telegram_local_status.db') as db:
        kur = db.cursor()
        kur.execute(""" CREATE TABLE IF NOT EXISTS users (
        id BIGINT PRIMARY KEY,
        mode TEXT
        )""")
        kur.execute(""" INSERT INTO users VALUES (?, 'start') ON CONFLICT(id) DO UPDATE SET mode = 'after_start' """,(id,))
    pass


def get_mode(id):
    with sqlite3.connect('telegram_local_status.db') as db:
        kur = db.cursor()
        list_mode = kur.execute(""" SELECT mode from users WHERE id = ?  """, (id,)).fetchone()
        return list_mode[0]


def set_mode(id, new_mode):
    with sqlite3.connect('telegram_local_status.db') as db:
        kur = db.cursor()
        kur.execute(""" UPDATE users SET mode = ? WHERE id = ? """, (new_mode, id))


