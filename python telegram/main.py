import telebot
from telebot import types
import python_local_db


bot = telebot.TeleBot('1701501638:AAEzdpukqaAbmfJ6oOikEDe41HfZrRH5MR8')

# inline reply keyboard


@bot.message_handler(commands=['start'])
def start(message):
    python_local_db.new_user(message.from_user.id)
    #in_keyboard = types.InlineKeyboardMarkup()
    #in_keyboard.add(types.InlineKeyboardButton(text="about",callback_data="ввести код"), types.InlineKeyboardButton(text="ввести код", callback_data="ввести код"))

    re_keyboard = types.ReplyKeyboardMarkup(resize_keyboard=True)
    re_keyboard.add(types.KeyboardButton(text="about"), types.KeyboardButton(text="ввести код"))

    bot.send_message(message.from_user.id, "Cardy", reply_markup=re_keyboard)



@bot.message_handler(content_types=['text'])
async def get_text(message):
    text = message.text
    id = message.from_user.id
    mode = await python_local_db.get_mode(id)
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
            is_enntered = python_local_db.try_entering_with_code(id, text)
            if (is_enntered):
                python_local_db.set_mode(id, "stable_work")
                bot.send_message(id, "Код успешно введён!")
                bot.send_message()
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
    #if (mode == "stable work"):




bot.polling(none_stop=True)








