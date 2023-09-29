--CR174B
--QUERY 2
--BD/ILL – count of items borrowed BY CUL (CUL is BORROWER)

WITH parameters AS (
    SELECT
        /* Choose a start and end date for the loans period */ 
        '2021-07-01'::date AS start_date,
        '2025-07-01'::date AS end_date
        )
SELECT
        TO_CHAR (CURRENT_DATE::DATE,'mm/dd/yyyy') AS todays_date,
        li.current_item_permanent_location_name,
        li.patron_group_name,
        COUNT (li.loan_id) AS total_circs,
        
        CASE WHEN
    	date_part ('month',li.loan_date ::DATE) >'6' 
        THEN concat ('FY ', date_part ('year',li.loan_date::DATE) + 1) 
        ELSE concat ('FY ', date_part ('year',li.loan_date::DATE))
        END as fiscal_year_of_loan,
        
        CASE WHEN 
        (li.material_type_name ilike 'BD%' OR li.item_effective_location_name_at_check_out ILIKE 'Borr%') THEN 'Borrow Direct'
        WHEN (li.material_type_name ilike 'ILL*%' OR li.item_effective_location_name_at_check_out ILIKE 'Inter%') then 'Interlibrary Loan'
		ELSE 'Not BDILL'
		END AS BDILL_type
		
		
FROM folio_reporting.loans_items AS li
        LEFT JOIN folio_reporting.locations_libraries AS ll 
        ON li.current_item_permanent_location_id = ll.location_id

WHERE 
		li.loan_date >= (SELECT start_date FROM parameters)
    	AND li.loan_date < (SELECT end_date FROM parameters) 
        AND (li.item_effective_location_name_at_check_out ILIKE ANY (ARRAY ['Borrow%', 'Inter%']) 
        OR (li.material_type_name ILIKE ANY (ARRAY['BD%', 'ILL*%'])))

GROUP BY
        TO_CHAR (CURRENT_DATE::DATE,'mm/dd/yyyy'),
        li.current_item_permanent_location_name,
        li.patron_group_name,
        fiscal_year_of_loan,
        BDILL_type
        
ORDER BY
        li.current_item_permanent_location_name ASC,
        li.patron_group_name ASC
  ;
