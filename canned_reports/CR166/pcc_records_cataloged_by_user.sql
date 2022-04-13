WITH source_pcc AS(
SELECT DISTINCT 
  sm1.instance_hrid,
  sm1.instance_id,
  sm1.field AS "042",
  sm1."content" AS "042_cnt"
  FROM srs_marctab sm1
  WHERE (sm1.field = '042' AND sm1.sf = 'a' AND sm1."content" = 'pcc')
),
source_coo AS(
SELECT DISTINCT 
  sm2.instance_hrid,
  sm2.instance_id,
  sm2.field AS "040",
  sm2.sf,
  sm2."content" AS "040_cnt",
  sc."042",
  sc."042_cnt"
  FROM sourc_pcc AS sc
  LEFT JOIN srs_marctab sm2 ON sm2.instance_id = sc.instance_id
  WHERE (sm2.field = '040' AND sm2.sf = 'a' AND sm2."content" = 'COO')
  OR (sm2.field = '040' AND sm2.sf = 'd' AND sm2."content" = 'COO')
 )
SELECT 
  scc.instance_hrid,
  scc."042",
  scc."042_cnt",
  scc."040",
  scc.sf,
  scc."040_cnt",
  json_extract_path_text(ii.data, 'metadata','createdByUserId') as created_by_user_id,
  json_extract_path_text(uu.data,'personal','lastName') as last_name,
  json_extract_path_text(uu.data,'personal','firstName') as first_name
  FROM source_coo scc
  LEFT JOIN folio_reporting.instance_ext ie ON scc.instance_id = ie.instance_id
  LEFT JOIN inventory_instances ii ON ie.instance_id = ii.id 
  LEFT JOIN user_users  uu ON json_extract_path_text(ii.data, 'metadata','createdByUserId') = uu.id 
  WHERE ie.record_created_date::date >= '2021-07-01' -- IF range is needed use 'BETWEEN' instead of ">="
;
