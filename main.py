# This is a sample Python script.
import csv
from random import choice

import random
import string
import datetime


def randomword(length):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(length))


filename = 'products.csv'
with open(filename, 'w', newline='') as file:
    writer = csv.writer(file)
    field = [
        "product_id",
        "catalog_node_id",
        "old_price",
        "current_price",
        "is_delivery_enabled",
        "is_pickup_enabled",
        "title",
        "description",
    ]

    writer.writerow(field)
    for id in range(1, 1000):


        writer.writerow([
            id,
            random.randint(0, 999),
            choice([350, 400, 450, 500, 550, 600, 650, 700, 800, 1000, 1200, 1500, 2000, 5000, 10000]),
            choice([350, 400, 450, 500, 550, 600, 650, 700, 800, 1000, 1200, 1500, 2000, 5000, 10000]),
            choice([True, False]),
            choice([True, False]),
            randomword(64),
            randomword(1024),
        ])

# import os
#
# # Move a file by renaming its path
# os.rename('C:/Users/vovan/PycharmProjects/CsvGenerator/' + filename, 'C:/DBD/'+filename)
