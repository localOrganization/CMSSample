/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [CMSSampleDataID]
      ,[PageJson]
      ,[CMSSiteLookupID]
      ,[CMSTemplateTypeLookupID]
  FROM [CISOregon_Test].[dbo].[CMSSampleData]

declare @PageJson NVARCHAR(MAX) = (select pagejson from cms where cmsid = 232)

Insert into CMSSampleData (PageJson, CMSSiteLookupID, CMSTemplateTypeLookupID)
values (@PageJson, 117, 121)

select * from cms where cmssitelookupid = 117
select * from cms where cmsid = 232

 