{{ config(materialized='table') }}

SELECT distinct 
                        current_month as last_run_date,
                        last_day(current_month) curr_month, 
						last_day(DATE_ADD(current_month, INTERVAL -1 MONTH)) as prev_month,
						last_day(DATE_ADD(current_month, INTERVAL -2 MONTH)) as prev_2_month
			FROM UNNEST
				(
					GENERATE_DATE_ARRAY
						(
							(select cast(max(partition_date) as date) as partition_date 
								from {{source('pei_ll_us_east1_dev_im','im_pipeline_details')}} 
									where partition_date > '1900-01-01'
							) , CURRENT_DATE(), INTERVAL 1 DAY
						)
				) AS current_month
                
union all                                 

            select 
               cast('1900-01-01' as date) as last_run_date,
               last_day(cast(current_date as date)) as curr_month,
               last_day(DATE_ADD(current_date, INTERVAL -1 MONTH)) as prev_month,
               last_day(DATE_ADD(current_date, INTERVAL -2 MONTH)) as prev_2_month