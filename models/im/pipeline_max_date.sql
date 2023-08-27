select cast(max(partition_date) as date) as last_run_date 
								from {{source('pei_ll_us_east1_dev_im','im_pipeline_details')}} 
									where partition_date > '1900-01-01'
							