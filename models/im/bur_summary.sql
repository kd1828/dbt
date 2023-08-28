with curr_prev_month_compute as
	(
			--- Computes curr month, prev month dates.
		select * from {{ ref('lastrun')}} 
			
	),

curr_prev_month_last_run_compute as
    (            
        select coalesce(cpmc.last_run_date,lastrun.last_run_date) as last_run_date,
            curr_month,
            prev_month,
            prev_2_month
                from curr_prev_month_compute cpmc
        cross join  {{ref('pipeline_max_date')}} as lastrun
                        order by curr_month desc limit 1 
    )
{#
s_pipeline as
(
    select a.* from 
    (
    Select *, date_trunc(cast(PARTITION_DATE as DATETIME),DAY) as Partitioned_date from {{source('pei_ll_us_east1_dev_bv','S_PIPELINE')}}  where '2022-03-04'>'1900-01-01'
    ) a 
    join
    (
    Select H_PIPELINE_HKEY, max(date_trunc(cast(PARTITION_DATE as DATETIME),DAY)) as Partitioned_date
    from {{source('pei_ll_us_east1_dev_bv','S_PIPELINE')}}
    cross join curr_prev_month_last_run_compute
    -- this is where all records until prev month are scanned
    -- dirty data exists on dt = '2022-03-04'
    where  '2022-03-04'>'2022-03-05' and cast(date_trunc(cast(PARTITION_DATE as DATETIME),DAY) as date) > last_run_date
    group by H_PIPELINE_HKEY
    ) b on a.H_PIPELINE_HKEY =b.H_PIPELINE_HKEY and a.Partitioned_date=b.Partitioned_date
    where trim(a.Reporting_Period) <>'0' or trim(a.Project_Number) <>'' or trim(a.CURRENCY_CODE) <> '' 
    ), 
    
    s_pipeline_im as 		 
    (
    select * from {{source('pei_ll_us_east1_dev_im','im_pipeline_details')}}
        where partition_date = (select max(partition_date) from {{source('pei_ll_us_east1_dev_im','im_pipeline_details')}}
                                                    where partition_date > '1900-01-01')
    ),
	 
unn as 
	(			 
		 -- Inserts and Updates 
		 
		 select 
			 CURRENCY_CODE 
			, Project_Name 
			, Project_Short_Name 
			, Project_Number 
			, Office 
			, Office_Parent 
			, Forecast_Secure_Date
			--, case when Forecast_Secure_Date is null or lower(Forecast_Secure_Date) ='null' or trim(Forecast_Secure_Date) ="" then cast(null as date) else cast(parse_date('%d/%m/%Y',Forecast_Secure_Date)  as date) end as Forecast_Secure_Date			
			, Construction_Sector_Name 
			, Strategic_Business_Unit_Name 
			, Operational_Unit 
			, Project_Sponsor 
			, Risk_Group 
			, Contract_Type 
			, Project_Status_Group 
			, Project_Status 
			, case when upper(In_Forecast)  = 'N' then cast(0  as bool)
					when  upper(In_Forecast)  = 'Y' then cast(1  as bool) else cast(null as bool) end as In_Forecast
			, LOA_Description 
			, Negotiate_Or_Compet 
			, case when Prob_Proceed_pct is null or lower(Prob_Proceed_pct) ='null' then cast(null as float64) else cast(Prob_Proceed_pct  as float64) end as Prob_Proceed_pct 
			, case when Prob_Bid_pct is null or lower(Prob_Bid_pct) ='null' then cast(null as float64) else cast(Prob_Bid_pct  as float64) end as Prob_Bid_pct 
			, case when Prob_Win_pct is null or lower(Prob_Win_pct) ='null' then cast(null as float64) else cast(Prob_Win_pct  as float64) end as Prob_Win_pct 
			, Prob_Proceed 
			, Prob_Bid 
			, Prob_Win 
			, PCP_CRM_Reference 
			, PCPGate 
			, RepeatClient 
			, Client_Contracting_Name 
			, Comment_Notes 
			, case when Reporting_Period is null or lower(Reporting_Period) ='null' then cast(null as date) else cast(parse_date('%d-%h-%Y',Reporting_Period)  as date) end as Reporting_Period
			, case when Contract_Schedule_Duration is null or lower(Contract_Schedule_Duration) ='null' then cast(null as int64) else cast(Contract_Schedule_Duration  as int64) end as Contract_Schedule_Duration
			 , case when Contract_Value is null or lower(Contract_Value) ='null' then cast(null as numeric) else round(cast(Contract_Value  as numeric),4) end as Contract_Value
			 , case when Strike_GPM is null or lower(Strike_GPM) ='null' then cast(null as numeric) else round(cast(Strike_GPM  as numeric),4) end as Strike_GPM
			 , case when Total_Forecast_Selling_Expense  is null or lower(Total_Forecast_Selling_Expense ) ='null' then cast(null as float64) else cast(Total_Forecast_Selling_Expense   as float64) end as Total_Forecast_Selling_Expense 
			 , case when Pipeline_GPM_pct  is null or lower(Pipeline_GPM_pct ) ='null' then cast(null as float64) else cast(Pipeline_GPM_pct   as float64) end as Pipeline_GPM_pct 
			 , Forecast_Complete_Date
			 , Head_Contract_Start_Date
			 , Forecast_Board_Date
			 , Forecast_GIC_Date
			 , Forecast_RIC_Date
			--, case when Forecast_Complete_Date is null or lower(Forecast_Complete_Date) ='null' or trim(Forecast_Complete_Date) ="" then cast(null as date) else cast(parse_date('%d/%m/%Y',Forecast_Complete_Date)  as date) end as Forecast_Complete_Date
			--, case when Head_Contract_Start_Date is null or lower(Head_Contract_Start_Date) ='null' or trim(Head_Contract_Start_Date) ="" then cast(null as date) else cast(parse_date('%d/%m/%Y',Head_Contract_Start_Date)  as date) end as Head_Contract_Start_Date
			--, case when Forecast_Board_Date is null or lower(Forecast_Board_Date) ='null' or trim(Forecast_Board_Date) ="" then cast(null as date) else cast(parse_date('%d/%m/%Y',Forecast_Board_Date)  as date) end as Forecast_Board_Date
			--, case when Forecast_GIC_Date is null or lower(Forecast_GIC_Date) ='null' or trim(Forecast_GIC_Date) ="" then cast(null as date) else cast(parse_date('%d/%m/%Y',Forecast_GIC_Date)  as date) end as Forecast_GIC_Date
			--, case when Forecast_RIC_Date is null or lower(Forecast_RIC_Date) ='null' or trim(Forecast_RIC_Date) ="" then cast(null as date) else cast(parse_date('%d/%m/%Y',Forecast_RIC_Date)  as date) end as Forecast_RIC_Date
			 
			, ClientSector 
			, ClientCategory 
			, case when LLShare  is null or lower(LLShare ) ='null' then cast(null as float64) else cast(LLShare   as float64) end as LLShare 
			, case when InternalShare is null or lower(InternalShare ) ='null'or lower(InternalShare ) ='' then cast(null as float64) else cast(InternalShare   as float64) end as InternalShare 
			, case when upper(JointVenture)  = 'N' then cast(0  as bool) when  upper(JointVenture)  = 'Y' then cast(1  as bool) else cast(null as bool) end as JointVenture
			, OracleOriginationProjectNum 
			, BidStartDate
			, BidCompletionDate
	
			--, case when BidStartDate is null or lower(BidStartDate) ='null' or trim(BidStartDate) ="" or trim(BidStartDate) ='Unallocated' then cast(null as date) else cast(parse_date('%d/%m/%Y',BidStartDate)  as date) end as BidStartDate
			--, case when BidCompletionDate is null or lower(BidCompletionDate) ='null' or trim(BidCompletionDate) ="" or trim(BidCompletionDate) ='Unallocated' then cast(null as date) else cast(parse_date('%d/%m/%Y',BidCompletionDate)  as date) end as BidCompletionDate
			
			, case when BidPeriods is null or lower(BidPeriods) ='null' then cast(null as int64) else cast(BidPeriods  as int64) end as BidPeriods
			, CASE WHEN Revenue_Dec_Current_FY  IS NULL OR lower(Revenue_Dec_Current_FY ) =  'null' then cast(null as float64) else cast(Revenue_Dec_Current_FY  as float64) end as Revenue_Dec_Current_FY 
			, CASE WHEN Revenue_Jun_Current_FY  IS NULL OR lower(Revenue_Jun_Current_FY ) =  'null' then cast(null as float64) else cast(Revenue_Jun_Current_FY  as float64) end as Revenue_Jun_Current_FY 
			, CASE WHEN Revenue_Dec_FY_1  IS NULL OR lower(Revenue_Dec_FY_1 ) =  'null' then cast(null as float64) else cast(Revenue_Dec_FY_1  as float64) end as Revenue_Dec_FY_1 
			, CASE WHEN Revenue_Jun_FY_1  IS NULL OR lower(Revenue_Jun_FY_1 ) =  'null' then cast(null as float64) else cast(Revenue_Jun_FY_1  as float64) end as Revenue_Jun_FY_1 
			, CASE WHEN Revenue_Dec_FY_2  IS NULL OR lower(Revenue_Dec_FY_2 ) =  'null' then cast(null as float64) else cast(Revenue_Dec_FY_2  as float64) end as Revenue_Dec_FY_2 
			, CASE WHEN Revenue_Jun_FY_2  IS NULL OR lower(Revenue_Jun_FY_2 ) =  'null' then cast(null as float64) else cast(Revenue_Jun_FY_2  as float64) end as Revenue_Jun_FY_2 
			, CASE WHEN GPM_Dec_Current_FY  IS NULL OR lower(GPM_Dec_Current_FY ) =  'null' then cast(null as float64) else cast(GPM_Dec_Current_FY  as float64) end as GPM_Dec_Current_FY 
			, CASE WHEN GPM_Jun_Current_FY  IS NULL OR lower(GPM_Jun_Current_FY ) =  'null' then cast(null as float64) else cast(GPM_Jun_Current_FY  as float64) end as GPM_Jun_Current_FY 
			, CASE WHEN GPM_Dec_FY_1  IS NULL OR lower(GPM_Dec_FY_1 ) =  'null' then cast(null as float64) else cast(GPM_Dec_FY_1  as float64) end as GPM_Dec_FY_1 
			, CASE WHEN GPM_Jun_FY_1  IS NULL OR lower(GPM_Jun_FY_1 ) =  'null' then cast(null as float64) else cast(GPM_Jun_FY_1  as float64) end as GPM_Jun_FY_1 
			, CASE WHEN GPM_Dec_FY_2  IS NULL OR lower(GPM_Dec_FY_2 ) =  'null' then cast(null as float64) else cast(GPM_Dec_FY_2  as float64) end as GPM_Dec_FY_2 
			, CASE WHEN GPM_Jun_FY_2  IS NULL OR lower(GPM_Jun_FY_2 ) =  'null' then cast(null as float64) else cast(GPM_Jun_FY_2  as float64) end as GPM_Jun_FY_2 
			, CASE WHEN Perecntage_Complete_Dec_Current_FY  IS NULL OR lower(Perecntage_Complete_Dec_Current_FY ) =  'null' then cast(null as float64) else cast(Perecntage_Complete_Dec_Current_FY  as float64) end as Perecntage_Complete_Dec_Current_FY 
			, CASE WHEN Perecntage_Complete_Jun_Current_FY  IS NULL OR lower(Perecntage_Complete_Jun_Current_FY ) =  'null' then cast(null as float64) else cast(Perecntage_Complete_Jun_Current_FY  as float64) end as Perecntage_Complete_Jun_Current_FY 
			, CASE WHEN Perecntage_Complete_Dec_FY_1  IS NULL OR lower(Perecntage_Complete_Dec_FY_1 ) =  'null' then cast(null as float64) else cast(Perecntage_Complete_Dec_FY_1  as float64) end as Perecntage_Complete_Dec_FY_1 
			, CASE WHEN Perecntage_Complete_Jun_FY_1  IS NULL OR lower(Perecntage_Complete_Jun_FY_1 ) =  'null' then cast(null as float64) else cast(Perecntage_Complete_Jun_FY_1  as float64) end as Perecntage_Complete_Jun_FY_1 
			, CASE WHEN Perecntage_Complete_Dec_FY_2  IS NULL OR lower(Perecntage_Complete_Dec_FY_2 ) =  'null' then cast(null as float64) else cast(Perecntage_Complete_Dec_FY_2  as float64) end as Perecntage_Complete_Dec_FY_2 
			, CASE WHEN Perecntage_Complete_Jun_FY_2  IS NULL OR lower(Perecntage_Complete_Jun_FY_2 ) =  'null' then cast(null as float64) else cast(Perecntage_Complete_Jun_FY_2  as float64) end as Perecntage_Complete_Jun_FY_2 
			, Client_Category 
			, CPC_Project_Group 
			, case when Extract_Date is null or Extract_Date ="" or trim(Extract_Date)='null'  then cast(null as datetime) else cast(parse_datetime('%Y-%m-%d %H:%M:%S', Extract_Date)  as datetime) end as Extract_Date
 			 , (SELECT DATE_TRUNC(datetime(timestamp(current_datetime, 'UTC'),'Australia/Sydney'),DAY)) AS PARTITION_DATE 
			
		 from s_pipeline src
		 
		 union all 
		 SELECT 
			  tgt.CURRENCY_CODE 
			, tgt.Project_Name 
			, tgt.Project_Short_Name 
			, tgt.Project_Number 
			, tgt.Office 
			, tgt.Office_Parent 
			, tgt.Forecast_Secure_Date
			, tgt.Construction_Sector_Name 
			, tgt.Strategic_Business_Unit_Name 
			, tgt.Operational_Unit 
			, tgt.Project_Sponsor 
			, tgt.Risk_Group 
			, tgt.Contract_Type 
			, tgt.Project_Status_Group 
			, tgt.Project_Status 
			, cast(tgt.In_Forecast as bool) as In_Forecast
			, tgt.LOA_Description 
			, tgt.Negotiate_Or_Compet 
			, cast(tgt.Prob_Proceed_pct  as float64) as Prob_Proceed_pct 
			, cast(tgt.Prob_Bid_pct  as float64) as Prob_Bid_pct 
			, cast(tgt.Prob_Win_pct  as float64) as Prob_Win_pct 
			, tgt.Prob_Proceed 
			, tgt.Prob_Bid 
			, tgt.Prob_Win 
			, tgt.PCP_CRM_Reference 
			, tgt.PCPGate 
			, tgt.RepeatClient 
			, tgt.Client_Contracting_Name 
			, tgt.Comment_Notes 
			, cast(tgt.Reporting_Period  as date) as Reporting_Period
			, cast(tgt.Contract_Schedule_Duration  as int64) as Contract_Schedule_Duration
			, round(cast(tgt.Contract_Value  as numeric),4) as Contract_Value
			, round(cast(tgt.Strike_GPM  as numeric),4) as Strike_GPM
			, cast(tgt.Total_Forecast_Selling_Expense   as float64) as Total_Forecast_Selling_Expense 
			, cast(tgt.Pipeline_GPM_pct   as float64) as Pipeline_GPM_pct 
			, tgt.Forecast_Complete_Date
			, tgt.Head_Contract_Start_Date
			, tgt.Forecast_Board_Date
			, tgt.Forecast_GIC_Date
			, tgt.Forecast_RIC_Date
			, tgt.ClientSector 
			, tgt.ClientCategory 
			, cast(tgt.LLShare   as float64) as LLShare 
			, cast(tgt.InternalShare   as float64) as InternalShare 
			, cast(tgt.JointVenture as bool) as JointVenture
			, tgt.OracleOriginationProjectNum 
			, tgt.BidStartDate
			, tgt.BidCompletionDate
			, cast(tgt.BidPeriods  as int64) as BidPeriods
			, cast(tgt.Revenue_Dec_Current_FY  as float64) as Revenue_Dec_Current_FY 
			, cast(tgt.Revenue_Jun_Current_FY  as float64) as Revenue_Jun_Current_FY 
			, cast(tgt.Revenue_Dec_FY_1  as float64) as Revenue_Dec_FY_1 
			, cast(tgt.Revenue_Jun_FY_1  as float64) as Revenue_Jun_FY_1 
			, cast(tgt.Revenue_Dec_FY_2  as float64)as Revenue_Dec_FY_2 
			, cast(tgt.Revenue_Jun_FY_2  as float64)as Revenue_Jun_FY_2 
			, cast(tgt.GPM_Dec_Current_FY  as float64) as GPM_Dec_Current_FY 
			, cast(tgt.GPM_Jun_Current_FY  as float64) as GPM_Jun_Current_FY 
			, cast(tgt.GPM_Dec_FY_1  as float64)  as GPM_Dec_FY_1 
			, cast(tgt.GPM_Jun_FY_1  as float64) as GPM_Jun_FY_1 
			, cast(tgt.GPM_Dec_FY_2  as float64) as GPM_Dec_FY_2 
			, cast(tgt.GPM_Jun_FY_2  as float64) as GPM_Jun_FY_2 
			, cast(tgt.Perecntage_Complete_Dec_Current_FY  as float64) as Perecntage_Complete_Dec_Current_FY 
			, cast(tgt.Perecntage_Complete_Jun_Current_FY  as float64) as Perecntage_Complete_Jun_Current_FY 
			, cast(tgt.Perecntage_Complete_Dec_FY_1  as float64) as Perecntage_Complete_Dec_FY_1 
			, cast(tgt.Perecntage_Complete_Jun_FY_1  as float64) as Perecntage_Complete_Jun_FY_1 
			, cast(tgt.Perecntage_Complete_Dec_FY_2  as float64) as Perecntage_Complete_Dec_FY_2 
			, cast(tgt.Perecntage_Complete_Jun_FY_2  as float64) as Perecntage_Complete_Jun_FY_2 
			, tgt.Client_Category 
			, tgt.CPC_Project_Group 
			, cast(tgt.Extract_Date  as datetime) as Extract_Date
 			, (SELECT DATE_TRUNC(datetime(timestamp(current_datetime, 'UTC'),'Australia/Sydney'),DAY)) AS PARTITION_DATE 
			FROM 
			(select * from s_pipeline_im where partition_date > '1900-01-01' )tgt
			left join 
				(SELECT * FROM s_pipeline  WHERE partition_date > '1900-01-01') src   
			on 	tgt.Reporting_Period = case when src.Reporting_Period is null or lower(src.Reporting_Period) ='null' then cast(null as date) else cast(parse_date('%d-%h-%Y',src.Reporting_Period)  as date) end and 
				tgt.Project_Number = src.Project_Number and 
				trim(tgt.CURRENCY_CODE) = trim(src.CURRENCY_CODE)
				where src.Project_Number is null
					
		)
select distinct * from unn
    #}
        
select distinct * from curr_prev_month_last_run_compute