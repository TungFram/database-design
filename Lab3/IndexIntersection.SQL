SELECT
    a.indrelid::regclass,
    a.indexrelid::regclass,
    b.indrelid::regclass,
    b.indexrelid::regclass
FROM (
    SELECT *, array_to_string(indkey, ' ') AS cols
    FROM pg_index
    ) AS a
JOIN (
    SELECT *, array_to_string(indkey, ' ') AS cols
    FROM pg_index
    ) AS b
ON (
    a.indrelid = b.indrelid AND
    a.indexrelid > b.indexrelid AND
    (
        (
            a.cols LIKE b.cols || '%' AND
            coalesce(substr(a.cols, length(b.cols) + 1, 1), ' ') = ' '
        ) OR
        (
            b.cols LIKE a.cols || '%' AND
            coalesce(substr(b.cols, length(a.cols) + 1, 1), ' ') = ' '
        )
    )
)
ORDER BY a.indrelid;

-- Этот запрос для того, чтобы посмотреть какие индексы пересекаются (работают по одному и тому же полю)
-- (Не совсем уверен, что работает корректно)