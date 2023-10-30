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

filename = 'tags.csv'
with open(filename, 'w', newline='') as file:
    writer = csv.writer(file)
    field = [
        "tag_id",
        "title",
        "color",
    ]

    writer.writerow(field)
    for id in range(1, 1000):
        writer.writerow([
            id,
            randomword(32),
            choice(["Black", "Blue", "White", "Pink", "Gray", "Yellow", "Orange"]),
        ])

# import os
#
# # Move a file by renaming its path
# os.rename('C:/Users/vovan/PycharmProjects/CsvGenerator/' + filename, 'C:/DBD/'+filename)
