
select OBJECT_NAME(object_id) as contrain_name
	,OBJECT_NAME(parent_object_id) as costrain_table
	,OBJECT_NAME(referenced_object_id) as ref_table
from sys.foreign_keys
where OBJECT_NAME(referenced_object_id) not in ('etl_batches', 'etl_batch_details')


select 
	concat('ALTER TABLE ', OBJECT_NAME(a.parent_object_id), ' 
		DROP CONSTRAINT ', OBJECT_NAME(a.constraint_object_id) ,'; ') AS CreateFkSqlTx 
	, concat('ALTER TABLE ', OBJECT_NAME(a.parent_object_id), ' 
		ADD CONSTRAINT ', OBJECT_NAME(a.constraint_object_id) ,' 
			FOREIGN KEY (', b.name ,')
				REFERENCES ',OBJECT_NAME(a.referenced_object_id),' (',c.name,')
				ON DELETE CASCADE ; ') AS DropFkSqlTx
from sys.foreign_key_columns AS a
JOIN sys.columns as b
	on a.parent_column_id = b.column_id
	and a.parent_object_id = b.object_id	
JOIN sys.columns as c
	on a.referenced_column_id = c.column_id
	and a.referenced_object_id = c.object_id
where 1=1
--and OBJECT_NAME(a.constraint_object_id)= 'fk4_fact_service_order'
and OBJECT_NAME(referenced_object_id) not in ('etl_batches', 'etl_batch_details')




/*
ALTER TABLE fact_service_order     
	DROP CONSTRAINT fk4_fact_service_order; 	

ALTER TABLE fact_service_order     
	ADD CONSTRAINT fk4_fact_service_order      
		FOREIGN KEY (orgsys)      
			REFERENCES dim_organizations (OrgSys)      
		ON DELETE CASCADE ; 
*/



ALTER TABLE fact_service_order     DROP CONSTRAINT fk4_fact_service_order; 	
go
ALTER TABLE dim_pay_rate     DROP CONSTRAINT fk3_dim_pay_rate; 	
go
ALTER TABLE dim_pay_rate     DROP CONSTRAINT fk2_dim_pay_rate; 	
go
ALTER TABLE fact_service_order     DROP CONSTRAINT fk3_fact_service_order; 	
go
ALTER TABLE dim_alerts     DROP CONSTRAINT fk2_dim_alerts; 	
go
ALTER TABLE dim_alerts     DROP CONSTRAINT fk3_dim_alerts; 	
go
ALTER TABLE dim_entity_event     DROP CONSTRAINT fk_dim_entity_event_dim_entity_entsys; 	
go
ALTER TABLE dim_frp_policy     DROP CONSTRAINT fk_dim_frp_policy_dim_entity_frpsys; 	
go
ALTER TABLE dim_pay_rate     DROP CONSTRAINT fk1_dim_pay_rate; 
go
ALTER TABLE dim_adm_prior_authorization     DROP CONSTRAINT fk_dim_adm_prior_authorization; 	
go
ALTER TABLE dim_alerts     DROP CONSTRAINT fk_dim_alerts; 	
go
ALTER TABLE dim_frp_bill_seq     DROP CONSTRAINT fk_dim_frp_bill_seq_dim_admissions_admsys; 	
go
ALTER TABLE dim_admission_bill_hold     DROP CONSTRAINT fk1_dim_admission_bill_hold; 	
go



------
ALTER TABLE dim_alerts     ADD CONSTRAINT fk_dim_alerts      FOREIGN KEY (admsys)      REFERENCES dim_admissions (admsys)      ON DELETE CASCADE ; 
go
print  'done 13'
go
ALTER TABLE dim_alerts     ADD CONSTRAINT fk2_dim_alerts      FOREIGN KEY (patsys)      REFERENCES dim_entity (entsys)      ON DELETE CASCADE ; 
go
print  'done 12'
go
ALTER TABLE dim_alerts     ADD CONSTRAINT fk3_dim_alerts      FOREIGN KEY (resprssys)      REFERENCES dim_entity (entsys)   ; 
go
print  'done 11'
go





ALTER TABLE fact_service_order     ADD CONSTRAINT fk4_fact_service_order      FOREIGN KEY (orgsys)      REFERENCES dim_organizations (OrgSys)      ON DELETE CASCADE ; 
go
print  'done 1'
go
ALTER TABLE dim_pay_rate     ADD CONSTRAINT fk3_dim_pay_rate      FOREIGN KEY (orgsys)      REFERENCES dim_organizations (OrgSys)      ON DELETE CASCADE ; 
go
print  'done 2'
go
ALTER TABLE dim_pay_rate     ADD CONSTRAINT fk2_dim_pay_rate      FOREIGN KEY (plnsys)      REFERENCES dim_insurance_plans (plnsys)      ON DELETE CASCADE ; 
go
print  'done 3'
go
ALTER TABLE fact_service_order     ADD CONSTRAINT fk3_fact_service_order      FOREIGN KEY (svcsys)      REFERENCES dim_services (svcsys)      ON DELETE CASCADE ; 
go
print  'done 4'
go
ALTER TABLE dim_entity_event     ADD CONSTRAINT fk_dim_entity_event_dim_entity_entsys      FOREIGN KEY (entsys)      REFERENCES dim_entity (entsys)      ON DELETE CASCADE ; 
go
print  'done 6'
go
ALTER TABLE dim_frp_policy     ADD CONSTRAINT fk_dim_frp_policy_dim_entity_frpsys      FOREIGN KEY (frpsys)      REFERENCES dim_entity (entsys)      ON DELETE CASCADE ; 
go
print  'done 7'
go
ALTER TABLE dim_pay_rate     ADD CONSTRAINT fk1_dim_pay_rate      FOREIGN KEY (prssys)      REFERENCES dim_entity (entsys)      ON DELETE CASCADE ; 
go
print  'done 8'
go
ALTER TABLE dim_adm_prior_authorization     ADD CONSTRAINT fk_dim_adm_prior_authorization      FOREIGN KEY (admsys)      REFERENCES dim_admissions (admsys)      ON DELETE CASCADE ; 
go
print  'done 9'
go
ALTER TABLE dim_frp_bill_seq     ADD CONSTRAINT fk_dim_frp_bill_seq_dim_admissions_admsys      FOREIGN KEY (admsys)      REFERENCES dim_admissions (admsys)      ON DELETE CASCADE ; 
go
print  'done 11'
go
ALTER TABLE dim_admission_bill_hold     ADD CONSTRAINT fk1_dim_admission_bill_hold      FOREIGN KEY (admsys)      REFERENCES dim_admissions (admsys)      ON DELETE CASCADE ; 
go
print  'done 12'
go



