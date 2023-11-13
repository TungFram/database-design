SELECT
    schemaname || '.' || relname as table_name,
    indexrelname AS index,
    pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size,
    idx_scan AS index_scans
FROM pg_stat_user_indexes AS ui
JOIN pg_index AS i ON ui.indexrelid = i.indexrelid
WHERE NOT indisunique AND
      idx_scan < 50 AND
      pg_relation_size(relid) > 5 * 8192
ORDER BY
    pg_relation_size(i.indexrelid) / nullif(idx_scan, 0) DESC NULLS FIRST,
    pg_relation_size(i.indexrelid) desc;

-- Это запрос для просмотра какие индексы солько раз были использованы, можно использовать при защите
-- (запустил индекс -> запустил этот запрос -> вот там +1)