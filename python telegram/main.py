import telebot
from telebot import types
import python_local_db
import python_global_db

bot = telebot.TeleBot('1701501638:AAEzdpukqaAbmfJ6oOikEDe41HfZrRH5MR8')


def try_entering_with_code(id, code):
    return True




def massege_when_stable_work(id):
    cards_table = []
    list_id = python_global_db.get_users_card_list(python_global_db.get_user_id(id))
    for i in list_id:
        cards_table.append(python_global_db.get_card(i[0]))
    inlines = types.InlineKeyboardMarkup()
    for i in cards_table:
        inlines.add(types.InlineKeyboardButton(text=i[1], callback_data=i[0]))
    if (cards_table != []):
        bot.send_message(id, 'Выберете карту', reply_markup=inlines)
        python_local_db.set_mode(id, "exact_card_selection")
    else:
        print("HEEEEEEEEEEEREEEEEEEEEEEEEEEEEEEE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")


@bot.callback_query_handler(lambda first: True)
def fu(parse):
    if (python_local_db.get_mode(parse.message.chat.id) == "exact_card_selection"):
        try:
            about_card = python_global_db.get_card(parse.data)
            print(about_card)
        except:
            print("corgi")
        #if parse.data == "ввести код":
        #    bot.send_message(parse.message.chat.id, text="Введите свой вопрос")



@bot.message_handler(commands=['start'])
def start(message):
    python_local_db.new_user(message.from_user.id)
    re_keyboard = types.ReplyKeyboardMarkup(resize_keyboard=True)
    re_keyboard.add(types.KeyboardButton(text="about"), types.KeyboardButton(text="ввести код"))
    bot.send_message(message.from_user.id, "Cardy", reply_markup=re_keyboard)


@bot.message_handler(content_types=['text'])
def get_text(message):
    text = message.text
    id = message.from_user.id
    mode = python_local_db.get_mode(id)
    re_keyboard = types.ReplyKeyboardMarkup(resize_keyboard=True)
    if (mode == "after_start"):
        if (text == "about"):
            re_keyboard.add(types.KeyboardButton(text='ввести код'))
            bot.send_message(id, "это Cardy \n :)", reply_markup=re_keyboard)
        elif (text == "ввести код"):
            python_local_db.set_mode(id, "after_entering_code")
            re_keyboard.add(types.KeyboardButton(text='отмена'))
            bot.send_message(id, "Введите код",reply_markup=re_keyboard)
        else:
            bot.send_message(id, "Выберете один из вариантов")
    if (mode == "after_entering_code"):
        if (text == "отмена"):
            python_local_db.set_mode(id, "after_start")
            re_keyboard.add(types.KeyboardButton(text='about'), types.KeyboardButton(text='ввести код'))
            bot.send_message(message.from_user.id, 'Cardy', reply_markup=re_keyboard)
        else:
            is_enntered = try_entering_with_code(id, text)
            if (is_enntered):
                python_local_db.set_mode(id, "stable_work")
                bot.send_message(id, "Код успешно введён!")
                massege_when_stable_work(id)
            else:
                python_local_db.set_mode(id, "after_unsucsessfull_entered")
                re_keyboard.add(types.KeyboardButton(text='ввести ещё раз'), types.KeyboardButton(text='отмена'))
                bot.send_message(id, "Код неверный", reply_markup=re_keyboard)
    if (mode == "after_unsucsessfull_entered"):
        if (text == "отмена"):
            python_local_db.set_mode(id, "after_start")
            re_keyboard.add(types.KeyboardButton(text='about'), types.KeyboardButton(text='ввести код'))
            bot.send_message(id, 'Cardy', reply_markup=re_keyboard)
        elif (text == "ввести ещё раз"):
            python_local_db.set_mode(id, "after_entering_code")
            re_keyboard.add(types.KeyboardButton(text='отмена'))
            bot.send_message(id, 'Введите код', reply_markup=re_keyboard)
    if (mode == "stable work"):
        massege_when_stable_work(id)


bot.polling(none_stop=True)