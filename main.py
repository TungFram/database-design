# This is a sample Python script.
import csv
from random import choice

import random
import datetime

filename = 'price_units.csv'
with open(filename, 'w', newline='') as file:
    writer = csv.writer(file)
    field = [
        "price_unit_id",
        "one_gigabyte",
        "koef_gigabyte",
        "one_minutes",
        "koef_minutes",
        "one_sms",
        "koef_sms",
        "created_date"
    ]

    writer.writerow(field)
    for id in range(1, 999):
        # Генерируем случайную дату в диапазоне.
        start_date = datetime.date(2023, 1, 1)
        end_date = datetime.date(2029, 12, 31)
        random_date = start_date + datetime.timedelta(days=random.randint(0, (end_date - start_date).days))
        # преобразуем дату в строку в формате "день-месяц-год"
        # для строковых значений обязательно f"'{}'"
        date = f"'{random_date.strftime('%Y-%m-%d')}'"

        writer.writerow([
            id,  # Id.
            choice([0.1, 0.2, 0.5, 1.0, 2.0, 5.0]),  # Gigabytes.
            choice([0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.2, 1.5, 2.0]),
            choice([0.1, 0.2, 0.5, 1.0, 2.0, 5.0]),   # Minutes.
            choice([0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.2, 1.5, 2.0]),
            choice([0.1, 0.2, 0.5, 1.0, 2.0, 5.0]),   # Sms.
            choice([0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.2, 1.5, 2.0]),
            date,  # created_date.
        ])

# import os
#
# # Move a file by renaming its path
# os.rename('C:/Users/vovan/PycharmProjects/CsvGenerator/' + filename, 'C:/DBD/'+filename)
