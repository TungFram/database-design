# This is a sample Python script.
import csv
from random import choice

import random
import string
import datetime


def randomword(length):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(length))

def randomdate():
    # Генерируем случайную дату в диапазоне.
    start_date = datetime.date(2023, 1, 1)
    end_date = datetime.date(2029, 12, 31)
    random_date = start_date + datetime.timedelta(days=random.randint(0, (end_date - start_date).days))
    # преобразуем дату в строку в формате "день-месяц-год"
    # для строковых значений обязательно f"'{}'"
    date = f"'{random_date.strftime('%Y-%m-%d')}'"
    return date

filename = 'product_price.csv'
with open(filename, 'w', newline='') as file:
    writer = csv.writer(file)
    field = [
        "price_id",
        "prodict_id",
        "old_price",
        "current_price",
        "date",
        "version",
    ]

    writer.writerow(field)
    for id in range(1, 1000):
        writer.writerow([
            id,
            random.randint(1, 999),
            choice([350, 400, 450, 500, 550, 600, 650, 700, 800, 1000, 1200, 1500, 2000, 5000, 10000]),
            choice([350, 400, 450, 500, 550, 600, 650, 700, 800, 1000, 1200, 1500, 2000, 5000, 10000]),
            randomdate(),
            1,
        ])

# import os
#
# # Move a file by renaming its path
# os.rename('C:/Users/vovan/PycharmProjects/CsvGenerator/' + filename, 'C:/DBD/'+filename)
