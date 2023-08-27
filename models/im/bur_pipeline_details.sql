SELECT * from 
    {{source('pei_ll_us_east1_dev_im','im_pipeline_details')}}
	WHERE PARTITION_DATE  = 
		(SELECT MAX(PARTITION_DATE) FROM {{source('pei_ll_us_east1_dev_im','im_pipeline_details')}}
			where  PARTITION_DATE> '1900-01-01' )
and PARTITION_DATE> '1900-01-01' --test

---test