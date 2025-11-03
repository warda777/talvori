WITH t AS (
  SELECT c.oid,
         n.nspname  AS schema,
         c.relname  AS table_name,
         COALESCE(obj_description(c.oid,'pg_class'),'') AS table_comment
  FROM pg_class c
  JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE c.relkind='r' AND n.nspname='public'
),
cols AS (
  SELECT
    t.schema, t.table_name, t.oid, a.attnum AS pos,
    a.attname AS column_name,
    pg_catalog.format_type(a.atttypid,a.atttypmod) AS data_type,
    CASE WHEN a.attnotnull THEN 'NO' ELSE 'YES' END AS is_nullable,
    pg_get_expr(ad.adbin, ad.adrelid) AS default_expr,
    EXISTS (SELECT 1 FROM pg_index i WHERE i.indrelid=t.oid AND i.indisprimary AND a.attnum = ANY(i.indkey)) AS is_pk,
    COALESCE(col_description(t.oid, a.attnum),'') AS column_comment
  FROM t
  JOIN pg_attribute a ON a.attrelid=t.oid AND a.attnum>0 AND NOT a.attisdropped
  LEFT JOIN pg_attrdef ad ON ad.adrelid=a.attrelid AND ad.adnum=a.attnum
),
fks AS (
  SELECT
    t.schema,
    rel.relname AS table_name,
    con.conname AS fk_name,
    fn.nspname||'.'||frel.relname AS ref_table,
    string_agg(att.attname, ', ' ORDER BY k.ord)   AS local_cols,
    string_agg(att2.attname, ', ' ORDER BY fk.ord) AS ref_cols,
    con.confupdtype,
    con.confdeltype
  FROM pg_constraint con
  JOIN pg_class     rel  ON rel.oid=con.conrelid
  JOIN pg_namespace n    ON n.oid=rel.relnamespace
  JOIN t                   ON t.oid=rel.oid
  JOIN pg_class     frel ON frel.oid=con.confrelid
  JOIN pg_namespace fn   ON fn.oid=frel.relnamespace
  JOIN unnest(con.conkey)  WITH ORDINALITY k(attnum, ord)  ON TRUE
  JOIN unnest(con.confkey) WITH ORDINALITY fk(attnum, ord) ON fk.ord=k.ord
  JOIN pg_attribute  att  ON att.attrelid  = rel.oid  AND att.attnum  = k.attnum
  JOIN pg_attribute  att2 ON att2.attrelid = frel.oid AND att2.attnum = fk.attnum
  WHERE con.contype='f'
  GROUP BY
    t.schema, rel.relname, con.conname, fn.nspname, frel.relname,
    con.confupdtype, con.confdeltype
),
fk_text AS (
  SELECT schema, table_name,
         string_agg(
           '- **'||fk_name||'**: ('||local_cols||') → '||ref_table||' ('||ref_cols||')'
           || ' · on update '||
           CASE confupdtype
             WHEN 'a' THEN 'NO ACTION' WHEN 'r' THEN 'RESTRICT' WHEN 'c' THEN 'CASCADE'
             WHEN 'n' THEN 'SET NULL'  WHEN 'd' THEN 'SET DEFAULT' ELSE confupdtype::text END
           || ' · on delete '||
           CASE confdeltype
             WHEN 'a' THEN 'NO ACTION' WHEN 'r' THEN 'RESTRICT' WHEN 'c' THEN 'CASCADE'
             WHEN 'n' THEN 'SET NULL'  WHEN 'd' THEN 'SET DEFAULT' ELSE confdeltype::text END
         , E'\n' ORDER BY fk_name) AS bullets
  FROM fks
  GROUP BY schema, table_name
),
per_table AS (
  SELECT
    c.schema, c.table_name,
    '## '||c.schema||'.'||c.table_name||E'\n\n'
    || CASE WHEN t.table_comment<>'' THEN '> '||t.table_comment||E'\n\n' ELSE '' END
    || '| # | Column | Type | Null | PK | Default | Description |' || E'\n'
    || '|---|--------|------|------|----|---------|-------------|' || E'\n'
    || string_agg(
         '| '||c.pos||' | '||c.column_name||' | '||replace(c.data_type,'|','\|')
         ||' | '||c.is_nullable
         ||' | '||CASE WHEN c.is_pk THEN 'YES' ELSE '' END
         ||' | '||COALESCE(replace(c.default_expr,'|','\|'),'')
         ||' | '||COALESCE(replace(c.column_comment,'|','\|'),'')
         ||' |'
       , E'\n' ORDER BY c.pos)
    || E'\n\n'
    || CASE WHEN ft.bullets IS NOT NULL THEN '#### Foreign Keys' || E'\n' || ft.bullets || E'\n\n' ELSE '' END
    AS section_md
  FROM cols c
  JOIN t   ON t.oid=c.oid
  LEFT JOIN fk_text ft ON ft.schema=c.schema AND ft.table_name=c.table_name
  GROUP BY c.schema, c.table_name, t.table_comment, ft.bullets
)
SELECT
  '# Talvori – Data Dictionary (public)' || E'\n\n'
  || 'Generiert: '||to_char(now(),'YYYY-MM-DD HH24:MI')||E'\n\n'
  || string_agg(section_md, E'\n' ORDER BY schema, table_name)
AS markdown
FROM per_table;
