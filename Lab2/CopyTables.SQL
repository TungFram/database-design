COPY rates
FROM 'C:\Users\vovan\PycharmProjects\CsvGenerator\rates.csv'
WITH (
    DELIMITER ',',
    FORMAT CSV,
    HEADER true,
    NULL 'null'
    );

-- Там нет разрешений на чтение изначально, я вручную копировал файлы на С: