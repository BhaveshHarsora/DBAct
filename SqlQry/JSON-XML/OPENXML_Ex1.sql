/*
Date 14 Nov 2021
OPENXML Example, Read data from Node''s various fields 
*/
use master
GO

declare @docHandle as int, @xml as nvarchar(max) = '
<inputColumns>
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[recorded_date]"
		cachedDataType="dbDate"
		cachedName="recorded_date"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_0]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[recorded_date]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[recorded_time]"
		cachedDataType="dbTime"
		cachedName="recorded_time"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_1]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[recorded_time]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[recorded_date_time]"
		cachedDataType="dbTimeStamp2"
		cachedName="recorded_date_time"
		cachedScale="6"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_2]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[recorded_date_time]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[cid]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="cid"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_3]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[cid]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[session_id]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="session_id"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_4]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[session_id]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[client_name]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="client_name"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_5]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[client_name]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[domain]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="domain"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_6]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[domain]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[group_name]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="group_name"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_7]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[group_name]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[plugin_number]"
		cachedDataType="i4"
		cachedName="plugin_number"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_8]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[plugin_number]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[plugin_name]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="plugin_name"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_9]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[plugin_name]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[type]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="type"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_10]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[type]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[initiated_by]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="initiated_by"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_11]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[initiated_by]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[dataset]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="dataset"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_12]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[dataset]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[effective_path]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="effective_path"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_13]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[effective_path]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[dataset_override]"
		cachedCodepage="1252"
		cachedDataType="str"
		cachedLength="5"
		cachedName="dataset_override"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_14]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[dataset_override]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[retention_policy]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="retention_policy"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_15]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[retention_policy]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[effective_expiration_ts]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="effective_expiration_ts"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_16]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[effective_expiration_ts]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[effective_expiration]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="effective_expiration"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_17]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[effective_expiration]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[retention_policy_override]"
		cachedCodepage="1252"
		cachedDataType="str"
		cachedLength="5"
		cachedName="retention_policy_override"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_18]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[retention_policy_override]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[schedule]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="schedule"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_19]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[schedule]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[scheduled_start_ts]"
		cachedDataType="dbTimeStamp2"
		cachedName="scheduled_start_ts"
		cachedScale="6"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_20]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[scheduled_start_ts]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[scheduled_start_date]"
		cachedDataType="dbDate"
		cachedName="scheduled_start_date"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_21]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[scheduled_start_date]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[scheduled_end_ts]"
		cachedDataType="dbTimeStamp2"
		cachedName="scheduled_end_ts"
		cachedScale="6"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_22]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[scheduled_end_ts]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[scheduled_start_time]"
		cachedDataType="dbTime"
		cachedName="scheduled_start_time"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_23]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[scheduled_start_time]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[scheduled_end_date]"
		cachedDataType="dbDate"
		cachedName="scheduled_end_date"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_24]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[scheduled_end_date]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[scheduled_end_time]"
		cachedDataType="dbTime"
		cachedName="scheduled_end_time"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_25]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[scheduled_end_time]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[started_ts]"
		cachedDataType="dbTimeStamp2"
		cachedName="started_ts"
		cachedScale="6"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_26]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[started_ts]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[started_date]"
		cachedDataType="dbDate"
		cachedName="started_date"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_27]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[started_date]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[started_time]"
		cachedDataType="dbTime"
		cachedName="started_time"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_28]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[started_time]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[completed_ts]"
		cachedDataType="dbTimeStamp2"
		cachedName="completed_ts"
		cachedScale="6"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_29]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[completed_ts]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[completed_date]"
		cachedDataType="dbDate"
		cachedName="completed_date"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_30]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[completed_date]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[completed_time]"
		cachedDataType="dbTime"
		cachedName="completed_time"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_31]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[completed_time]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[num_of_files]"
		cachedDataType="r8"
		cachedName="num_of_files"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_32]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[num_of_files]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[bytes_scanned]"
		cachedDataType="r8"
		cachedName="bytes_scanned"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_33]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[bytes_scanned]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[bytes_new]"
		cachedDataType="r8"
		cachedName="bytes_new"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_34]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[bytes_new]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[bytes_modified]"
		cachedDataType="r8"
		cachedName="bytes_modified"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_35]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[bytes_modified]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[bytes_modified_sent]"
		cachedDataType="r8"
		cachedName="bytes_modified_sent"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_36]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[bytes_modified_sent]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[bytes_modified_not_sent]"
		cachedDataType="r8"
		cachedName="bytes_modified_not_sent"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_37]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[bytes_modified_not_sent]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[status_code]"
		cachedDataType="i4"
		cachedName="status_code"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_38]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[status_code]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[error_code]"
		cachedDataType="i4"
		cachedName="error_code"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_39]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[error_code]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[encryption_method]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="encryption_method"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_40]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[encryption_method]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[encryp_method2]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="encryp_method2"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_41]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[encryp_method2]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[encryp_method2_sa]"
		cachedCodepage="1252"
		cachedDataType="str"
		cachedLength="5"
		cachedName="encryp_method2_sa"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_42]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[encryp_method2_sa]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[bytes_excluded]"
		cachedDataType="r8"
		cachedName="bytes_excluded"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_43]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[bytes_excluded]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[bytes_skipped]"
		cachedDataType="r8"
		cachedName="bytes_skipped"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_44]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[bytes_skipped]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[num_files_skipped]"
		cachedDataType="r8"
		cachedName="num_files_skipped"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_45]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[num_files_skipped]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[client_os]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="client_os"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_46]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[client_os]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[client_ver]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="client_ver"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_47]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[client_ver]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[bytes_overhead]"
		cachedDataType="r8"
		cachedName="bytes_overhead"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_48]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[bytes_overhead]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[status_code_summary]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="status_code_summary"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_49]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[status_code_summary]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[error_code_summary]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="error_code_summary"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_50]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[error_code_summary]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[backup_label]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="backup_label"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_51]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[backup_label]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[backup_number]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="backup_number"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_52]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[backup_number]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[systemid]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="systemid"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_53]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[systemid]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[expiration_ts]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="expiration_ts"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_54]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[expiration_ts]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[expiration]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="expiration"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_55]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[expiration]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[createtime]"
		cachedDataType="i4"
		cachedName="createtime"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_56]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[createtime]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[original_retention]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="original_retention"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_57]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[original_retention]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[current_retention]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="current_retention"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_58]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[current_retention]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[proxy_cid]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="proxy_cid"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_59]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[proxy_cid]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[display_name]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="display_name"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_60]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[display_name]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[server]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="server"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_61]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[server]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[wid]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="wid"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_62]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[wid]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[ddr_hostname]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="ddr_hostname"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_63]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[ddr_hostname]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[ddrid]"
		cachedDataType="wstr"
		cachedLength="255"
		cachedName="ddrid"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_64]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[ddrid]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[hard_limit_exceeded]"
		cachedCodepage="1252"
		cachedDataType="str"
		cachedLength="5"
		cachedName="hard_limit_exceeded"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_65]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[hard_limit_exceeded]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[soft_limit_exceeded]"
		cachedCodepage="1252"
		cachedDataType="str"
		cachedLength="5"
		cachedName="soft_limit_exceeded"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_66]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[soft_limit_exceeded]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[bytes_protected]"
		cachedDataType="r8"
		cachedName="bytes_protected"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_67]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[bytes_protected]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[nummodfiles]"
		cachedDataType="r8"
		cachedName="nummodfiles"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_68]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[nummodfiles]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[pcntcommon]"
		cachedDataType="i4"
		cachedName="pcntcommon"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_69]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[pcntcommon]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[overhead]"
		cachedDataType="r8"
		cachedName="overhead"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_70]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[overhead]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[reduced]"
		cachedDataType="r8"
		cachedName="reduced"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_71]"
		lineageId="Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[reduced]" />
	<inputColumn
		refId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[avamar_source]"
		cachedDataType="wstr"
		cachedLength="20"
		cachedName="avamar_source"
		externalMetadataColumnId="Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[Param_72]"
		lineageId="Package\syd1-pb-ava01\Derived Column.Outputs[Derived Column Output].Columns[avamar_source]" />
</inputColumns>
';
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xml  

select *
into #temp
from OPENXML(@docHandle,'/inputColumns/inputColumn',1)
with (
	refId varchar(max)
	,cachedName varchar(max)
	,externalMetadataColumnId varchar(max)
	,lineageId VARCHAR(MAX)
) as t

EXEC sp_xml_removedocument @docHandle 


select replace(replace(refId,'Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].Columns[', ''),']','') as refID
	, cachedName
	, replace(replace(externalMetadataColumnId,'Package\syd1-pb-ava01\OLE DB Command.Inputs[OLE DB Command Input].ExternalColumns[', ''),']','') as externalMetadataColumnId
	, replace(replace(lineageId,'Package\syd1-pb-ava01\ODBC Source.Outputs[ODBC Source Output].Columns[', ''),']','') as lineageId
	, lineageId
from #temp
order by refID