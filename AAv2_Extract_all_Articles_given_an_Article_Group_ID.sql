SELECT * 
FROM public.article a 
WHERE a.article_id in (
    SELECT CAST(UNNEST(ag.article_ids_array) AS INTEGER) as article_id
    FROM public.custom_glossary ag
    WHERE ag.customglossary_id = ${Article Group ID}
  )
AND a.deleted is false
--AND a.private is false
ORDER BY a.title