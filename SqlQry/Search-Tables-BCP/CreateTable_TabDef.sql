USE [MatrixCare_NewSchema]
GO


DROP TABLE [dbo].[TabDef]
GO

CREATE TABLE [dbo].[TabDef]
(
	[TableName] [varchar](100) NOT NULL,
	[ColumnName] [varchar](100) NOT NULL,
	[DataType] [varchar](50) NULL,
	[ConstName] [varchar](50) NULL,
	[TableOrder] [int] NOT NULL,
	
	CONSTRAINT [IX_TabDef] UNIQUE NONCLUSTERED 
	(
		[TableName] ASC,
		[ColumnName] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


