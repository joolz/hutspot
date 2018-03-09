# check character set for schema
SELECT 
    schema_name, default_character_set_name
FROM
    information_schema.SCHEMATA
WHERE
    schema_name = 'dlwo_tst'
        AND default_character_set_name <> 'utf8';

# check character set for tables
SELECT 
    T.table_name, CCSA.character_set_name
FROM
    information_schema.`TABLES` T,
    information_schema.`COLLATION_CHARACTER_SET_APPLICABILITY` CCSA
WHERE
    CCSA.collation_name = T.table_collation
        AND T.table_schema = 'dlwo_tst'
        AND CCSA.character_set_name <> 'utf8'
ORDER BY T.table_name;

# check character set for columns
SELECT 
    distinct character_set_name
FROM
    information_schema.`COLUMNS`
WHERE
    table_schema = 'dlwo_tst'
        AND character_set_name IS NOT NULL
        AND character_set_name <> 'utf8';

# check collation for tables
SELECT 
    table_collation, table_name
FROM
    information_schema.tables
WHERE
    table_schema = 'dlwo_tst'
        AND table_collation <> 'utf8_unicode_ci'
ORDER BY table_collation , table_name;

# check collation for columns
SELECT 
    collation_name, table_name, column_name
FROM
    information_schema.columns
WHERE
    table_schema = 'dlwo_tst'
        AND collation_name IS NOT NULL AND collation_name <> 'utf8_unicode_ci'
ORDER BY collation_name , table_name , column_name;
