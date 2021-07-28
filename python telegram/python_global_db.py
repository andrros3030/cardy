import sqlite3


def get_user_id(tele_id):
    with sqlite3.connect('..\\test_main_data_base\database.db') as db:
        kur = db.cursor()
        list_mode = kur.execute(""" SELECT PK_ID from T_ACCOUNT WHERE v_telegram = ?  """, (tele_id,)).fetchone()
        return list_mode[0]

def get_users_card_list(user_id): #app id
    with sqlite3.connect('..\\test_main_data_base\database.db') as db:
        kur = db.cursor()
        list_mode = kur.execute(""" SELECT FK_CARD from T_ACCESS WHERE PK_ID = ?  """, (user_id,)).fetchall()
        return list_mode

def get_card(card_id):
    with sqlite3.connect('..\\test_main_data_base\database.db') as db:
        kur = db.cursor()
        list_mode = kur.execute(""" SELECT * from T_CARD WHERE PK_ID = ?  """, (card_id,)).fetchone()
        return list_mode
