-- https://habr.com/ru/articles/276973/
-- https://www.youtube.com/watch?v=aaecM4wKdhY

-- Создаем просто для проверки с одним полем (можно не делать)
CREATE INDEX products_desc_btree_inx
ON products
USING btree (description);

-- Создаем индекс по 2 полям строковым (ну на самом деле не важно,
-- т.к. у нас строки да цифры, нам нужен только стандартный btree индекс)
CREATE INDEX products_title_desc_btree_inx
ON products
USING btree (title, description);

-- explain analyse говорит нам какая стратегия была выбрана планировщиком postgres для выполнения запроса,
-- сколько строк было выбрано, а также за сколько времени это сделано.

    -- Вообще у нас 3 основных стратегии:
        -- Sequence scan - это мы просто перебираем каждую строку в таблице, тупо проверяем условие, если походит, то берем в селект
        -- Bitmap scan - это когда у нас есть условие, которое сильно сужает выборку (например, половину); то есть ну уже не
            -- так классно идти по всей таблице, чтоб все равно потом отсечь большую часть. Поэтому мы строим дополнительную битовую карту,
            -- которая говорит ,что нужная строка по условию может быть на этой странице, и позволяет не смотреть в таблицу каждый раз, поэтому все быстрее.
        -- Index scan - если у нас есть подходящий по столбику индекс (именно по нему условия, группировка или сортировка)
            -- (если 2 поля в индексе, то нужно эти же 2 поля, в том же порядке, но можно и левый (только левый)), то мы
            -- будем использовать его, чтобы быстрее найти нужную строку.

-- Сейчас у нас выбрана вся таблица, планировщик подумает, что нахрен ему составлять какие-то стратегии, если все равно все возвращать, поэтому seq scan.
EXPLAIN ANALYSE SELECT * FROM products;

-- тут уже у планировщика точные условия, но конкретно сейчас тут "ну найди те ,в которые начинаются на b и есть еще гд-то буква а",
    -- потенциально это может быть очень много строк, мы же заранее не знаем че за данные, поэтому seq scan.
EXPLAIN ANALYSE SELECT * FROM  products
    WHERE
        title LIKE 'b%'
        AND
        description LIKE '%a%'
;

-- если поставить жесткие условия (например, =), то нам нужно будет выбрать малое кол-во строк, будет Bitmap index scan (если есть индекс),
    -- index scan
EXPLAIN ANALYSE SELECT * FROM  products
    WHERE
        description = 'amqdvsenaljmaibjzwbeikeaqxtmgslvjvncuytmixgdvovcjfsrrvqtcuvzedknmjomocracbgeqybmngkfafukkgxxxllcpukbhudelnpxriwxaoyjhmhrzgyioetrugrwobiizvtgpdctripzizwxkamcagpouwiuhxcdxnroiisbzhopdahcudzbuoaryddcqhofvlhxrdnhffbkrbyosjpvexeqllytzulovzrvswymluulypkghfaykgbcioztumsbncpxqmuhfzwlrskadevjkoyzwlsoirnmoviofvwguhfrhxbiczyuwonvqxhgjlmjuqbrxzwmhaayzppavrwhjnxjctdiosazbbkgbzytzjfmtokajxbryfxptsrwhbdxvyzxclvjthusqzxrihdtfzddbqcfqnjgjoqtcfinkmukumrfrbyjaiteknqznexigqeqfkfovwguvwsytspdjhqykimvkeodfsoulhtphtutdutsvewsdbzkrehftigzmjqgraerjbmurwankudwbeclzxfjnfgnsjipipshkahlupqaedqlcurxkqijqptermmdzixnekpxhgmjazebyrxfskjyqgvjjwytlwhaskfrujepfyvejcwmgyqrmzqpqrdalyqhsjrgjrgfpwlgmoxmmpwzmvfwopjwkmjiqijhyrljqilmuacgvpfmsjglqbflxtubcoihjobicgafrdiildsqfoxjqpxdorlrubudinexowxpsnxrzrwjvekjzpmjssjtmuhlnubqryqgyfmoedcrauuslmfeyyevahioyrbsenfzcihhykrbtbotypmanxwxrywkdxfeicqueacvzxylinsywgwuvsiuvlyexbpwlxmvyknoehtrftnlougiiucniojedphhnuionmyibcddrohekzibrpaqqvmzzrclfhnlqdwjipcufhtofyalczjukxiunbxtgnyxohnxmyspnxvkgjotfjpygwfnipyaawwxlvwy'
;



-- возможность заставить планировщик напрямую не выбирать стратегии
SET enable_indexscan = OFF;
SET enable_indexscan = ON;

SET enable_seqscan = OFF;
SET enable_seqscan = ON;

SET enable_bitmapscan = OFF;
SET enable_bitmapscan = ON;




-- ну и второй индекс, советую выбирать информативное название.
CREATE INDEX rates_gbs_mins_inx
ON rates (gigabytes, minutes);

EXPLAIN ANALYSE SELECT * FROM rates
WHERE
    gigabytes = 50 AND
    minutes < 30
;

drop index rates_gbs_mins_inx;


