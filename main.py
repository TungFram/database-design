# This is a sample Python script.
import csv
from random import choice

import random
import datetime

with open('price_units.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    field = ["id", "One_gb", "minutes", "sms", "endat"]

    writer.writerow(field)
    for i in range(19, 999):
        # Генерируем случайную дату в диапазоне.
        start_date = datetime.date(2023, 1, 1)
        end_date = datetime.date(2029, 12, 31)
        random_date = start_date + datetime.timedelta(days=random.randint(0, (end_date - start_date).days))
        # преобразуем дату в строку в формате "день-месяц-год"
        # для строковых значений обязательно f"'{}'"
        date = f"'{random_date.strftime('%d-%m-%Y')}'"

        writer.writerow([
            i,  # Id.
            choice([10, 20, 30, 50, 100, 999]),  # Gigabytes.
            choice([10, 20, 30, 40, 50, 100, 200, 300, 400, 500, 600, 700, 1000, 2000, 9999]),  # Minutes.
            choice([10, 20, 30, 40, 50, 100, 200, 300, 400, 500, 600, 700, 1000, 2000, 9999]),  # Sms.
            date,  # EndAt.
        ])

