USE [master]
GO
/****** Object:  Database [CMSSample]    Script Date: 9/6/2018 10:59:55 PM ******/
CREATE DATABASE [CMSSample]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CISOregon', FILENAME = N'C:\data\CMSSample.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
 LOG ON 
( NAME = N'CISOregon_log', FILENAME = N'C:\data\CMSSample_log.ldf' , SIZE = 5512KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [CMSSample] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [CMSSample].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [CMSSample] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [CMSSample] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [CMSSample] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [CMSSample] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [CMSSample] SET ARITHABORT OFF 
GO
ALTER DATABASE [CMSSample] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [CMSSample] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [CMSSample] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [CMSSample] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [CMSSample] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [CMSSample] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [CMSSample] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [CMSSample] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [CMSSample] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [CMSSample] SET  DISABLE_BROKER 
GO
ALTER DATABASE [CMSSample] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [CMSSample] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [CMSSample] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [CMSSample] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [CMSSample] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [CMSSample] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [CMSSample] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [CMSSample] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [CMSSample] SET  MULTI_USER 
GO
ALTER DATABASE [CMSSample] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [CMSSample] SET DB_CHAINING OFF 
GO
ALTER DATABASE [CMSSample] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [CMSSample] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [CMSSample] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'CMSSample', N'ON'
GO
ALTER DATABASE [CMSSample] SET QUERY_STORE = OFF
GO
USE [CMSSample]
GO
ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
USE [CMSSample]
GO
/****** Object:  User [SQLAdmin]    Script Date: 9/6/2018 10:59:56 PM ******/
CREATE USER [SQLAdmin] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [CCISERVICES\ciscoad]    Script Date: 9/6/2018 10:59:56 PM ******/
CREATE USER [CCISERVICES\ciscoad] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [SQLAdmin]
GO
/****** Object:  UserDefinedFunction [dbo].[ConvertUtcToPacific]    Script Date: 9/6/2018 10:59:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ben Funkhouser
-- Create date: 4/8/2016
-- =============================================
CREATE FUNCTION [dbo].[ConvertUtcToPacific] 
(
	@TimeUtc datetime
)
RETURNS datetime
AS
BEGIN
	return DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @TimeUtc)
END

GO
/****** Object:  Table [dbo].[ELMAH_Error]    Script Date: 9/6/2018 10:59:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ELMAH_Error](
	[ErrorId] [uniqueidentifier] NOT NULL,
	[Application] [nvarchar](60) NOT NULL,
	[Host] [nvarchar](50) NOT NULL,
	[Type] [nvarchar](100) NOT NULL,
	[Source] [nvarchar](60) NOT NULL,
	[Message] [nvarchar](500) NOT NULL,
	[User] [nvarchar](50) NOT NULL,
	[StatusCode] [int] NOT NULL,
	[TimeUtc] [datetime] NOT NULL,
	[Sequence] [int] IDENTITY(1,1) NOT NULL,
	[AllXml] [ntext] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwDistinctErrorsToday]    Script Date: 9/6/2018 10:59:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwDistinctErrorsToday]
AS
SELECT        Type, Source, Message, StatusCode
FROM            dbo.ELMAH_Error
WHERE        (dbo.ConvertUtcToPacific(TimeUtc) > CONVERT(DATE, GETDATE()))
GROUP BY Type, Source, Message, StatusCode

GO
/****** Object:  Table [dbo].[Lookup]    Script Date: 9/6/2018 10:59:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lookup](
	[LookupID] [int] IDENTITY(1,1) NOT NULL,
	[LookupTypeID] [int] NOT NULL,
	[LookupName] [nvarchar](50) NOT NULL,
	[LookupDescription] [nvarchar](255) NULL,
 CONSTRAINT [PK_Lookup] PRIMARY KEY CLUSTERED 
(
	[LookupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwLog]    Script Date: 9/6/2018 10:59:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/


CREATE View [dbo].[vwLog]
as
SELECT u.UserName, lt.LookupDescription, [Message], LoggedOnUTC
  FROM [Log] l Left outer join
  [User] u on l.UserID = u.UserID inner join 
  [Lookup] lt on l.LogTypeLookupID = lt.LookupID 
  --where lt.LookupDescription like '%search%'
  
GO
/****** Object:  Table [dbo].[LookupType]    Script Date: 9/6/2018 10:59:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LookupType](
	[LookupTypeID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
 CONSTRAINT [PK_LookupType] PRIMARY KEY CLUSTERED 
(
	[LookupTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwLookups]    Script Date: 9/6/2018 10:59:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vwLookups]
AS
SELECT TOP (100) PERCENT lt.NAME AS LookupTypeName
	,l.LookupTypeID
	,l.LookupID
	,l.LookupName
	,l.LookupDescription
FROM dbo.Lookup AS l
INNER JOIN dbo.LookupType AS lt ON lt.LookupTypeID = l.LookupTypeID


GO
/****** Object:  Table [dbo].[LookupAssociation]    Script Date: 9/6/2018 10:59:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LookupAssociation](
	[LookupAssociationID] [int] IDENTITY(1,1) NOT NULL,
	[ParentLookupID] [int] NOT NULL,
	[ChildLookupID] [int] NOT NULL,
 CONSTRAINT [PK_LookupAssociation] PRIMARY KEY CLUSTERED 
(
	[LookupAssociationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwLookupAssociations]    Script Date: 9/6/2018 10:59:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vwLookupAssociations]
AS
SELECT TOP (100) PERCENT plt.NAME AS ParentLookupTypeName
	,plt.LookupTypeID as ParentLookupTypeID 
	,lp.LookupID as ParentLookupID
	,lp.LookupName as ParentLookupName
	,lp.LookupDescription as ParentLookupDescription
	,clt.NAME AS ChildLookupTypeName
	,clt.LookupTypeID as ChildLookupTypeID 
	,lc.LookupID as ChildLookupID
	,lc.LookupName as ChildLookupName
	,lc.LookupDescription as ChildLookupDescription

FROM dbo.Lookup AS lc inner join
dbo.LookupAssociation la on lc.LookupID = la.ChildLookupID inner join
dbo.Lookup as lp on la.ParentLookupID = lp.LookupID 
INNER JOIN dbo.LookupType AS plt ON lp.LookupTypeID = plt.LookupTypeID
INNER JOIN dbo.LookupType as clt on lc.LookupTypeID = clt.LookupTypeID


GO
/****** Object:  Table [dbo].[CMS]    Script Date: 9/6/2018 10:59:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS](
	[CMSID] [int] IDENTITY(1,1) NOT NULL,
	[PageName] [nvarchar](500) NULL,
	[Slug] [nvarchar](500) NULL,
	[IncludeInNav] [char](1) NULL,
	[PageJson] [nvarchar](max) NULL,
	[DateUpdated] [datetime] NULL,
	[AppActionsJson] [nvarchar](max) NULL,
	[IsLive] [char](1) NULL,
	[CMSSiteLookupID] [int] NULL,
	[CMSTemplateTypeLookupID] [int] NULL,
 CONSTRAINT [PK_ContentManagementSystem] PRIMARY KEY CLUSTERED 
(
	[CMSID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CMSSampleData]    Script Date: 9/6/2018 10:59:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSSampleData](
	[CMSSampleDataID] [int] IDENTITY(1,1) NOT NULL,
	[PageJson] [nvarchar](max) NOT NULL,
	[CMSSiteLookupID] [int] NULL,
	[CMSTemplateTypeLookupID] [int] NULL,
 CONSTRAINT [PK_CMSSampleData] PRIMARY KEY CLUSTERED 
(
	[CMSSampleDataID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CMSSiteTemplateType]    Script Date: 9/6/2018 10:59:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMSSiteTemplateType](
	[CMSSiteTemplateTypeID] [int] IDENTITY(1,1) NOT NULL,
	[CMSSiteLookupID] [int] NOT NULL,
	[CMSTemplateTypeLookupID] [int] NOT NULL,
 CONSTRAINT [PK_CMSSiteTemplateType] PRIMARY KEY CLUSTERED 
(
	[CMSSiteTemplateTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[JsonDataSource]    Script Date: 9/6/2018 10:59:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JsonDataSource](
	[JsonDataSourceID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Data] [nvarchar](max) NULL,
 CONSTRAINT [PK_JsonDataSource] PRIMARY KEY CLUSTERED 
(
	[JsonDataSourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LookupLevel]    Script Date: 9/6/2018 10:59:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LookupLevel](
	[LookupLevelID] [int] IDENTITY(1,1) NOT NULL,
	[Level1LookupID] [int] NOT NULL,
	[Level2LookupID] [int] NOT NULL,
	[Level3LookupID] [int] NULL,
	[Level4LookupID] [int] NULL,
	[TempClaimNumber] [varchar](50) NULL,
 CONSTRAINT [PK_LookupLossCode] PRIMARY KEY CLUSTERED 
(
	[LookupLevelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[CMS] ON 
GO
INSERT [dbo].[CMS] ([CMSID], [PageName], [Slug], [IncludeInNav], [PageJson], [DateUpdated], [AppActionsJson], [IsLive], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (252, N'Enrollment Quick Guide', N'Tips', N'Y', N'{"SecondaryHeadline":"A Brand-New Enrollment System Requires a Brand-New Login!","Billboard":{"Headline":null,"Tagline":null,"Summary":null,"MediaEmbedCode":null,"Image":"839E847B5D8F4FA0BF7CC5617702ED2E","ImageFileName":"Helpful Tips.jpg","ImageHref":null,"IsActuallyAVideoLink":false,"IsLive":false},"CallToAction":{"Description":"Start the enrollment process!","LinkName":"Enroll Here","LinkHref":"https://www.cisbenefits.org/almost_there"},"MainPageHtml":"<div>\n<div>\n<div>&nbsp;</div>\n\n<div>\n<div>\n<div style=\"margin-left:6.0pt;\">\n<div>We have a new enrollment system, called Benefitsolver. Employees who have not accessed the new site (since July 1, 2017) are considered first-time users because they are on Benefitsolver for the first time.&nbsp;</div>\n</div>\n\n<div style=\"margin-left:6.0pt;\">&nbsp;</div>\n\n<div style=\"margin-left:6.0pt;\">EASY STEPS TO CREATE A LOGIN:</div>\n\n<ul>\n\t<li>Click on the &ldquo;Enroll Here&rdquo; button located at the top right hand side of the page.</li>\n\t<li>On the Benefitsolver &ldquo;Welcome&rdquo; page, click on the &ldquo;<strong>Register</strong>&rdquo; button</li>\n\t<li>Enter CIS in the company key box, if it isn&rsquo;t there already</li>\n\t<li>Enter your Social Security Number (SSN) and date of birth (DOB)</li>\n\t<li>Complete the create account process on the next page, following the onscreen instructions</li>\n</ul>\n\n<div>\n<div>NOTE:&nbsp; If you try to use to use your old username and password for cisbenefits you will not be recognized, and it will give an error message that says your login information entered is invalid and to contact your HR Administrator.&nbsp; Complete the steps above to remedy this error.</div>\n\n<div>&nbsp;</div>\n\n<div>If you get an error that your information cannot be verified, please contact your HR department so they can determine if your SSN or DOB was entered incorrectly for your record.</div>\n\n<div>&nbsp;</div>\n\n<h4><span style=\"color:#00a1aa;\">Start the enrollment process and </span><u><a href=\"https://www.cisbenefits.org/almost_there\"><span style=\"color:#00a1aa;\">CLICK HERE</span></a><span style=\"color:#00a1aa;\">!</span></u></h4>\n\n<div>&nbsp;</div>\n</div>\n</div>\n<br clear=\"all\" />\n&nbsp;</div>\n</div>\n</div>\n","SmallInfoBox":{"Headline":"Need help?","Body":"<div>https://Please contact the <strong>CIS Benefits</strong> department.</div>\n\n<div><a href=\"tel:1-855-763-3829 \"><span class=\"glyphicon glyphicon-phone margin-right-halfem\"></span>&nbsp;1-855-763-3829 </a></div>\n\n<div><a href=\"mailto:employeebenefits@cisoregon.org\"><span class=\"glyphicon glyphicon-envelope margin-right-halfem\"></span>&nbsp;Employee Benefits</a></div>\n","Downloads":[]},"FBFeedIsVisible":"N","CustomAction":null,"PageName":"Enrollment Quick Guide","ExcludeFromBreadCrumbs":false,"CMSHelp":null}', CAST(N'2017-10-09T02:54:58.447' AS DateTime), N'null', N'Y', 116, 119)
GO
INSERT [dbo].[CMS] ([CMSID], [PageName], [Slug], [IncludeInNav], [PageJson], [DateUpdated], [AppActionsJson], [IsLive], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (254, N'Your Benefits, Discovered', N'home', N'N', N'{"PublicAnnouncement":{"HeadlineName":"Get to know the CIS difference","HeadlineSrc":"https://www.cisbenefits.org/Tips","ImageID":null,"ImageFileName":null,"Description":"Welcome to the new cisbenefits.org.  We know you may have questions about your employee benefit choices. We''re here to help you understand the benefits available to you and your family.","IsLive":null,"OpenInNewTab":false},"Billboard":{"Headline":null,"Tagline":null,"Summary":null,"MediaEmbedCode":"<iframe src=\"https://player.vimeo.com/video/23541008\" width=\"640\" height=\"472\" frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe> <p><a href=\"https://vimeo.com/23541008\">CIS Benefits and Healthy Benefits</a> from <a href=\"https://vimeo.com/cisoregon\">CIS Oregon</a> on <a href=\"https://vimeo.com\">Vimeo</a>.</p>","Image":"E8D4742DEAE04F4F8DE97F16E88402C","ImageFileName":"OE Image for Website.png","ImageHref":"https://www.cisbenefits.org/almost_there","IsActuallyAVideoLink":false,"IsLive":false},"SectionHighlights":[{"HeadlineName":"New Hires-Getting Started","HeadlineSrc":"http://www.cisbenefits.org/newhires","ImageID":"C1C553D728E54280A5D69F4616398154","ImageFileName":"Hello I Am New","Description":"We want your enrollment to be easy and worry free.  We’ve created instructions to make it easy for you to walk through the enrollment process.","IsLive":null,"OpenInNewTab":false},{"HeadlineName":"Already Enrolled?","HeadlineSrc":"http://www.cisbenefits.org/change","ImageID":"5D0D4B4B2C8343D6ADF479FD6440B368","ImageFileName":"Enrolled","Description":"You''re already enrolled and want to review or make a change.","IsLive":null,"OpenInNewTab":false},{"HeadlineName":"Wellness","HeadlineSrc":"/Wellness","ImageID":"055F7B420B01495CAB239671F2A4A78E","ImageFileName":"Road Trip.jpg","Description":"We''re here to help you maintain a healthy weight, eat better, be more physically active, and reduce stress","IsLive":null,"OpenInNewTab":false},{"HeadlineName":"Privacy Notices","HeadlineSrc":"https://www.cisoregon.org/dl/6aVl9wui","ImageID":"845F18D091334334948444EB4B80CB60","ImageFileName":"Privacy.jpg","Description":"There are federal regulations governing protected health information for group health plans and other covered entities. It''s important that we describe how your medical information may be used and disclosed - as well as how you can access this information.","IsLive":null,"OpenInNewTab":false}],"CallToAction":{"Description":"CIS offers a full range of benefits to keep you and your family healthy.","LinkName":"Enroll Here","LinkHref":"https://www2.benefitsolver.com/benefits/BenefitSolverView?page_name=signon&co_num=15671&co_affid=citycountyinsurance"},"LinkButton":{"LinkName":"ENROLL/UPDATE HERE","LinkSrc":"https://www2.benefitsolver.com/benefits/BenefitSolverView?page_name=signon&co_num=15671&co_affid=citycountyinsurance","LinkFileName":null,"IsSubLevel":false},"QuickLinksHeading":{"LinkName":"Resources for You","LinkSrc":null,"LinkFileName":null,"IsSubLevel":false},"QuickLinks":[{"LinkName":"Regence BlueCross Blue Shield","LinkSrc":"https://www.regence.com","LinkFileName":null,"IsSubLevel":false},{"LinkName":"MDLive","LinkSrc":"https://welcome.mdlive.com/","LinkFileName":null,"IsSubLevel":true},{"LinkName":"VSP","LinkSrc":"https://www.vsp.com/","LinkFileName":null,"IsSubLevel":true},{"LinkName":"Advantages Discounts","LinkSrc":"https://www.regence.com/web/regence_individual/advantages-discounts","LinkFileName":null,"IsSubLevel":true},{"LinkName":"Delta Dental","LinkSrc":"https://www.modahealth.com/members/index.shtml","LinkFileName":null,"IsSubLevel":false},{"LinkName":"Kaiser Permanente","LinkSrc":"https://healthy.kaiserpermanente.org/","LinkFileName":null,"IsSubLevel":false},{"LinkName":"Willamette Dental","LinkSrc":"https://www.willamettedental.com/","LinkFileName":null,"IsSubLevel":false},{"LinkName":"EAP - Deer Oaks","LinkSrc":"https://www.deeroakseap.com/","LinkFileName":null,"IsSubLevel":false}],"SmallInfoBox":{"Headline":"Enroll today!","Body":"<div><strong>CLICK <a href=\"https://www2.benefitsolver.com/benefits/BenefitSolverView?page_name=signon&amp;co_num=15671&amp;co_affid=citycountyinsurance\"><u>HERE</u></a> TO&nbsp;REGISTER</strong>&nbsp;</div>\n\n<div>&nbsp;</div>\n\n<div><strong>Need help?</strong></div>\n\n<div>Please contact the<a href=\"mailto:employeebenefits@cisoregon.org\"><strong> CIS Benefits </strong></a>department at 1-855-763-3829.</div>\n","Downloads":[]},"PageName":"Your Benefits, Discovered","ExcludeFromBreadCrumbs":false,"CMSHelp":null}', CAST(N'2018-01-04T20:03:24.087' AS DateTime), N'null', N'Y', 116, 118)
GO
INSERT [dbo].[CMS] ([CMSID], [PageName], [Slug], [IncludeInNav], [PageJson], [DateUpdated], [AppActionsJson], [IsLive], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (255, N'Wellness Resources', N'Wellness', N'Y', N'{"SecondaryHeadline":"Resources for you to use at your convenience!","Billboard":{"Headline":null,"Tagline":null,"Summary":null,"MediaEmbedCode":null,"Image":"A0F02BD2CDC242A4BE414CF915992213","ImageFileName":"Wellness Sign","ImageHref":null,"IsActuallyAVideoLink":false,"IsLive":false},"CallToAction":{"Description":"Login to access even more resources.","LinkName":"Login","LinkHref":"https://www.benefitsolver.com"},"MainPageHtml":"<div>\n<div>\n<div>&nbsp;</div>\n\n<div>CIS focuses on health improvement/wellness in the workplace,&nbsp;and on assistance for individual employees and their families. Wellness resources availble to members and their employees include:</div>\n\n<div>&nbsp;</div>\n\n<div>\n<div>\n<div>\n<ul>\n\t<li><u><a href=\"https://www.cisbenefits.org/Wellness/Weight\"><span style=\"color:#00a1aa;\">Healthy Eating &amp; Weight Management Programs</span></a></u></li>\n\t<li><u><a href=\"https://www.cisbenefits.org/Wellness/EAP\"><span style=\"color:#00a1aa;\">Employee Assistance Program</span></a></u></li>\n\t<li>hubbub\n\t<ul>\n\t\t<li><u><a href=\"https://www.cisoregon.org/dl/U6hVCkkc\"><span style=\"color:#00a1aa;\">Regence members</span></a></u></li>\n\t\t<li><u><a href=\"https://www.cisoregon.org/dl/4Q7EfX4R\"><span style=\"color:#00a1aa;\">Kaiser members</span></a></u></li>\n\t</ul>\n\t</li>\n</ul>\n</div>\n</div>\n</div>\n</div>\n</div>\n","SmallInfoBox":{"Headline":"Need help?","Body":"<div>Please contact the <strong><a href=\"mailto:healthybenefits@cisoregon.org?subject=Wellness Resources\">CIS Benefits</a></strong> department.</div>\n","Downloads":[]},"FBFeedIsVisible":"Y","CustomAction":null,"PageName":"Wellness Resources","ExcludeFromBreadCrumbs":false,"CMSHelp":null}', CAST(N'2018-01-04T20:05:00.543' AS DateTime), N'null', N'Y', 116, 119)
GO
INSERT [dbo].[CMS] ([CMSID], [PageName], [Slug], [IncludeInNav], [PageJson], [DateUpdated], [AppActionsJson], [IsLive], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (256, N'Employee Assistance Program ', N'Wellness/EAP', N'Y', N'{"SecondaryHeadline":"Deer Oaks","Billboard":{"Headline":null,"Tagline":null,"Summary":null,"MediaEmbedCode":null,"Image":null,"ImageFileName":null,"ImageHref":null,"IsActuallyAVideoLink":false,"IsLive":false},"CallToAction":null,"MainPageHtml":"<p>Call to request services. Crisis support is available 24 hours a day: <strong>888-993-7650 or visit <a href=\"https://www.deeroakseap.com\">www.deeroakseap.com</a></strong><strong>. Under the Member Login tab, enter Oregon as your username and password.&nbsp; </strong></p>\n\n<p>The EAP provides services to help people privately resolve problems that may interfere with work, family, and life.&nbsp; <strong>If you are experiencing a serious crisis, are thinking about harming yourself or others, you deserve to get help sooner rather than later. If you are experiencing intense emotional distress, call us at 888-993-7650, call 911 or go to your local hospital emergency room.</strong></p>\n\n<h3 style=\"font-style: normal;\"><span style=\"color:#00a1aa;\">Counseling - 8 FREE sessions</span></h3>\n\n<ul>\n\t<li>\n\t<p><strong>24-hour Crisis Help </strong>- Toll-free access for you or a family member experiencing a crisis: 888-993-7650</p>\n\t</li>\n\t<li>\n\t<p><strong>Confidential Counseling </strong>- Face-to-face counseling sessions for each new issue, including family, relationships, stress, anxiety, and other common challenges. Call 888-993-7650 <strong>to get started with the 8 free visits available to you or anyone living in your home.</strong></p>\n\t</li>\n\t<li>\n\t<p><strong>Take the High Road </strong>- Deer Oaks reimburses eligible employees and their dependents for cab fare (up to $45) in the event that they are incapacitated due to impairment by a substance or extreme emotional condition.&nbsp;</p>\n\t</li>\n</ul>\n\n<h3 style=\"font-style: normal;\"><span style=\"color:#00a1aa;\">Life Balance</span></h3>\n\n<ul>\n\t<li>\n\t<p><strong>Online Seminars</strong> - Online seminars are an interative learning experience you can view at your own convenience.</p>\n\t</li>\n\t<li>\n\t<p><strong>Identity Theft Services</strong> - Support in planning the recovery process for restoring your identity and credit after an incident.</p>\n\t</li>\n\t<li>\n\t<p><strong>Will Preparation</strong> - Easily create a simple, state-specific will at no cost to you. <a href=\"https://www.advantageengagement.com/centers_redirect.php?id_division=25&amp;name_division=Centers&amp;id_module=m9075&amp;name_module=NOLO&amp;id_element=295&amp;name_element=NOLO&amp;url=http://www.nolo.com/products/online-will-nnwill.html\">This service </a>is provided through our partner Nolo, a leader in do-it-yourself legal forms since 1980. Enter the &quot;Coupon Code&quot; of 1601 on the &quot;Checkout&quot; screen after clicking on &quot;Start Now.&quot;</p>\n\t</li>\n</ul>\n\n<p>There are <strong><a href=\"https://www.cisoregon.org/dl/vFhc9ri3\">many more services </a></strong>are available to you at minimal to no-cost.&nbsp;</p>\n\n<h3><span style=\"color:#00a1aa;\">Contact Deer Oaks EAP Services</span></h3>\n\n<div><a href=\"tel:888-993-7650\"><span class=\"glyphicon glyphicon-phone margin-right-halfem\"></span><u>&nbsp;888-993-7650</u></a></div>\n\n<div><a href=\"mailto:eap@deeroaks.com\"><span class=\"glyphicon glyphicon-envelope margin-right-halfem\"></span><u>&nbsp;eap@deeroaks.com</u></a></div>\n\n<div><a href=\"https://www.deeroakseap.com/\"><span class=\"glyphicon glyphicon-globe margin-right-halfem\"></span><u>&nbsp;www.deeroakseap.com</u></a></div>\n\n<ul>\n\t<li>Username &amp; password: Oregon</li>\n</ul>\n\n<div>\n<p>Deer Oaks provides monthly newsletters. Please see below for past newsletters:</p>\n\n<ul>\n\t<li><a href=\"https://www.advantageengagement.com/1601/docs/January%202018%20Employee%20Newsletter.pdf\"><u><font color=\"#0066cc\">Jan. 2018 Employee Newsletter</font></u></a></li>\n</ul>\n\n<div>&nbsp;</div>\n</div>\n","SmallInfoBox":{"Headline":"Need help?","Body":"<div>Please contact the <strong><a href=\"mailto:Wellness Resources?subject=employeebenefits%40cisoregon.org\">CIS Benefits</a></strong> department.</div>\n","Downloads":[]},"FBFeedIsVisible":"N","CustomAction":null,"PageName":"Employee Assistance Program ","ExcludeFromBreadCrumbs":false,"CMSHelp":null}', CAST(N'2018-01-05T00:16:28.567' AS DateTime), N'null', N'Y', 116, 119)
GO
INSERT [dbo].[CMS] ([CMSID], [PageName], [Slug], [IncludeInNav], [PageJson], [DateUpdated], [AppActionsJson], [IsLive], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (257, N'Healthy Eating & Weight Management', N'Wellness/Weight', N'Y', N'{"SecondaryHeadline":null,"Billboard":{"Headline":null,"Tagline":null,"Summary":null,"MediaEmbedCode":null,"Image":null,"ImageFileName":null,"ImageHref":null,"IsActuallyAVideoLink":false},"CallToAction":null,"MainPageHtml":"<div>\n<h1>&nbsp;</h1>\n\n<p>CIS Benefits offers programs for <a href=\"https://www.cisoregon.org/dl/Pa2Z3SmV\"><span style=\"color:#00A3E0;\"><u>healthy eating and weight management</u></span></a><span style=\"color:#00A3E0;\">.</span></p>\n\n<h3><span style=\"color:#00a1aa;\">General Program Eligibility Includes:</span></h3>\n\n<ul>\n\t<li>\n\t<p>Must be covered by a CIS medical plan (employee and/or covered dependent)</p>\n\t</li>\n\t<li>\n\t<p>Must be 18 or older</p>\n\t</li>\n</ul>\n\n<h3><span style=\"color:#00a1aa;\">Reimbursement Programs:</span></h3>\n\n<ul>\n\t<li>\n\t<p>Receive 70% reimbursement of program costs up to a maximum of $400 per calendar year</p>\n\t</li>\n\t<li>\n\t<p>Must demonstrate regular program participation (e.g. attend at least 70% of weekly meetings)</p>\n\t</li>\n\t<li>\n\t<p><strong>Reimbursement is not available for electronic tracking devices or monthly monitoring fees</strong></p>\n\t</li>\n\t<li>\n\t<p>Submit a <a href=\"https://www.cisoregon.org/dl/X9vyWaJe\" target=\"_blank\"><u><span style=\"color:#00A3E0;\">Reimbursement Form</span> </u></a>at the end of your program sequence</p>\n\t</li>\n</ul>\n\n<h3><span style=\"color:#00a1aa;\">Program Options:</span></h3>\n\n<ol>\n\t<li>\n\t<p>Weight Watchers&reg; (Community/At-Work meetings, Online)</p>\n\t</li>\n\t<li>\n\t<p>Community, hospital, or clinic based programs (requires prior CIS approval)</p>\n\t</li>\n</ol>\n\n<ul>\n\t<li>\n\t<p>Programs must promote eating &ldquo;regular&rdquo; food, stress physical activity, encourage food tracking, be educational in nature, and recognize other factors that influence weight such as stress, genetics, emotions, etc.</p>\n\t</li>\n\t<li>\n\t<p>Questions: Email <a href=\"mailto:healthybenefits@cisoregon.org\"><span style=\"color:#00A3E0;\"><u>hmatthews@cisoregon.org</u></span></a></p>\n\t</li>\n</ul>\n\n<p>&nbsp;</p>\n</div>\n","SmallInfoBox":{"Headline":"Need help?","Body":"<div>Please contact the <strong><a href=\"mailto:Wellness Resources?subject=employeebenefits%40cisoregon.org\">CIS Benefits</a></strong> department.</div>\n","Downloads":[]},"FBFeedIsVisible":"N","PageName":"Healthy Eating & Weight Management","ExcludeFromBreadCrumbs":false,"CMSHelp":null}', CAST(N'2017-07-03T22:20:57.637' AS DateTime), N'null', N'Y', 116, 119)
GO
INSERT [dbo].[CMS] ([CMSID], [PageName], [Slug], [IncludeInNav], [PageJson], [DateUpdated], [AppActionsJson], [IsLive], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (258, N'Welcome New Hires-Getting Started', N'newhires', N'N', N'{"SecondaryHeadline":"We know there’s a lot to go through as a new hire — and it can feel overwhelming. We’re here to help you and your family every step of the way. ","Billboard":{"Headline":null,"Tagline":null,"Summary":null,"MediaEmbedCode":null,"Image":null,"ImageFileName":null,"ImageHref":null,"IsActuallyAVideoLink":false},"CallToAction":{"Description":"Ready to get started?","LinkName":"ENROLL HERE","LinkHref":"https://www2.benefitsolver.com/benefits/BenefitSolverView?page_name=signon&co_num=15671&co_affid=citycountyinsurance"},"MainPageHtml":"<h5>First, check out our helpful hints! We&#39;ve created instructions for you. Once you&#39;re ready to enroll, <strong><a href=\"https://www2.benefitsolver.com/benefits/BenefitSolverView?page_name=signon&amp;co_num=15671&amp;co_affid=citycountyinsurance\">click here</a></strong>.</h5>\n\n<ul>\n\t<li><a href=\"https://www.cisoregon.org/dl/7tHzPeOs\">New Hires - Helpful Hints Before You Get Started</a></li>\n\t<li><a href=\"https://www.cisoregon.org/dl/EP1L0iP1\">Instructions for New Hires</a></li>\n\t<li><a href=\"https://www.cisoregon.org/dl/S7vISG2z\">Flexible Spending Account Enrollment Form</a></li>\n</ul>\n","SmallInfoBox":{"Headline":"Need help?","Body":"<div>Please contact the CIS Benefits department.</div>\n\n<div><a href=\"tel:855-763-3829\"><span class=\"glyphicon glyphicon-phone margin-right-halfem\"></span>&nbsp;855-763-3829</a></div>\n\n<div><a href=\"mailto:EmployeeBenefits@cisoregon.org\"><span class=\"glyphicon glyphicon-envelope margin-right-halfem\"></span>&nbsp;Email</a></div>\n","Downloads":[]},"FBFeedIsVisible":"N","PageName":"Welcome New Hires-Getting Started","ExcludeFromBreadCrumbs":false,"CMSHelp":null}', CAST(N'2017-07-06T17:10:08.613' AS DateTime), N'null', N'Y', 116, 119)
GO
INSERT [dbo].[CMS] ([CMSID], [PageName], [Slug], [IncludeInNav], [PageJson], [DateUpdated], [AppActionsJson], [IsLive], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (259, N'Already enrolled?', N'change', N'N', N'{"SecondaryHeadline":"You''re already enrolled and want to review or make a change","Billboard":{"Headline":null,"Tagline":null,"Summary":null,"MediaEmbedCode":null,"Image":null,"ImageFileName":null,"ImageHref":null,"IsActuallyAVideoLink":false},"CallToAction":{"Description":"Ready to get started?","LinkName":"ENROLL HERE","LinkHref":"https://www2.benefitsolver.com/benefits/BenefitSolverView?page_name=signon&co_num=15671&co_affid=citycountyinsurance"},"MainPageHtml":"<h5>To make mid-year changes (e.g., update personal info, marriage, birth, etc.)&nbsp;<strong><a href=\"https://www2.benefitsolver.com/benefits/BenefitSolverView?page_name=signon&amp;co_num=15671&amp;co_affid=citycountyinsurance\">click here</a></strong>. If you need to make a change to your flexible spending account (FSA), use the form below.</h5>\n\n<ul>\n\t<li><a href=\"https://www.cisoregon.org/dl/BhIjUjtZ\">FSA Change Form</a></li>\n\t<li><a href=\"https://www.cisoregon.org/dl/qvbOzbJA\">Quick Guide - Access, View, and Make Changes to Your Benefits</a></li>\n</ul>\n","SmallInfoBox":{"Headline":"Need help?","Body":"<div>Please contact the CIS Benefits department.</div>\n\n<div><a href=\"tel:855-763-3829\"><span class=\"glyphicon glyphicon-phone margin-right-halfem\"></span>&nbsp;855-763-3829</a></div>\n\n<div><a href=\"mailto:EmployeeBenefits@cisoregon.org\"><span class=\"glyphicon glyphicon-envelope margin-right-halfem\"></span>&nbsp;Email</a></div>\n","Downloads":[]},"FBFeedIsVisible":"N","CustomAction":null,"PageName":"Already enrolled?","ExcludeFromBreadCrumbs":false,"CMSHelp":null}', CAST(N'2017-09-06T15:55:52.490' AS DateTime), N'null', N'Y', 116, 119)
GO
INSERT [dbo].[CMS] ([CMSID], [PageName], [Slug], [IncludeInNav], [PageJson], [DateUpdated], [AppActionsJson], [IsLive], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (262, N'Wellness Works', N'wellness/publications/wellness-works', N'Y', N'{"SecondaryHeadline":"WELLNESS TOPICS OF INTEREST TO CIS BENEFITS MEMBERS","Billboard":{"Headline":null,"Tagline":null,"Summary":null,"MediaEmbedCode":null,"Image":null,"ImageFileName":null,"ImageHref":null,"IsActuallyAVideoLink":false},"CallToAction":null,"MainPageHtml":null,"SmallInfoBox":{"Headline":"Have questions?","Body":"<div>Please contact the CIS Benefits department.&nbsp;</div>\n\n<div><a href=\"tel:855-763-3829\"><span class=\"glyphicon glyphicon-phone margin-right-halfem\"></span>&nbsp;855-763-3829</a></div>\n\n<div><a href=\"mailto:EmployeeBenefits@cisoregon.org\"><span class=\"glyphicon glyphicon-envelope margin-right-halfem\"></span>&nbsp;Email</a></div>\n","Downloads":null},"FBFeedIsVisible":"N","CustomAction":{"View":"Publications","ViewModel":"PublicationsViewModel","ConfigString":"?publication=Wellness Works&repository=IDocumentManagementRepository"},"PageName":"Wellness Works","ExcludeFromBreadCrumbs":false,"CMSHelp":null}', CAST(N'2017-08-03T14:50:38.580' AS DateTime), NULL, N'Y', 116, 119)
GO
INSERT [dbo].[CMS] ([CMSID], [PageName], [Slug], [IncludeInNav], [PageJson], [DateUpdated], [AppActionsJson], [IsLive], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (263, N'Benefit Connections', N'wellness/publications/benefit-connections', N'Y', N'{"SecondaryHeadline":"A publication to help you and your family fully understand the wide range of benefits/services included in your insurance plans","Billboard":{"Headline":null,"Tagline":null,"Summary":null,"MediaEmbedCode":null,"Image":null,"ImageFileName":null,"ImageHref":null,"IsActuallyAVideoLink":false},"CallToAction":null,"MainPageHtml":null,"SmallInfoBox":{"Headline":"Have questions?","Body":"<div>Please contact the CIS Benefits department.&nbsp;</div>\n\n<div><a href=\"tel:855-763-3829\"><span class=\"glyphicon glyphicon-phone margin-right-halfem\"></span>&nbsp;855-763-3829</a></div>\n\n<div><a href=\"mailto:EmployeeBenefits@cisoregon.org\"><span class=\"glyphicon glyphicon-envelope margin-right-halfem\"></span>&nbsp;Email</a></div>\n","Downloads":null},"FBFeedIsVisible":"N","CustomAction":{"View":"Publications","ViewModel":"PublicationsViewModel","ConfigString":"?publication=Benefit Connections&repository=IDocumentManagementRepository"},"PageName":"Benefit Connections","ExcludeFromBreadCrumbs":false,"CMSHelp":null}', CAST(N'2017-08-03T14:52:42.010' AS DateTime), NULL, N'Y', 116, 119)
GO
INSERT [dbo].[CMS] ([CMSID], [PageName], [Slug], [IncludeInNav], [PageJson], [DateUpdated], [AppActionsJson], [IsLive], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (266, N'Browser Requirements', N'browser', N'N', N'{"RedirectUrl":"https://www.cisoregon.org/dl/nNjsv2eo","PageName":"Browser Requirements","ExcludeFromBreadCrumbs":false,"CMSHelp":null}', CAST(N'2017-09-11T16:00:45.570' AS DateTime), N'null', N'Y', 116, 106)
GO
INSERT [dbo].[CMS] ([CMSID], [PageName], [Slug], [IncludeInNav], [PageJson], [DateUpdated], [AppActionsJson], [IsLive], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (272, N'Open Enrollment - Almost There!', N'almost_there', N'N', N'{"SecondaryHeadline":"Read this important information before enrolling","Billboard":{"Headline":null,"Tagline":null,"Summary":null,"MediaEmbedCode":null,"Image":"60FA5AEBEE514A51868DEF2D11B050BD","ImageFileName":"Important Info.jpg","ImageHref":"https://www2.benefitsolver.com/benefits/BenefitSolverView?page_name=signon&co_num=15671&co_affid=citycountyinsurance","IsActuallyAVideoLink":false,"IsLive":false},"CallToAction":null,"MainPageHtml":null,"SmallInfoBox":{"Headline":"Need Help?","Body":"<div>\n<div>Please contact the CIS Benefits department.</div>\n\n<div><a href=\"tel:855-763-3829\"><span class=\"glyphicon glyphicon-phone margin-right-halfem\"></span>&nbsp;855-763-3829</a></div>\n\n<div><a href=\"mailto:EmployeeBenefits@cisoregon.org\"><span class=\"glyphicon glyphicon-envelope margin-right-halfem\"></span>&nbsp;Email</a></div>\n</div>\n","Downloads":null},"FBFeedIsVisible":"N","CustomAction":null,"PageName":"Open Enrollment - Almost There!","ExcludeFromBreadCrumbs":false,"CMSHelp":null}', CAST(N'2017-10-05T00:36:30.357' AS DateTime), N'null', N'Y', 116, 119)
GO
INSERT [dbo].[CMS] ([CMSID], [PageName], [Slug], [IncludeInNav], [PageJson], [DateUpdated], [AppActionsJson], [IsLive], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (276, N'Employee Assistance Program', N'EAP', N'N', N'{"RedirectUrl":"https://www.cisoregon.org/dl/vFhc9ri3","PageName":"Employee Assistance Program","ExcludeFromBreadCrumbs":false,"CMSHelp":null}', CAST(N'2018-01-03T20:54:16.870' AS DateTime), N'null', N'Y', 116, 106)
GO
SET IDENTITY_INSERT [dbo].[CMS] OFF
GO
SET IDENTITY_INSERT [dbo].[CMSSampleData] ON 
GO
INSERT [dbo].[CMSSampleData] ([CMSSampleDataID], [PageJson], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (1, N'{"Billboard":{"Headline":"Property & Liability","Tagline":"Tagline goes here","Summary":"Testing summary paragraph.","MediaEmbedCode":"<iframe src=\"https://player.vimeo.com/video/20896493?color=1078a1\" width=\"500\" height=\"369\" frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>","Image":null,"ImageFileName":null},"QuickLinks":[{"LinkName":"Coverage","LinkSrc":"onemore","LinkFileName":null},{"LinkName":"Services","LinkSrc":"one more url","LinkFileName":null},{"LinkName":"TULIP","LinkSrc":"hey","LinkFileName":null},{"LinkName":"OPEEP","LinkSrc":null,"LinkFileName":null}],"ImageBoxes":[{"Heading":"Coverage","Image":"http://www.cisoregon.org/dl/5EGy1XIK","ImageFileName":null,"Link":"/PropertyLiability/Coverage"},{"Heading":"Services","Image":"http://www.cisoregon.org/dl/UOBKCW23","ImageFileName":null,"Link":"/PropertyLiability/Services"},{"Heading":"TULIP","Image":"http://www.cisoregon.org/dl/jjphxhIA","ImageFileName":null,"Link":"/PropertyLiability/TULIP"},{"Heading":"OPEEP","Image":"http://www.cisoregon.org/dl/DUlSvnIZ","ImageFileName":null,"Link":"/PropertyLiability/OPEEP"}],"CallToAction":{"Description":"test","LinkName":"test","LinkHref":"test"},"QuickLinksHeading":"CIS provides insuracne morbi leo risus, portra ac consectetur ac vestibul onec","QuickLinksFooter":"Learn more at <a href=\"www.cisbenefits.org\">CISBenefits.org</a>","PageSummary":"<div><div><div><strong>Kitty ipsum dolor sit amet</strong>, iaculis run bat biting sleep in the sink, adipiscing claw sleep in the sink scratched egestas lay down in your way nunc. Sniff consectetur rutrum vehicula give me fish stretching, orci turpis rhoncus attack your ankles vel accumsan nam. Et in viverra vulputate libero nullam enim ut, lay down in your way dolor chuf faucibus enim ut. Nunc zzz ac quis catnip give me fish, lay down in your way egestas faucibus neque sollicitudin accumsan. Feed me cras nec stretching sagittis in viverra, suscipit neque neque tincidunt a toss the mousie. Suscipit amet vel jump, claw sleep on your keyboard fluffy fur toss the mousie pharetra nam.</div><div>&nbsp;</div><div>Tempus scratched amet claw, accumsan mauris a lay down in your way puking ac accumsan vulputate in viverra. <span style=\"background-color:#FFFF00\">Sleep on your face sunbathe tristique consectetur nam, leap</span> attack enim sleep in the sink puking purr sagittis. Faucibus accumsan iaculis sleep in the sink ac lay down in your way, amet suspendisse shed everywhere adipiscing fluffy fur sniff. Chase the red dot neque eat the grass nullam leap nunc, lick quis libero quis nunc lay down in your way tempus. Justo quis eat the grass tristique, etiam justo enim nibh catnip sleep in the sink. Sagittis pharetra kittens feed me pharetra tail flick, stuck in a tree lay down in your way neque puking ac.</div></div></div>","SecondaryHeadline":"Explore Property & Liability:","PageName":"Property & Liability","ExtendedHeaderHeight":"","DisplaySectionQuickLinks":false}', NULL, 99)
GO
INSERT [dbo].[CMSSampleData] ([CMSSampleDataID], [PageJson], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (2, N'{"Billboard":{"Headline":null,"Tagline":"The Benefits of CIS Benefits Coverage","Summary":null,"MediaEmbedCode":null,"Image":"FC125AFB2C81460CB1A6794F43D5A903","ImageFileName":"BenefitsCoverageLarge.jpg"},"MainPageText":"<div><div>Lucas ipsum dolor sit amet antilles jar jabba antilles antilles kessel calrissian hutt moff skywalker. Coruscant biggs hutt jabba. Windu jawa organa darth mon mandalorians organa. Sidious tatooine ackbar mara. Biggs fett lobot vader wampa hutt darth baba. Kamino obi-wan ventress gamorrean fett lando yavin. Mace ponda yoda alderaan windu yoda coruscant. Dagobah coruscant grievous hoth fett moff lando wampa. Organa mon twi&#39;lek mon hutt binks obi-wan wedge. Leia hutt obi-wan darth yoda ventress darth.</div><div>&nbsp;</div><div>Kessel aayla utapau jade luke moff utapau jade moff. Moff solo skywalker solo fett. Mon grievous chewbacca windu kenobi bothan baba r2-d2. Darth boba solo luke jango binks skywalker. Skywalker aayla ponda secura. Lars ben calamari dooku obi-wan vader. Hutt yoda skywalker dagobah. Organa c-3po organa binks zabrak ackbar lars calamari maul. Moff moff darth antilles. Jabba c-3po luke ahsoka dagobah watto han dagobah. Maul darth moff twi&#39;lek. Darth jinn binks binks binks maul sidious yavin moff. Wampa tatooine kenobi jinn ackbar binks.</div></div>","QuickLinksHeading":"CIS Benefits","PageName":"Coverage","DisplayExtendedHeaderBackground":false,"ExtendedHeaderHeight":"medium"}', NULL, 100)
GO
INSERT [dbo].[CMSSampleData] ([CMSSampleDataID], [PageJson], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (3, N'{"PublicAnnouncement":{"HeadlineName":"Open Enrollment Date Is Approaching","HeadlineSrc":"src","ImageID":"DA520B47C1F444A7956932BCC4266500","ImageFileName":"iStock Wellness v1_0.jpg","Description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud.","IsLive":"Y"},"Billboard":{"Headline":null,"Tagline":null,"Summary":null,"MediaEmbedCode":null,"Image":"3986248273954DDC94F9D43E2946B6B6","ImageFileName":"sinkhole-truck.jpg"},"SectionHighlights":[{"HeadlineName":"Health Benefits","HeadlineSrc":"link","ImageID":null,"ImageFileName":null,"Description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud.","IsLive":null},{"HeadlineName":"Lorem Ipsum","HeadlineSrc":"link 2","ImageID":null,"ImageFileName":null,"Description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud.","IsLive":null},{"HeadlineName":"Dolor Simet","HeadlineSrc":"link 3","ImageID":null,"ImageFileName":null,"Description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud.","IsLive":null},{"HeadlineName":"Apsus Enim","HeadlineSrc":"link 4","ImageID":null,"ImageFileName":null,"Description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud.","IsLive":null}],"MainImageBoxes":[{"Heading":"test heading","Image":"http://www.cisoregon.org/dl/eYOO0c2K","ImageFileName":"Dentist","Link":"test URL"},{"Heading":"test","Image":"http://www.cisoregon.org/dl/uTbcBuRw","ImageFileName":"Contented","Link":"test"}],"PageName":"Member Dashboard","DisplaySectionQuickLinks":false,"ConnectCallToActionToFooter":false}', NULL, 101)
GO
INSERT [dbo].[CMSSampleData] ([CMSSampleDataID], [PageJson], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (4, N'{"SecondaryHeadline":"lorem ipsum dolor sit amet, consectetuer adipiscing elit commo","Billboard":{"Headline":null,"Tagline":null,"Summary":null,"MediaEmbedCode":null,"Image":"6F2969E1DAEA44CABD9258AF24155700","ImageFileName":"nurses.jpg"},"MainImageBox":{"Heading":null,"Image":"ADBEE2C0650B49C0849F43BA6C1D5290","ImageFileName":"lakeo-fire.jpg","Link":null},"SecondaryImageBox":{"Heading":null,"Image":"D14DA7F3DA91453FB6606CF43CAB97A","ImageFileName":"Spending.png","Link":null},"SidebarImageBox":{"Heading":null,"Image":"112C7FE05C474B19B569C729E300A8A2","ImageFileName":"Contented.png","Link":"Test"},"SectionHighlights":[{"HeadlineName":"Test Highlight","HeadlineSrc":"Test Link","ImageID":null,"ImageFileName":null,"Description":"Test Desc","IsLive":null},{"HeadlineName":"Test Highlight","HeadlineSrc":"Test Link","ImageID":null,"ImageFileName":null,"Description":"Test Desc","IsLive":null},{"HeadlineName":"Test Highlight","HeadlineSrc":"Test Link","ImageID":null,"ImageFileName":null,"Description":"Test Desc","IsLive":null},{"HeadlineName":"Test Highlight","HeadlineSrc":"Test Link","ImageID":null,"ImageFileName":null,"Description":"Test Desc","IsLive":null},{"HeadlineName":"Test Highlight","HeadlineSrc":"Test Link","ImageID":null,"ImageFileName":null,"Description":"Test Desc","IsLive":null},{"HeadlineName":"Test Highlight","HeadlineSrc":"Test Link","ImageID":null,"ImageFileName":null,"Description":"Test Desc","IsLive":null}],"SectionQuickLinks":[],"PageName":"CIS Benefits"}', NULL, 102)
GO
INSERT [dbo].[CMSSampleData] ([CMSSampleDataID], [PageJson], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (5, N'{"BookletSubSectionNames":["Overview","Intro","The First Point","The Second Point","Second PointA"],"Booklet":[{"SubSectionName":"Overview","ParentSectionName":null,"ItemHeading":"test","ItemBody":"Overview body"},{"SubSectionName":"Intro","ParentSectionName":"Overview","ItemHeading":"test","ItemBody":"intro body"},{"SubSectionName":"The First Point","ParentSectionName":"Intro","ItemHeading":"Point 1 ","ItemBody":"point 1 body"},{"SubSectionName":"The Second Point","ParentSectionName":"Intro","ItemHeading":null,"ItemBody":null},{"SubSectionName":"Second PointA","ParentSectionName":null,"ItemHeading":null,"ItemBody":null}],"SidebarImageBoxes":[{"Heading":null,"Image":"CE4665526FD847DBB3EA92CE3EAEF2E1","ImageFileName":"Contented.png","Link":null}],"Headline":"test","PageName":"test","ExtendedHeaderHeight":"medium"}', NULL, 103)
GO
INSERT [dbo].[CMSSampleData] ([CMSSampleDataID], [PageJson], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (6, N'{"Headline":"Wellness","Tagline":"These wellness grants are so handy","SecondaryHeadline":"Secondary Headline","HeaderBody":"<div>Here is a little text about the page. &nbsp;Here&#39;s some more text! :-)</div>","InfoBoxes":[{"Headline":"Test Info Box","Body":"<div><span style=\"background-color:#C6D219\">Test </span>Info Box body</div>","Downloads":[{"LinkName":"Promotional Image","LinkSrc":"D0358125AABA430E8503B77438976949","LinkFileName":"smiling-cheesy2.jpg"},{"LinkName":"CIS Final Audit Report","LinkSrc":"http://www.cisoregon.org/dl/YIAJSX1o","LinkFileName":"CIS Final Audit Report.pdf"}]}],"PageName":"CIS Grants","ConnectCallToActionToFooter":false}', NULL, 104)
GO
INSERT [dbo].[CMSSampleData] ([CMSSampleDataID], [PageJson], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (7, N'{"SecondaryHeadline":"Secondary Headline","Billboard":{"Headline":null,"Tagline":null,"Summary":null,"MediaEmbedCode":null,"Image":"http://www.cisoregon.org/dl/eYOO0c2K","ImageFileName":"Dentist"},"MainImageBox":{"Heading":null,"Image":"F1ADC5B303F3454AA025AF9F08A742B7","ImageFileName":"IMG_20150731_164911_991.jpg","Link":null},"SecondaryImageBox":{"Heading":null,"Image":"20A200A6C9E94400880579EE54D6A648","ImageFileName":"ACMECafe.jpg","Link":null},"SectionQuickLinks":null,"CustomAction":{"Controller":"ManageProfile","Action":"Index","PartialView":"_ManageProfilePartialView"},"PageName":"Manage Profile","ConnectCallToActionToFooter":false}', NULL, 105)
GO
INSERT [dbo].[CMSSampleData] ([CMSSampleDataID], [PageJson], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (8, N'{"RedirectUrl":"http://2015.trondheimdc.no/","PageName":"CIS Oregon Dev Conference","DisplayExtendedHeaderBackground":false,"ExtendedHeaderHeight":"medium","DisplaySectionQuickLinks":false}', NULL, 106)
GO
INSERT [dbo].[CMSSampleData] ([CMSSampleDataID], [PageJson], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (9, N'{"Headline":"Claim Summaries","Tagline":"- Workers'' Compensation","SecondaryHeadline":null,"HeaderBody":null,"LeftInfoBox":{"Headline":"Report Request?","Body":"Don''t see the report you need? <a href=\"mailto:reports@cisoregon.org,cis@cisoregon.org?subject=Claims Report Request\">Click here</a> and let us know your request and when you need it by. We''re happy to work it up for you!","Downloads":[]},"CustomAction":null,"PageName":"Claim Summaries"}', NULL, 107)
GO
INSERT [dbo].[CMSSampleData] ([CMSSampleDataID], [PageJson], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (10, N'{"Headline":"Resources","Tagline":"Test tagline","SecondaryHeadline":"Test secondary headline","HeaderBody":"<div>Test header body</div>","SidebarSimpleInfoBoxes":[{"Headline":"Need help?","Body":"If you need help then contact us at this number: 123-456-7890","Downloads":null}],"InfoBoxes":[{"Headline":"Affidavit of Dependency","Body":"<div>this is the form description</div>","Downloads":[{"LinkName":"Affidavit of Dependency","LinkSrc":"5E733E410A4344DEA2745365888E4DD2","LinkFileName":"Affidavit of Dependency.pdf"}]},{"Headline":"LTD Claim Form","Body":"<div>this is the form description</div>","Downloads":[{"LinkName":"LTD Claim Form","LinkSrc":"14DC085E00D348B6BEE019DFF8EE81B","LinkFileName":"LTD Claim Form.pdf"}]},{"Headline":"A test document","Body":null,"Downloads":[{"LinkName":"A test document","LinkSrc":"74568CCC37454B0590A074B579817257","LinkFileName":"Test.docx"}]},{"Headline":"A test Excel file","Body":null,"Downloads":[{"LinkName":"A test Excel file","LinkSrc":"FD6E4C9AF3284950B05C78A8D5168FFD","LinkFileName":"Test.xlsx"}]},{"Headline":"A test Powerpoint file","Body":null,"Downloads":[{"LinkName":"A test Powerpoint file","LinkSrc":"76414A770613458181699979C8341561","LinkFileName":"Test.pptx"}]},{"Headline":"CIS Final Report","Body":"<div>Our final report of the year!</div>","Downloads":[{"LinkName":"CIS Final Report","LinkSrc":"http://www.cisoregon.org/dl/YIAJSX1o","LinkFileName":"test"}]}],"PageName":"Wellness Resources","ConnectCallToActionToFooter":false}', NULL, 108)
GO
INSERT [dbo].[CMSSampleData] ([CMSSampleDataID], [PageJson], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (11, N'{"PublicAnnouncement":{"HeadlineName":"Your Benefits, Discovered","HeadlineSrc":null,"ImageID":null,"ImageFileName":null,"Description":"Welcome to CIS Benefits. We know you may have questions about your employee benefit choices. We''re here to help you understand the benefits available to you and your family.","IsLive":null,"OpenInNewTab":false},"Billboard":{"Headline":null,"Tagline":null,"Summary":null,"MediaEmbedCode":"<iframe src=\"https://player.vimeo.com/video/23541008\" width=\"640\" height=\"472\" frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe> <p><a href=\"https://vimeo.com/23541008\">CIS Benefits and Healthy Benefits</a> from <a href=\"https://vimeo.com/cisoregon\">CIS Oregon</a> on <a href=\"https://vimeo.com\">Vimeo</a>.</p>","Image":"F42749F0A4704C09A039C4C3F71C2372","ImageFileName":"Serbia.jpg","ImageHref":null,"IsActuallyAVideoLink":true},"SectionHighlights":[{"HeadlineName":"New Hires-Getting Started","HeadlineSrc":null,"ImageID":"AB11D03584CB49A6BBC7A3B2E836E622","ImageFileName":"200x100.png","Description":"We want your enrollment to be easy and worry free.  We''ve created a step-by-step guide to help you through the process.","IsLive":null,"OpenInNewTab":false},{"HeadlineName":"Wellness","HeadlineSrc":"http://test.cisbenefits.org/Wellness","ImageID":"0A31663169F743878D4F6D273BA8CA20","ImageFileName":"390x230.png","Description":"We''re here to help you maintain a healthy weight, eat better, be more physically active, and reduce stress","IsLive":null,"OpenInNewTab":false},{"HeadlineName":"Privacy Notices","HeadlineSrc":"https://cisportal.hroffice.com/Downloaded/privacy-notice-cis_0ced6f82-a989-4a15-9fea-083ad82e9585_1268891730.pdf","ImageID":"0A31663169F743878D4F6D273BA8CA20","ImageFileName":"390x230.png","Description":"There are federal regulations governing protected health information for group health plans and other covered entities. It''s important that we describe how your medical information may be used and disclosed - as well as how you can access this information.","IsLive":null,"OpenInNewTab":false},{"HeadlineName":"Already Enrolled?","HeadlineSrc":null,"ImageID":"0A31663169F743878D4F6D273BA8CA20","ImageFileName":"390x230.png","Description":"You''re already enrolled and want to review or make a change.","IsLive":null,"OpenInNewTab":false}],"CallToAction":{"Description":"Test description!","LinkName":"Enroll Here","LinkHref":"https://cisportal.hroffice.com/account/login/MustAuthLogin?target=http%3a%2f%2fcisportal.hroffice.com%2f"},"LinkButton":{"LinkName":"Enrollment System","LinkSrc":"https://cisportal.hroffice.com/account/login/MustAuthLogin?target=http%3a%2f%2fcisportal.hroffice.com%2f","LinkFileName":null,"IsSubLevel":false},"QuickLinksHeading":{"LinkName":"Enrollment","LinkSrc":"https://cisportal.hroffice.com/account/login/MustAuthLogin?target=http%3a%2f%2fcisportal.hroffice.com%2f","LinkFileName":null,"IsSubLevel":false},"QuickLinks":[{"LinkName":"Regence BlueCross Blue Shield","LinkSrc":"www.regence.com","LinkFileName":null,"IsSubLevel":false},{"LinkName":"Kaiser Permanente","LinkSrc":"https://healthy.kaiserpermanente.org/","LinkFileName":null,"IsSubLevel":false},{"LinkName":"MDLive (Regence)","LinkSrc":"https://welcome.mdlive.com/","LinkFileName":null,"IsSubLevel":false},{"LinkName":"Reliant Behavioral Health","LinkSrc":"https://www.myrbh.com/Home/Home?role=member","LinkFileName":null,"IsSubLevel":false},{"LinkName":"VSP","LinkSrc":"https://www.vsp.com/","LinkFileName":null,"IsSubLevel":true},{"LinkName":"Willamette Dental","LinkSrc":"https://www.willamettedental.com/","LinkFileName":null,"IsSubLevel":true},{"LinkName":"Delta Dental","LinkSrc":"https://www.modahealth.com/","LinkFileName":null,"IsSubLevel":false},{"LinkName":"The Hartford","LinkSrc":"https://cisportal.hroffice.com/Downloaded/the-hartford_e39b0e26-1076-4ef3-84ed-61c03bc31cf5_0985278170.pdf","LinkFileName":null,"IsSubLevel":false}],"SmallInfoBox":{"Headline":"Need help?","Body":"<div>Please contact the<a href=\"mailto:employeebenefits@cisoregon.org\"><strong> CIS Benefits </strong></a>department.</div>\n","Downloads":[]},"PageName":"Home","ExcludeFromBreadCrumbs":false,"CMSHelp":null}', 116, 118)
GO
INSERT [dbo].[CMSSampleData] ([CMSSampleDataID], [PageJson], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (12, N'{"SecondaryHeadline":"A new resource for you to use at your convenience!","Billboard":{"Headline":null,"Tagline":null,"Summary":null,"MediaEmbedCode":null,"Image":"E63D9935112F46E3849F7B481706D200","ImageFileName":"760x350.png","ImageHref":null,"IsActuallyAVideoLink":false},"CallToAction":{"Description":"Login to access even more resources.","LinkName":"Login","LinkHref":"https://cisportal.hroffice.com/"},"MainPageHtml":"<div>\n<div>\n<div>&nbsp;</div>\n\n<div>CIS focuses on health improvement/wellness in the worksite and on assistance for individual employees and their families. Wellness resources availble to members and their employees include:</div>\n\n<div>&nbsp;</div>\n\n<div>\n<div>\n<div>\n<ul>\n\t<li>Healthy Eating &amp; Weight Management Programs</li>\n</ul>\n</div>\n\n<div>\n<ul>\n\t<li>Quit for Life Tobacco Cessation Program</li>\n</ul>\n</div>\n\n<div>\n<ul>\n\t<li>Worksite screening grant</li>\n</ul>\n</div>\n\n<div>\n<ul>\n\t<li>Employee Assistance Program</li>\n</ul>\n</div>\n\n<div>\n<ul>\n\t<li>Health Fair grant</li>\n</ul>\n</div>\n\n<div>\n<ul>\n\t<li>Turnkey worksite wellness programs</li>\n</ul>\n</div>\n</div>\n</div>\n</div>\n</div>\n","SmallInfoBox":{"Headline":"Need help?","Body":"<div>Please contact the <strong><a href=\"mailto:Wellness Resources?subject=employeebenefits%40cisoregon.org\">CIS Benefits</a></strong> department.</div>\n","Downloads":null},"PageName":"Wellness Resources","ExcludeFromBreadCrumbs":false,"CMSHelp":null}', 116, 119)
GO
SET IDENTITY_INSERT [dbo].[CMSSampleData] OFF
GO
SET IDENTITY_INSERT [dbo].[CMSSiteTemplateType] ON 
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (1, 115, 99)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (2, 115, 100)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (3, 115, 101)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (4, 115, 102)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (5, 115, 103)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (6, 115, 104)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (7, 115, 105)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (8, 117, 106)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (9, 115, 107)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (10, 115, 108)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (11, 115, 109)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (12, 115, 110)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (13, 115, 111)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (14, 115, 112)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (15, 115, 113)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (16, 115, 114)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (17, 116, 118)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (18, 116, 119)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (19, 127, 101)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (20, 127, 109)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (21, 127, 102)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (22, 127, 128)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (23, 127, 100)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (26, 127, 108)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (29, 115, 129)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (30, 115, 130)
GO
INSERT [dbo].[CMSSiteTemplateType] ([CMSSiteTemplateTypeID], [CMSSiteLookupID], [CMSTemplateTypeLookupID]) VALUES (31, 115, 131)
GO
SET IDENTITY_INSERT [dbo].[CMSSiteTemplateType] OFF
GO
SET IDENTITY_INSERT [dbo].[JsonDataSource] ON 
GO
INSERT [dbo].[JsonDataSource] ([JsonDataSourceID], [Name], [Data]) VALUES (1, N'Agency Directory', N'[{"AgencyName":"Abel Insurance Agency","AgentName":"Wendy Abel-Hatzel"},
{"AgencyName":"Alliance Insurance Group","AgentName":"M. Lisa Schultz"},
{"AgencyName":"Bain Insurance Agency","AgentName":"Joseph Bain"},
{"AgencyName":"Bancorp Insurance","AgentName":"Tammy Lesueur"},
{"AgencyName":"Barker-Uerlings Insurance, Inc.","AgentName":"Deidre Thede"},
{"AgencyName":"Barker-Uerlings Insurance, Inc.","AgentName":"Steven Uerlings"},
{"AgencyName":"Bisnett Insurance","AgentName":"Kathleen Lee"},
{"AgencyName":"Brown & Brown","AgentName":"Michaelene Thomas"},
{"AgencyName":"Clarke & Clarke Insurance Agency","AgentName":"Kevin Bell"},
{"AgencyName":"Clarke & Clarke Insurance Agency","AgentName":"Terri Bell"},
{"AgencyName":"Clay Davis Insurance Services, LLC","AgentName":"Clay Davis"},
{"AgencyName":"Coast Insurance Services","AgentName":"John Murphey"},
{"AgencyName":"Craven-Woods Insurance","AgentName":"Ken Woods Jr"},
{"AgencyName":"Ferranti-Graybeal Insurance Agency, Inc.","AgentName":"Jason Graybeal"},
{"AgencyName":"Field Waldo Insurance Agencies Inc","AgentName":"John Forsyth"},
{"AgencyName":"Field-Waldo Insurance Agencies","AgentName":"Ellen Martinez"},
{"AgencyName":"Fullhart Insurance Agency of Reedsport","AgentName":"Debbie McKinney"},
{"AgencyName":"Great Basin Insurance","AgentName":"Daneen Dail"},
{"AgencyName":"Great Basin Insurance","AgentName":"William Gilmore"},
{"AgencyName":"Great Basin Insurance","AgentName":"Matt Hurley"},
{"AgencyName":"Gustafson Insurance","AgentName":"Scott Gustafson"},
{"AgencyName":"Gustafson Insurance","AgentName":"Tim Gustafson"},
{"AgencyName":"Hagan Hamilton Insurance","AgentName":"Gary Eastlund"},
{"AgencyName":"Hagan Hanmilton Insurance Services, Inc.","AgentName":"Bern Coleman"},
{"AgencyName":"Hanson Insurance Group","AgentName":"Trent Hanson"},
{"AgencyName":"Hart Insurance","AgentName":"Terry Faulkner"},
{"AgencyName":"Hart Insurance","AgentName":"Kristin Wick"},
{"AgencyName":"Hudson Insurance","AgentName":"Cheryl Spellman"},
{"AgencyName":"ISU Insurance Services - The Stratton Agency","AgentName":"Mike Courtney"},
{"AgencyName":"ISU Insurance Services - The Stratton Agency","AgentName":"Rachel Dagley"},
{"AgencyName":"ISU Insurance Services - The Stratton Agency","AgentName":"Michael Stratton"},
{"AgencyName":"ISU Insurance Services - The Stratton Agency","AgentName":"Breanna Wimber"},
{"AgencyName":"Juul Insurance Agency","AgentName":"Kriston Correll"},
{"AgencyName":"Kaiser Permanente","AgentName":"Natalie Roth"},
{"AgencyName":"Madison & Davis Ins Agency, Inc","AgentName":"Bo Lindemann"},
{"AgencyName":"Nasburg Huggins Insurance Agency, Inc.","AgentName":"Ed Ellingsen"},
{"AgencyName":"NFP Property & Casualty Services, Inc.","AgentName":"Joe Schultz"},
{"AgencyName":"Nolte Fuller Insurnace Inc","AgentName":"Andrew Rucker"},
{"AgencyName":"Oregon Trail Insurance","AgentName":"Colleen Clark"},
{"AgencyName":"PayneWest Insurance","AgentName":"Stacey Anderson"},
{"AgencyName":"PayneWest Insurance","AgentName":"Laura Flores"},
{"AgencyName":"PayneWest Insurance","AgentName":"Matt McGowan"},
{"AgencyName":"PayneWest Insurance","AgentName":"John Russell"},
{"AgencyName":"Propel Insurance","AgentName":"Shon DeVries"},
{"AgencyName":"Propel Insurance","AgentName":"Scott Farmer"},
{"AgencyName":"Propel Insurance","AgentName":"Lauren Fortin"},
{"AgencyName":"Rhodes-Warden Insurance Agency","AgentName":"Mike Patterson"},
{"AgencyName":"Rhodes-Warden Insurance Agency","AgentName":"Alex Patterson"},
{"AgencyName":"WAFD INS Group","AgentName":"James Sabin"},
{"AgencyName":"WHA Insurance","AgentName":"Richard Allm"},
{"AgencyName":"WHA Insurance","AgentName":"Nathan Cortez"},
{"AgencyName":"WHA Insurance","AgentName":"Jennifer King"},
{"AgencyName":"WHA Insurance","AgentName":"Kelly McCorkle"},
{"AgencyName":"WHA Insurance","AgentName":"Kim Nicholsen"},
{"AgencyName":"WHA Insurance","AgentName":"Jake Stone"},
{"AgencyName":"Wheatland Insurance","AgentName":"John Anderson"},
{"AgencyName":"Wheatland Insurance","AgentName":"Dana Perkins"},
{"AgencyName":"Wheatland Insurance Center","AgentName":"Michael Corey"},
{"AgencyName":"Wheatland Insurance Center Inc","AgentName":"Kyle Evans"},
{"AgencyName":"Wheatland Insurance Center Inc","AgentName":"Karen Gipson"},
{"AgencyName":"Wheatland Insurance Center Inc","AgentName":"Alma Mae (Ame) Leggett"},
{"AgencyName":"Wheatland Insurance Center, Inc","AgentName":"Kathy Duncan-Casper"},
{"AgencyName":"Wheatland Insurance Center, Inc.","AgentName":"Kyle Evans"},
{"AgencyName":"Wilson Heirgood Associates","AgentName":"Nathan Cortez"},
{"AgencyName":"Wilson Heirgood Associates","AgentName":"Jeffrey Griffin"},
{"AgencyName":"WSC Insurance","AgentName":"Tom BeLusko"},
{"AgencyName":"WSC Insurance","AgentName":"Cynthia Cameron"},
{"AgencyName":"WSC Insurance","AgentName":"Amie Freeman"},
{"AgencyName":"WSC Insurance","AgentName":"LYNN OMEY"},
{"AgencyName":"WSC Insurance","AgentName":"Alycia Johnson"}]')
GO
INSERT [dbo].[JsonDataSource] ([JsonDataSourceID], [Name], [Data]) VALUES (2, N'BenefitsHeaderLink', N'{"LinkName":"ENROLL/UPDATE HERE","LinkSrc":"https://www2.benefitsolver.com/benefits/BenefitSolverView?page_name=signon&co_num=15671&co_affid=citycountyinsurance","LinkFileName":null,"IsSubLevel":false}')
GO
SET IDENTITY_INSERT [dbo].[JsonDataSource] OFF
GO
SET IDENTITY_INSERT [dbo].[Lookup] ON 
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (1, 1, N'Claims', N'Claims')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (2, 1, N'Finance', N'Finance (can pay bills)')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (3, 1, N'Member Services', N'Member Services')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (4, 1, N'Liability', N'Liability')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (5, 1, N'Property', N'Property')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (6, 1, N'Workers Comp', N'Workers Comp')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (7, 1, N'Benefits', N'Benefits')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (8, 1, N'Wellness', N'Wellness')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (9, 2, N'External', N'External')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (10, 2, N'Internal', N'Internal')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (11, 1, N'Admin', N'Administration')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (12, 3, N'RBH', N'RBH')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (13, 3, N'Quarterly Report', N'Quarterly Report')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (14, 3, N'Real-Time Risk', N'Real-Time Risk')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (15, 3, N'Safety Shorts', N'Safety Shorts')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (16, 3, N'CL Reports', N'CL Reports')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (17, 3, N'CLPL Primary', N'CLPL Primary')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (18, 3, N'CLWC Primary', N'CLWC Primary')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (19, 3, N'EB Online Billing', N'EB Online Billing')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (20, 3, N'EB Primary', N'EB Primary')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (21, 3, N'EB Secondary', N'EB Secondary')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (22, 3, N'PL Primary', N'PL Primary')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (23, 3, N'PL-Secondary', N'PL-Secondary')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (24, 3, N'WC Primary', N'WC Primary')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (25, 3, N'WC-Secondary', N'WC-Secondary')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (26, 3, N'Wellness Works', N'Wellness Works')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (27, 3, N'Wellness', N'Wellness')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (28, 3, N'Loss Runs PL', N'Loss Runs PL')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (29, 3, N'Loss Runs WC', N'Loss Runs WC')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (30, 5, N'APD', N'Auto Physical Damage')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (31, 5, N'AL', N'Auto Liability')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (32, 5, N'GL', N'General Liability')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (33, 5, N'PR', N'Property')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (34, 5, N'WC', N'Workers'' Compensation')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (35, 5, N'RFC', N'RFC General Questions')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (36, 6, N'DatabaseQuery', N'Database Query')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (37, 6, N'UserLoginFailure', N'User Login Failure')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (38, 6, N'UserLoginSuccess', N'User Login Success')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (39, 6, N'ResourceSearch', N'ResourceSearch')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (40, 6, N'SiteSearch', N'Site Search')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (41, 7, N'Delete', N'Delete')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (42, 7, N'Insert', N'Insert')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (43, 7, N'Update', N'Update')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (44, 1, N'Login As', N'Login As')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (45, 1, N'User Management', N'User Management')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (46, 1, N'CMS', N'CMS')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (47, 8, N'AK', N'Alaska')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (48, 8, N'AL', N'Alabama')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (49, 8, N'AR', N'Arkansas')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (50, 8, N'AZ', N'Arizona')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (51, 8, N'CA', N'California')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (52, 8, N'CO', N'Colorado')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (53, 8, N'CT', N'Connecticut')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (54, 8, N'DC', N'District of Columbia')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (55, 8, N'DE', N'Delaware')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (56, 8, N'FL', N'Florida')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (57, 8, N'GA', N'Georgia')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (58, 8, N'GU', N'Guam')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (59, 8, N'HI', N'Hawaii')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (60, 8, N'IA', N'Iowa')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (61, 8, N'ID', N'Idaho')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (62, 8, N'IL', N'Illinois')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (63, 8, N'IN', N'Indiana')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (64, 8, N'KS', N'Kansas')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (65, 8, N'KY', N'Kentucky')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (66, 8, N'LA', N'Louisiana')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (67, 8, N'MA', N'Massachusetts')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (68, 8, N'MD', N'Maryland')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (69, 8, N'ME', N'Maine')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (70, 8, N'MI', N'Michigan')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (71, 8, N'MN', N'Minnesota')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (72, 8, N'MO', N'Missouri')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (73, 8, N'MS', N'Mississippi')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (74, 8, N'MT', N'Montana')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (75, 8, N'NC', N'North Carolina')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (76, 8, N'ND', N'North Dakota')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (77, 8, N'NE', N'Nebraska')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (78, 8, N'NH', N'New Hampshire')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (79, 8, N'NJ', N'New Jersey')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (80, 8, N'NM', N'New Mexico')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (81, 8, N'NV', N'Nevada')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (82, 8, N'NY', N'New York')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (83, 8, N'OH', N'Ohio')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (84, 8, N'OK', N'Oklahoma')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (85, 8, N'OR', N'Oregon')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (86, 8, N'PA', N'Pennsylvania')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (87, 8, N'RI', N'Rhode Island')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (88, 8, N'SC', N'South Carolina')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (89, 8, N'SD', N'South Dakota')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (90, 8, N'TN', N'Tennessee')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (91, 8, N'TX', N'Texas')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (92, 8, N'UT', N'Utah')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (93, 8, N'VA', N'Virginia')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (94, 8, N'VT', N'Vermont')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (95, 8, N'WA', N'Washington')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (96, 8, N'WI', N'Wisconsin')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (97, 8, N'WV', N'West Virginia')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (98, 8, N'WY', N'Wyoming')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (99, 9, N'MarketingLanderTemplate', N'MarketingLanderTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (100, 9, N'MarketingSubpageTemplate', N'MarketingSubpageTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (101, 9, N'AccountDashboardTemplate', N'AccountDashboardTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (102, 9, N'SectionDashboardTemplate', N'SectionDashboardTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (103, 9, N'BookletTemplate', N'BookletTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (104, 9, N'InfoPageTemplate', N'InfoPageTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (106, 9, N'RedirectTemplate', N'RedirectTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (107, 9, N'DocumentTableTemplate', N'DocumentTableTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (108, 9, N'DocumentListingTemplate', N'DocumentListingTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (109, 9, N'LoginPageContent', N'LoginPageContent')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (110, 9, N'ContactFormTemplate', N'ContactFormTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (111, 9, N'ExternalSiteInfoTemplate', N'ExternalSiteInfoTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (112, 9, N'QuestionProSurveyTemplate', N'QuestionProSurveyTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (113, 9, N'EmployeeHandbookTemplate', N'EmployeeHandbookTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (114, 9, N'ConferenceBroadcastTemplate', N'ConferenceBroadcastTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (115, 10, N'Main', N'Main')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (116, 10, N'Benefits', N'Benefits')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (117, 10, N'Any', N'Any')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (118, 9, N'AccountFlyerTemplate', N'AccountFlyerTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (119, 9, N'BenefitsMarketingTemplate', N'BenefitsMarketingTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (120, 11, N'Benefits', N'cisbenefits_org')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (121, 6, N'MarkupURL', N'Markup URL')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (122, 11, N'BenefitsTest', N'test_cisbenefits_org')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (123, 11, N'MyCISTest', N'mytest_cisoregon_org')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (124, 11, N'MyCIS', N'my_cisoregon_org')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (125, 11, N'MainTest', N'test_cisoregon_org')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (126, 11, N'Main', N'cisoregon_org')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (127, 10, N'MyCIS', N'MyCIS')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (128, 9, N'VideoLibraryTemplate', N'VideoLibraryTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (129, 9, N'InterimChangesTemplate', N'InterimChangesTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (130, 9, N'LogiTemplate', N'LogiTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (131, 9, N'AudioPlayerTemplate', N'AudioPlayerTemplate')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (132, 3, N'Liability', N'Liability')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (133, 3, N'Property', N'Property')
GO
INSERT [dbo].[Lookup] ([LookupID], [LookupTypeID], [LookupName], [LookupDescription]) VALUES (134, 3, N'WC', N'WC')
GO
SET IDENTITY_INSERT [dbo].[Lookup] OFF
GO
SET IDENTITY_INSERT [dbo].[LookupAssociation] ON 
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (1, 3, 12)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (2, 3, 13)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (3, 3, 14)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (4, 3, 15)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (5, 3, 26)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (6, 1, 16)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (7, 1, 17)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (8, 1, 18)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (9, 2, 19)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (10, 2, 19)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (11, 7, 20)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (12, 7, 21)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (13, 4, 22)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (14, 4, 23)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (15, 5, 22)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (16, 5, 23)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (17, 6, 24)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (18, 6, 25)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (19, 8, 8)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (20, 8, 27)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (21, 3, 30)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (22, 3, 31)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (23, 3, 32)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (24, 3, 33)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (25, 3, 34)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (26, 3, 35)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (27, 1, 30)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (28, 1, 31)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (29, 1, 32)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (30, 1, 33)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (31, 1, 34)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (32, 1, 35)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (33, 7, 35)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (34, 4, 30)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (35, 4, 31)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (36, 4, 32)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (37, 5, 33)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (38, 6, 34)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (39, 1, 28)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (40, 1, 29)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (41, 115, 125)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (42, 115, 126)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (43, 116, 122)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (44, 116, 120)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (45, 127, 123)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (46, 127, 124)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (47, 2, 20)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (48, 2, 21)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (49, 4, 132)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (50, 5, 133)
GO
INSERT [dbo].[LookupAssociation] ([LookupAssociationID], [ParentLookupID], [ChildLookupID]) VALUES (51, 6, 134)
GO
SET IDENTITY_INSERT [dbo].[LookupAssociation] OFF
GO
SET IDENTITY_INSERT [dbo].[LookupType] ON 
GO
INSERT [dbo].[LookupType] ([LookupTypeID], [Name]) VALUES (1, N'UserRole')
GO
INSERT [dbo].[LookupType] ([LookupTypeID], [Name]) VALUES (2, N'UserType')
GO
INSERT [dbo].[LookupType] ([LookupTypeID], [Name]) VALUES (3, N'UserContactRole')
GO
INSERT [dbo].[LookupType] ([LookupTypeID], [Name]) VALUES (5, N'CoverageType')
GO
INSERT [dbo].[LookupType] ([LookupTypeID], [Name]) VALUES (6, N'LogType')
GO
INSERT [dbo].[LookupType] ([LookupTypeID], [Name]) VALUES (7, N'RevisionType')
GO
INSERT [dbo].[LookupType] ([LookupTypeID], [Name]) VALUES (8, N'State')
GO
INSERT [dbo].[LookupType] ([LookupTypeID], [Name]) VALUES (9, N'CMSTemplateType')
GO
INSERT [dbo].[LookupType] ([LookupTypeID], [Name]) VALUES (10, N'CMSSite')
GO
INSERT [dbo].[LookupType] ([LookupTypeID], [Name]) VALUES (11, N'CMSSiteURL')
GO
SET IDENTITY_INSERT [dbo].[LookupType] OFF
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Slug_CMS]    Script Date: 9/6/2018 10:59:57 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_Slug_CMS] ON [dbo].[CMS]
(
	[Slug] ASC,
	[IsLive] ASC,
	[CMSSiteLookupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_ELMAH_Error]    Script Date: 9/6/2018 10:59:57 PM ******/
ALTER TABLE [dbo].[ELMAH_Error] ADD  CONSTRAINT [PK_ELMAH_Error] PRIMARY KEY NONCLUSTERED 
(
	[ErrorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ELMAH_Error_App_Time_Seq]    Script Date: 9/6/2018 10:59:57 PM ******/
CREATE NONCLUSTERED INDEX [IX_ELMAH_Error_App_Time_Seq] ON [dbo].[ELMAH_Error]
(
	[Application] ASC,
	[TimeUtc] DESC,
	[Sequence] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ELMAH_Error] ADD  CONSTRAINT [DF_ELMAH_Error_ErrorId]  DEFAULT (newid()) FOR [ErrorId]
GO
ALTER TABLE [dbo].[Lookup]  WITH CHECK ADD  CONSTRAINT [FK_Lookup_LookupType] FOREIGN KEY([LookupTypeID])
REFERENCES [dbo].[LookupType] ([LookupTypeID])
GO
ALTER TABLE [dbo].[Lookup] CHECK CONSTRAINT [FK_Lookup_LookupType]
GO
ALTER TABLE [dbo].[LookupAssociation]  WITH CHECK ADD  CONSTRAINT [FK_LookupAssociation_Lookup] FOREIGN KEY([ParentLookupID])
REFERENCES [dbo].[Lookup] ([LookupID])
GO
ALTER TABLE [dbo].[LookupAssociation] CHECK CONSTRAINT [FK_LookupAssociation_Lookup]
GO
ALTER TABLE [dbo].[LookupAssociation]  WITH CHECK ADD  CONSTRAINT [FK_LookupAssociation_Lookup1] FOREIGN KEY([ChildLookupID])
REFERENCES [dbo].[Lookup] ([LookupID])
GO
ALTER TABLE [dbo].[LookupAssociation] CHECK CONSTRAINT [FK_LookupAssociation_Lookup1]
GO
ALTER TABLE [dbo].[LookupLevel]  WITH CHECK ADD  CONSTRAINT [FK_LookupLevel_Lookup] FOREIGN KEY([Level1LookupID])
REFERENCES [dbo].[Lookup] ([LookupID])
GO
ALTER TABLE [dbo].[LookupLevel] CHECK CONSTRAINT [FK_LookupLevel_Lookup]
GO
ALTER TABLE [dbo].[LookupLevel]  WITH CHECK ADD  CONSTRAINT [FK_LookupLevel_Lookup1] FOREIGN KEY([Level2LookupID])
REFERENCES [dbo].[Lookup] ([LookupID])
GO
ALTER TABLE [dbo].[LookupLevel] CHECK CONSTRAINT [FK_LookupLevel_Lookup1]
GO
ALTER TABLE [dbo].[LookupLevel]  WITH CHECK ADD  CONSTRAINT [FK_LookupLevel_Lookup2] FOREIGN KEY([Level3LookupID])
REFERENCES [dbo].[Lookup] ([LookupID])
GO
ALTER TABLE [dbo].[LookupLevel] CHECK CONSTRAINT [FK_LookupLevel_Lookup2]
GO
ALTER TABLE [dbo].[LookupLevel]  WITH CHECK ADD  CONSTRAINT [FK_LookupLevel_Lookup3] FOREIGN KEY([Level4LookupID])
REFERENCES [dbo].[Lookup] ([LookupID])
GO
ALTER TABLE [dbo].[LookupLevel] CHECK CONSTRAINT [FK_LookupLevel_Lookup3]
GO
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorsXml]    Script Date: 9/6/2018 10:59:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ELMAH_GetErrorsXml]
(
    @Application NVARCHAR(60),
    @PageIndex INT = 0,
    @PageSize INT = 15,
    @TotalCount INT OUTPUT
)
AS 

    SET NOCOUNT ON

    DECLARE @FirstTimeUTC DATETIME
    DECLARE @FirstSequence INT
    DECLARE @StartRow INT
    DECLARE @StartRowIndex INT

    SELECT 
        @TotalCount = COUNT(1) 
    FROM 
        [ELMAH_Error]
    WHERE 
        [Application] = @Application

    -- Get the ID of the first error for the requested page

    SET @StartRowIndex = @PageIndex * @PageSize + 1

    IF @StartRowIndex <= @TotalCount
    BEGIN

        SET ROWCOUNT @StartRowIndex

        SELECT  
            @FirstTimeUTC = [TimeUtc],
            @FirstSequence = [Sequence]
        FROM 
            [ELMAH_Error]
        WHERE   
            [Application] = @Application
        ORDER BY 
            [TimeUtc] DESC, 
            [Sequence] DESC

    END
    ELSE
    BEGIN

        SET @PageSize = 0

    END

    -- Now set the row count to the requested page size and get
    -- all records below it for the pertaining application.

    SET ROWCOUNT @PageSize

    SELECT 
        errorId     = [ErrorId], 
        application = [Application],
        host        = [Host], 
        type        = [Type],
        source      = [Source],
        message     = [Message],
        [user]      = [User],
        statusCode  = [StatusCode], 
        time        = CONVERT(VARCHAR(50), [TimeUtc], 126) + 'Z'
    FROM 
        [ELMAH_Error] error
    WHERE
        [Application] = @Application
    AND
        [TimeUtc] <= @FirstTimeUTC
    AND 
        [Sequence] <= @FirstSequence
    ORDER BY
        [TimeUtc] DESC, 
        [Sequence] DESC
    FOR
        XML AUTO

GO
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorXml]    Script Date: 9/6/2018 10:59:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ELMAH_GetErrorXml]
(
    @Application NVARCHAR(60),
    @ErrorId UNIQUEIDENTIFIER
)
AS

    SET NOCOUNT ON

    SELECT 
        [AllXml]
    FROM 
        [ELMAH_Error]
    WHERE
        [ErrorId] = @ErrorId
    AND
        [Application] = @Application

GO
/****** Object:  StoredProcedure [dbo].[ELMAH_LogError]    Script Date: 9/6/2018 10:59:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ELMAH_LogError]
(
    @ErrorId UNIQUEIDENTIFIER,
    @Application NVARCHAR(60),
    @Host NVARCHAR(30),
    @Type NVARCHAR(100),
    @Source NVARCHAR(60),
    @Message NVARCHAR(500),
    @User NVARCHAR(50),
    @AllXml NTEXT,
    @StatusCode INT,
    @TimeUtc DATETIME
)
AS

    SET NOCOUNT ON

    INSERT
    INTO
        [ELMAH_Error]
        (
            [ErrorId],
            [Application],
            [Host],
            [Type],
            [Source],
            [Message],
            [User],
            [AllXml],
            [StatusCode],
            [TimeUtc]
        )
    VALUES
        (
            @ErrorId,
            @Application,
            @Host,
            @Type,
            @Source,
            @Message,
            @User,
            @AllXml,
            @StatusCode,
            @TimeUtc
        )

GO
/****** Object:  StoredProcedure [dbo].[spRefreshCMSSampleData]    Script Date: 9/6/2018 10:59:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spRefreshCMSSampleData]
AS
-- BF 6/20/16
-- Delete all values and then re-insert a PageJson value using an existing page for each type of template.
BEGIN
	DELETE
	FROM CMSSampleData

	INSERT INTO CMSSampleData (
		TemplateID
		,PageJson
		)
	SELECT TemplateID
		,PageJson
	FROM (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY TemplateID ORDER BY TemplateID DESC
				) AS rn
		FROM CMS
		) t
	WHERE t.rn = 1
END
GO
USE [master]
GO
ALTER DATABASE [CMSSample] SET  READ_WRITE 
GO
