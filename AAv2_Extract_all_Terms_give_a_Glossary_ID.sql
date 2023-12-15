/*
AAv2 - Extract all Terms give a Glossary ID
This query extracts the Terms associated with a Glossary given a Glossary ID (found in the glossary URL).
*/


SELECT * 
FROM public.terms t 
WHERE t.id in (
    SELECT CAST(replace(UNNEST(g.glossary_links),'glossary_term:','') AS INTEGER) as term_id
  FROM public.glossaries g
  WHERE g.id = ${Glossary ID}
  )
AND a.deleted is false
--AND a.private is false
ORDER BY a.title
