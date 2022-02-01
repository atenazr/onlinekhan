USE [Onlinekhan]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetAdminAcceess]    Script Date: 14/07/1398 04:49:08 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
create FUNCTION [dbo].[fnGetAdminAcceess]()

RETURNS  nvarchar(300)
AS
BEGIN
	
	declare @powActionBit as int = 4,
	@counter as int = 0,
	@actionBit as nvarchar(300),
	@sumOfAction as nvarchar(300) = '',
	@actionBitLen as int = 0,
	@sumOfActionLen as int = 0,
	@sumOfActionChar as int,
	@actionBitChar as int,
	@carry as int = 0,
	@sum as int = 0;

	declare cur1 CURSOR FOR 
		select ActionBit from Actions where ActionBit != 0 group by ActionBit 

	open cur1;
	fetch next from cur1 into @powActionBit
	WHILE @@FETCH_STATUS = 0  
	BEGIN	
		
		set @actionBit = 1;
		set @counter = 0;

		while @counter < @powActionBit
		begin
			set @actionBit = CONCAT(@actionBit, '0');
			set @counter = @counter + 1;
		end
		---------------------------------------------

		set @actionBitLen = LEN(@actionBit);
		set @sumOfActionLen = LEN(@sumOfAction)
		set @counter = 0;

		if @actionBitLen > @sumOfActionLen
		begin	
			while (@actionBitLen - @sumOfActionLen) > @counter
			begin
				set @sumOfAction = CONCAT('0', @sumOfAction);
				set @counter = @counter + 1;
			end
		end
		else
			begin	
			while (@sumOfActionLen - @actionBitLen) > @counter
			begin
				set @actionBit = CONCAT('0', @actionBit);
				set @counter = @counter + 1;
			end
		end
		---------------------------------------------


		set @counter = LEN(@actionBit);
		while @counter > 0
		begin
			select @actionBitChar = SUBSTRING(@actionBit, @counter, 1);
			select @sumOfActionChar = SUBSTRING(@sumOfAction, @counter, 1);

			set @sum = (@actionBitChar + @sumOfActionChar + @carry);
			set @sumOfAction = STUFF(@sumOfAction, @counter, 1, (@sum % 2))

			set @carry = @sum / 2;

			set @counter = @counter - 1;
		end

		if @carry = 1
			set @sumOfAction = CONCAT(@carry, @sumOfAction);
		---------------------------------------------

		fetch next from cur1 into @powActionBit
	end
	CLOSE cur1;
	DEALLOCATE cur1;

	return @sumOfAction;

END

GO
/****** Object:  Table [dbo].[__MigrationHistory]    Script Date: 14/07/1398 04:49:09 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__MigrationHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ContextKey] [nvarchar](300) NOT NULL,
	[Model] [varbinary](max) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK_dbo.__MigrationHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC,
	[ContextKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Actions]    Script Date: 14/07/1398 04:49:13 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Actions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FaName] [nvarchar](50) NOT NULL,
	[ActionBit] [smallint] NOT NULL,
	[Priority] [tinyint] NOT NULL,
	[IsIndex] [bit] NOT NULL,
	[ControllerId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Actions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AssayAnswerSheets]    Script Date: 14/07/1398 04:49:18 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssayAnswerSheets](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AssaySchaduleId] [int] NOT NULL,
	[AssayQuestionId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[AnswerTime] [int] NOT NULL,
	[Answer] [int] NOT NULL,
 CONSTRAINT [PK_dbo.AssayAnswerSheets] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AssayQuestions]    Script Date: 14/07/1398 04:49:23 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssayQuestions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AssayId] [int] NOT NULL,
	[QuestionId] [int] NOT NULL,
	[LessonId] [int] NOT NULL,
	[File] [nvarchar](50) NULL,
	[AnswerNumber] [int] NOT NULL,
 CONSTRAINT [PK_dbo.AssayQuestions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Assays]    Script Date: 14/07/1398 04:49:28 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Assays](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](50) NOT NULL,
	[Time] [int] NOT NULL,
	[LookupId_Importance] [int] NOT NULL,
	[LookupId_Type] [int] NOT NULL,
	[LookupId_QuestionType] [int] NOT NULL,
	[IsPublic] [bit] NOT NULL,
	[IsOnline] [bit] NOT NULL,
	[UserId] [int] NOT NULL,
	[DateTimeCreate] [datetime] NOT NULL,
	[File] [nvarchar](50) NULL,
 CONSTRAINT [PK_dbo.Assays] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AssaySchedules]    Script Date: 14/07/1398 04:49:36 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssaySchedules](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AssayId] [int] NOT NULL,
	[DateTime] [datetime] NOT NULL,
	[Time] [int] NOT NULL,
 CONSTRAINT [PK_dbo.AssaySchedules] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AxillaryBooks]    Script Date: 14/07/1398 04:49:40 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AxillaryBooks](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[PublishYear] [smallint] NOT NULL,
	[Author] [nvarchar](100) NOT NULL,
	[Isbn] [nvarchar](100) NOT NULL,
	[Font] [nvarchar](50) NULL,
	[ImgName] [nvarchar](200) NULL,
	[Price] [int] NOT NULL,
	[OriginalPrice] [int] NOT NULL,
	[Description] [nvarchar](300) NULL,
	[LookupId_PrintType] [int] NOT NULL,
	[PublisherId] [int] NOT NULL,
	[LookupId_PaperType] [int] NOT NULL,
	[LookupId_BookType] [int] NOT NULL,
 CONSTRAINT [PK_dbo.AxillaryBooks] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AxillaryBooks_EducationBooks]    Script Date: 14/07/1398 04:49:51 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AxillaryBooks_EducationBooks](
	[AxillaryBookId] [int] NOT NULL,
	[EducationBookId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.AxillaryBooks_EducationBooks] PRIMARY KEY CLUSTERED 
(
	[AxillaryBookId] ASC,
	[EducationBookId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Boxes]    Script Date: 14/07/1398 04:49:53 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Boxes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[TeacherId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Boxes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Cities]    Script Date: 14/07/1398 04:49:55 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cities](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[ProvinceId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Cities] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Controllers]    Script Date: 14/07/1398 04:49:58 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Controllers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FaName] [nvarchar](50) NOT NULL,
	[EnName] [nvarchar](50) NOT NULL,
	[Icone] [nvarchar](200) NOT NULL,
	[Priority] [tinyint] NOT NULL,
	[ModuleId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Controllers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EducationBooks]    Script Date: 14/07/1398 04:50:03 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EducationBooks](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[PublishYear] [smallint] NOT NULL,
	[IsExamSource] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsChanged] [bit] NOT NULL,
	[LessonId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.EducationBooks] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EducationSubGroups]    Script Date: 14/07/1398 04:50:09 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EducationSubGroups](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[EducationTreeId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.EducationSubGroups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EducationTrees]    Script Date: 14/07/1398 04:50:12 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EducationTrees](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[ParentEducationTreeId] [int] NULL,
	[LookupId_EducationTreeState] [int] NOT NULL,
 CONSTRAINT [PK_dbo.EducationTrees] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EducationTrees_Lessons]    Script Date: 14/07/1398 04:50:15 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EducationTrees_Lessons](
	[EducationTreeId] [int] NOT NULL,
	[LessonId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.EducationTrees_Lessons] PRIMARY KEY CLUSTERED 
(
	[EducationTreeId] ASC,
	[LessonId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EducationYears]    Script Date: 14/07/1398 04:50:17 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EducationYears](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[IsActiveYear] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.EducationYears] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Exams]    Script Date: 14/07/1398 04:50:20 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Exams](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Date] [datetime] NOT NULL,
	[EducationTreeId] [int] NOT NULL,
	[EducationYearId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Exams] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[HistoryEducations]    Script Date: 14/07/1398 04:50:24 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HistoryEducations](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[StudentId] [int] NOT NULL,
	[RankGoal] [int] NOT NULL,
	[ExamId] [int] NOT NULL,
	[EducationTreeId] [int] NOT NULL,
	[EducationSubGroup_Id] [int] NULL,
 CONSTRAINT [PK_dbo.HistoryEducations] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[HistoryEducations_Cities]    Script Date: 14/07/1398 04:50:29 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HistoryEducations_Cities](
	[HistoryEducationId] [int] NOT NULL,
	[CityId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.HistoryEducations_Cities] PRIMARY KEY CLUSTERED 
(
	[HistoryEducationId] ASC,
	[CityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[HistoryEducations_UniversityBranchs]    Script Date: 14/07/1398 04:50:31 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HistoryEducations_UniversityBranchs](
	[HistoryEducationId] [int] NOT NULL,
	[UniversityBranchId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.HistoryEducations_UniversityBranchs] PRIMARY KEY CLUSTERED 
(
	[HistoryEducationId] ASC,
	[UniversityBranchId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LessonDepartments]    Script Date: 14/07/1398 04:50:33 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonDepartments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_dbo.LessonDepartments] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lessons]    Script Date: 14/07/1398 04:50:35 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lessons](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[IsMain] [bit] NOT NULL,
	[LookupId_Nezam] [int] NOT NULL,
	[NumberOfJudges] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Lessons] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lessons_LessonDepartments]    Script Date: 14/07/1398 04:50:40 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lessons_LessonDepartments](
	[LessonId] [int] NOT NULL,
	[LessonDepartmentId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Lessons_LessonDepartments] PRIMARY KEY CLUSTERED 
(
	[LessonId] ASC,
	[LessonDepartmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lessons_Users]    Script Date: 14/07/1398 04:50:42 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lessons_Users](
	[UserId] [int] NOT NULL,
	[LessonId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Lessons_Users] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[LessonId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lookups]    Script Date: 14/07/1398 04:50:44 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lookups](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Value] [nvarchar](50) NOT NULL,
	[State] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Lookups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Modules]    Script Date: 14/07/1398 04:50:47 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Modules](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Priority] [tinyint] NOT NULL,
 CONSTRAINT [PK_dbo.Modules] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Provinces]    Script Date: 14/07/1398 04:50:50 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Provinces](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Code] [nvarchar](5) NOT NULL,
 CONSTRAINT [PK_dbo.Provinces] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Publishers]    Script Date: 14/07/1398 04:50:54 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Publishers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_dbo.Publishers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[QuestionAnswers]    Script Date: 14/07/1398 04:50:58 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuestionAnswers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](50) NULL,
	[Context] [nvarchar](max) NOT NULL,
	[FilePath] [nvarchar](200) NULL,
	[LookupId_AnswerType] [int] NOT NULL,
	[Description] [nvarchar](300) NULL,
	[IsMaster] [bit] NOT NULL,
	[UserId] [int] NOT NULL,
	[QuestionId] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[WriterId] [int] NOT NULL,
	[LessonName] [nvarchar](50) NULL,
 CONSTRAINT [PK_dbo.QuestionAnswers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[QuestionAnswerViews]    Script Date: 14/07/1398 04:51:17 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuestionAnswerViews](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Rate] [tinyint] NOT NULL,
	[AnswerId] [int] NOT NULL,
	[StudentId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.QuestionAnswerViews] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[QuestionEquals]    Script Date: 14/07/1398 04:51:23 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuestionEquals](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EqualType] [tinyint] NOT NULL,
	[QuestionId1] [int] NOT NULL,
	[QuestionId2] [int] NOT NULL,
 CONSTRAINT [PK_dbo.QuestionEquals] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[QuestionGroups]    Script Date: 14/07/1398 04:51:27 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuestionGroups](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](200) NOT NULL,
	[InsertTime] [datetime] NOT NULL,
	[File] [nvarchar](50) NULL,
	[LessonId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.QuestionGroups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[QuestionGroups_Questions]    Script Date: 14/07/1398 04:51:32 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuestionGroups_Questions](
	[QuestionGroupId] [int] NOT NULL,
	[QuestionId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.QuestionGroups_Questions] PRIMARY KEY CLUSTERED 
(
	[QuestionGroupId] ASC,
	[QuestionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[QuestionJudges]    Script Date: 14/07/1398 04:51:34 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuestionJudges](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsStandard] [bit] NOT NULL,
	[IsDelete] [bit] NOT NULL,
	[IsUpdate] [bit] NOT NULL,
	[IsLearning] [bit] NOT NULL,
	[ResponseSecond] [smallint] NOT NULL,
	[QuestionId] [int] NOT NULL,
	[LookupId_QuestionHardnessType] [int] NOT NULL,
	[LookupId_RepeatnessType] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[IsActiveQuestion] [bit] NOT NULL,
	[IsActiveQuestionAnswer] [bit] NOT NULL,
	[LookupId_WhereProblem] [int] NOT NULL,
	[LookupId_ReasonProblem] [int] NOT NULL,
	[Description] [nvarchar](400) NULL,
	[LookupId_QuestionRank] [int] NOT NULL,
	[EducationGroup] [nvarchar](50) NULL,
 CONSTRAINT [PK_dbo.QuestionJudges] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[QuestionOptions]    Script Date: 14/07/1398 04:51:47 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuestionOptions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Context] [nvarchar](max) NOT NULL,
	[IsAnswer] [bit] NOT NULL,
	[QuestionId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.QuestionOptions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Questions]    Script Date: 14/07/1398 04:51:50 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Questions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Context] [nvarchar](max) NOT NULL,
	[QuestionNumber] [int] NOT NULL,
	[LookupId_QuestionType] [int] NOT NULL,
	[QuestionPoint] [int] NOT NULL,
	[LookupId_QuestionHardnessType] [int] NOT NULL,
	[LookupId_RepeatnessType] [int] NOT NULL,
	[UseEvaluation] [bit] NOT NULL,
	[IsStandard] [bit] NOT NULL,
	[LookupId_AuthorType] [int] NOT NULL,
	[ResponseSecond] [smallint] NOT NULL,
	[LookupId_AreaType] [int] NOT NULL,
	[Description] [nvarchar](300) NULL,
	[FileName] [nvarchar](50) NOT NULL,
	[InsertDateTime] [datetime] NOT NULL,
	[UserId] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsExercise] [bit] NOT NULL,
	[IsLearning] [bit] NOT NULL,
	[AnswerNumber] [int] NOT NULL,
	[IsDelete] [bit] NOT NULL,
	[IsUpdate] [bit] NOT NULL,
	[WriterId] [int] NOT NULL,
	[IsHybrid] [bit] NOT NULL,
	[LookupId_QuestionRank] [int] NOT NULL,
	[TopicAnswer] [nvarchar](50) NULL,
 CONSTRAINT [PK_dbo.Questions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Questions_Boxes]    Script Date: 14/07/1398 04:52:10 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Questions_Boxes](
	[QuestionId] [int] NOT NULL,
	[BoxId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Questions_Boxes] PRIMARY KEY CLUSTERED 
(
	[QuestionId] ASC,
	[BoxId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Questions_Tags]    Script Date: 14/07/1398 04:52:12 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Questions_Tags](
	[QuestionId] [int] NOT NULL,
	[TagId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Questions_Tags] PRIMARY KEY CLUSTERED 
(
	[QuestionId] ASC,
	[TagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Ratios]    Script Date: 14/07/1398 04:52:14 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ratios](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Rate] [tinyint] NOT NULL,
	[LessonId] [int] NOT NULL,
	[EducationSubGroupId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Ratios] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Resumes]    Script Date: 14/07/1398 04:52:19 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Resumes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Branch] [nvarchar](50) NULL,
	[CreationDateTime] [datetime] NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[Family] [nvarchar](150) NOT NULL,
	[FatherName] [nvarchar](150) NOT NULL,
	[IdNumber] [nvarchar](10) NULL,
	[NationalNo] [nvarchar](10) NULL,
	[Gender] [bit] NOT NULL,
	[Phone] [nvarchar](11) NOT NULL,
	[Mobile] [nvarchar](11) NOT NULL,
	[CityBorn] [nvarchar](50) NOT NULL,
	[Birthday] [datetime] NOT NULL,
	[Marriage] [bit] NOT NULL,
	[Religion] [nvarchar](50) NOT NULL,
	[Address] [nvarchar](300) NOT NULL,
	[PostCode] [nvarchar](10) NOT NULL,
	[FatherJob] [nvarchar](150) NULL,
	[FatherDegree] [int] NOT NULL,
	[FatherPhone] [nvarchar](11) NULL,
	[MotherJob] [nvarchar](150) NULL,
	[MotherDegree] [int] NOT NULL,
	[MotherPhone] [nvarchar](11) NULL,
	[PartnerJob] [nvarchar](150) NULL,
	[PartnerDegree] [int] NOT NULL,
	[PartnerPhone] [nvarchar](11) NULL,
	[Reagent1] [nvarchar](50) NULL,
	[RelationReagent1] [nvarchar](50) NULL,
	[JobReagent1] [nvarchar](50) NULL,
	[PhoneReagent1] [nvarchar](11) NULL,
	[AddressReagent1] [nvarchar](300) NULL,
	[Reagent2] [nvarchar](50) NULL,
	[RelationReagent2] [nvarchar](50) NULL,
	[JobReagent2] [nvarchar](50) NULL,
	[PhoneReagent2] [nvarchar](11) NULL,
	[AddressReagent2] [nvarchar](300) NULL,
	[HaveEducationCertificate] [bit] NOT NULL,
	[HaveAnotherCertificate] [bit] NOT NULL,
	[AnotherCertificate] [nvarchar](50) NULL,
	[HavePublication] [bit] NOT NULL,
	[NumberOfPublication] [int] NOT NULL,
	[HaveTeachingResume] [bit] NOT NULL,
	[NumberOfTeachingYear] [int] NOT NULL,
	[MaghtaRequest1] [int] NOT NULL,
	[KindRequest1] [int] NOT NULL,
	[LessonNameRequest1] [nvarchar](50) NULL,
	[MaghtaRequest2] [int] NOT NULL,
	[KindRequest2] [int] NOT NULL,
	[LessonNameRequest2] [nvarchar](50) NULL,
	[RequestForAdvice] [bit] NOT NULL,
	[MaghtaAdvice] [int] NOT NULL,
	[Description] [nvarchar](300) NULL,
	[EducationCertificateJson] [nvarchar](max) NOT NULL,
	[PublicationJson] [nvarchar](max) NOT NULL,
	[TeachingResumeJson] [nvarchar](max) NOT NULL,
	[CityId] [int] NOT NULL,
	[TeachingRequest1] [bit] NOT NULL,
	[PublishingRequest1] [bit] NOT NULL,
	[TeachingRequest2] [bit] NOT NULL,
	[PublishingRequest2] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.Resumes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Roles]    Script Date: 14/07/1398 04:53:16 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Level] [tinyint] NOT NULL,
	[SumOfActionBit] [nvarchar](300) NOT NULL,
	[UserType] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Roles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Students]    Script Date: 14/07/1398 04:53:20 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Students](
	[Id] [int] NOT NULL,
	[FatherName] [nvarchar](50) NOT NULL,
	[Address] [nvarchar](300) NOT NULL,
 CONSTRAINT [PK_dbo.Students] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Tags]    Script Date: 14/07/1398 04:53:23 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tags](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[IsSource] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.Tags] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Teachers]    Script Date: 14/07/1398 04:53:26 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Teachers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FatherName] [nvarchar](50) NOT NULL,
	[Address] [nvarchar](300) NOT NULL,
	[UserId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Teachers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Topics]    Script Date: 14/07/1398 04:53:29 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Topics](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](200) NOT NULL,
	[ExamStock] [int] NOT NULL,
	[ExamStockSystem] [int] NOT NULL,
	[Importance] [smallint] NOT NULL,
	[IsExamSource] [bit] NOT NULL,
	[LookupId_HardnessType] [int] NOT NULL,
	[LookupId_AreaType] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ParentTopicId] [int] NULL,
	[LessonId] [int] NOT NULL,
	[DisplayPriority] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Topics] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Topics_EducationBooks]    Script Date: 14/07/1398 04:53:39 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Topics_EducationBooks](
	[TopicId] [int] NOT NULL,
	[EducationBookId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Topics_EducationBooks] PRIMARY KEY CLUSTERED 
(
	[TopicId] ASC,
	[EducationBookId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Topics_Questions]    Script Date: 14/07/1398 04:53:41 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Topics_Questions](
	[TopicId] [int] NOT NULL,
	[QuestionId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Topics_Questions] PRIMARY KEY CLUSTERED 
(
	[TopicId] ASC,
	[QuestionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UniversityBranches]    Script Date: 14/07/1398 04:53:45 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UniversityBranches](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[SiteAverage] [int] NOT NULL,
	[Balance1Low] [int] NOT NULL,
	[Balance1High] [int] NOT NULL,
	[Balance2Low] [int] NOT NULL,
	[Balance2High] [int] NOT NULL,
	[EducationSubGroupId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.UniversityBranches] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Users]    Script Date: 14/07/1398 04:54:20 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Family] [nvarchar](50) NOT NULL,
	[Username] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](50) NOT NULL,
	[NationalNo] [nvarchar](10) NULL,
	[Gender] [bit] NOT NULL,
	[Phone] [nvarchar](8) NULL,
	[Mobile] [nvarchar](11) NULL,
	[IsAdmin] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[LastLogin] [datetime] NOT NULL,
	[RoleId] [int] NOT NULL,
	[CityId] [int] NOT NULL,
	[ProfilePic] [nvarchar](50) NULL,
 CONSTRAINT [PK_dbo.Users] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Writers]    Script Date: 14/07/1398 04:54:32 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Writers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[User_Id] [int] NULL,
 CONSTRAINT [PK_dbo.Writers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Lessons] ADD  DEFAULT ((0)) FOR [NumberOfJudges]
GO
ALTER TABLE [dbo].[QuestionAnswers] ADD  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[QuestionAnswers] ADD  DEFAULT ((0)) FOR [WriterId]
GO
ALTER TABLE [dbo].[QuestionJudges] ADD  DEFAULT ((0)) FOR [UserId]
GO
ALTER TABLE [dbo].[QuestionJudges] ADD  DEFAULT ((0)) FOR [IsActiveQuestion]
GO
ALTER TABLE [dbo].[QuestionJudges] ADD  DEFAULT ((0)) FOR [IsActiveQuestionAnswer]
GO
ALTER TABLE [dbo].[QuestionJudges] ADD  DEFAULT ((0)) FOR [LookupId_WhereProblem]
GO
ALTER TABLE [dbo].[QuestionJudges] ADD  DEFAULT ((0)) FOR [LookupId_ReasonProblem]
GO
ALTER TABLE [dbo].[QuestionJudges] ADD  DEFAULT ((1062)) FOR [LookupId_QuestionRank]
GO
ALTER TABLE [dbo].[Questions] ADD  DEFAULT ((0)) FOR [IsDelete]
GO
ALTER TABLE [dbo].[Questions] ADD  DEFAULT ((0)) FOR [IsUpdate]
GO
ALTER TABLE [dbo].[Questions] ADD  DEFAULT ((1)) FOR [WriterId]
GO
ALTER TABLE [dbo].[Questions] ADD  DEFAULT ((0)) FOR [IsHybrid]
GO
ALTER TABLE [dbo].[Questions] ADD  DEFAULT ((1063)) FOR [LookupId_QuestionRank]
GO
ALTER TABLE [dbo].[Resumes] ADD  DEFAULT ((0)) FOR [TeachingRequest1]
GO
ALTER TABLE [dbo].[Resumes] ADD  DEFAULT ((0)) FOR [PublishingRequest1]
GO
ALTER TABLE [dbo].[Resumes] ADD  DEFAULT ((0)) FOR [TeachingRequest2]
GO
ALTER TABLE [dbo].[Resumes] ADD  DEFAULT ((0)) FOR [PublishingRequest2]
GO
ALTER TABLE [dbo].[Topics] ADD  DEFAULT ((0)) FOR [DisplayPriority]
GO
ALTER TABLE [dbo].[Actions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Actions_dbo.Controllers_ControllerId] FOREIGN KEY([ControllerId])
REFERENCES [dbo].[Controllers] ([Id])
GO
ALTER TABLE [dbo].[Actions] CHECK CONSTRAINT [FK_dbo.Actions_dbo.Controllers_ControllerId]
GO
ALTER TABLE [dbo].[AssayAnswerSheets]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssayAnswerSheets_dbo.AssayQuestions_AssayQuestionId] FOREIGN KEY([AssayQuestionId])
REFERENCES [dbo].[AssayQuestions] ([Id])
GO
ALTER TABLE [dbo].[AssayAnswerSheets] CHECK CONSTRAINT [FK_dbo.AssayAnswerSheets_dbo.AssayQuestions_AssayQuestionId]
GO
ALTER TABLE [dbo].[AssayAnswerSheets]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssayAnswerSheets_dbo.AssaySchedules_AssaySchaduleId] FOREIGN KEY([AssaySchaduleId])
REFERENCES [dbo].[AssaySchedules] ([Id])
GO
ALTER TABLE [dbo].[AssayAnswerSheets] CHECK CONSTRAINT [FK_dbo.AssayAnswerSheets_dbo.AssaySchedules_AssaySchaduleId]
GO
ALTER TABLE [dbo].[AssayAnswerSheets]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssayAnswerSheets_dbo.Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[AssayAnswerSheets] CHECK CONSTRAINT [FK_dbo.AssayAnswerSheets_dbo.Users_UserId]
GO
ALTER TABLE [dbo].[AssayQuestions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssayQuestions_dbo.Assays_AssayId] FOREIGN KEY([AssayId])
REFERENCES [dbo].[Assays] ([Id])
GO
ALTER TABLE [dbo].[AssayQuestions] CHECK CONSTRAINT [FK_dbo.AssayQuestions_dbo.Assays_AssayId]
GO
ALTER TABLE [dbo].[AssayQuestions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssayQuestions_dbo.Lessons_LessonId] FOREIGN KEY([LessonId])
REFERENCES [dbo].[Lessons] ([Id])
GO
ALTER TABLE [dbo].[AssayQuestions] CHECK CONSTRAINT [FK_dbo.AssayQuestions_dbo.Lessons_LessonId]
GO
ALTER TABLE [dbo].[AssayQuestions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssayQuestions_dbo.Questions_QuestionId] FOREIGN KEY([QuestionId])
REFERENCES [dbo].[Questions] ([Id])
GO
ALTER TABLE [dbo].[AssayQuestions] CHECK CONSTRAINT [FK_dbo.AssayQuestions_dbo.Questions_QuestionId]
GO
ALTER TABLE [dbo].[Assays]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Assays_dbo.Lookups_LookupId_Importance] FOREIGN KEY([LookupId_Importance])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[Assays] CHECK CONSTRAINT [FK_dbo.Assays_dbo.Lookups_LookupId_Importance]
GO
ALTER TABLE [dbo].[Assays]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Assays_dbo.Lookups_LookupId_QuestionType] FOREIGN KEY([LookupId_QuestionType])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[Assays] CHECK CONSTRAINT [FK_dbo.Assays_dbo.Lookups_LookupId_QuestionType]
GO
ALTER TABLE [dbo].[Assays]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Assays_dbo.Lookups_LookupId_Type] FOREIGN KEY([LookupId_Type])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[Assays] CHECK CONSTRAINT [FK_dbo.Assays_dbo.Lookups_LookupId_Type]
GO
ALTER TABLE [dbo].[Assays]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Assays_dbo.Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Assays] CHECK CONSTRAINT [FK_dbo.Assays_dbo.Users_UserId]
GO
ALTER TABLE [dbo].[AssaySchedules]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssaySchedules_dbo.Assays_AssayId] FOREIGN KEY([AssayId])
REFERENCES [dbo].[Assays] ([Id])
GO
ALTER TABLE [dbo].[AssaySchedules] CHECK CONSTRAINT [FK_dbo.AssaySchedules_dbo.Assays_AssayId]
GO
ALTER TABLE [dbo].[AxillaryBooks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AxillaryBooks_dbo.Lookups_LookupId_BookType] FOREIGN KEY([LookupId_BookType])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[AxillaryBooks] CHECK CONSTRAINT [FK_dbo.AxillaryBooks_dbo.Lookups_LookupId_BookType]
GO
ALTER TABLE [dbo].[AxillaryBooks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AxillaryBooks_dbo.Lookups_LookupId_PaperType] FOREIGN KEY([LookupId_PaperType])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[AxillaryBooks] CHECK CONSTRAINT [FK_dbo.AxillaryBooks_dbo.Lookups_LookupId_PaperType]
GO
ALTER TABLE [dbo].[AxillaryBooks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AxillaryBooks_dbo.Lookups_LookupId_PrintType] FOREIGN KEY([LookupId_PrintType])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[AxillaryBooks] CHECK CONSTRAINT [FK_dbo.AxillaryBooks_dbo.Lookups_LookupId_PrintType]
GO
ALTER TABLE [dbo].[AxillaryBooks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AxillaryBooks_dbo.Publishers_PublisherId] FOREIGN KEY([PublisherId])
REFERENCES [dbo].[Publishers] ([Id])
GO
ALTER TABLE [dbo].[AxillaryBooks] CHECK CONSTRAINT [FK_dbo.AxillaryBooks_dbo.Publishers_PublisherId]
GO
ALTER TABLE [dbo].[AxillaryBooks_EducationBooks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AxillaryBooks_EducationBooks_dbo.AxillaryBooks_AxillaryBookId] FOREIGN KEY([AxillaryBookId])
REFERENCES [dbo].[AxillaryBooks] ([Id])
GO
ALTER TABLE [dbo].[AxillaryBooks_EducationBooks] CHECK CONSTRAINT [FK_dbo.AxillaryBooks_EducationBooks_dbo.AxillaryBooks_AxillaryBookId]
GO
ALTER TABLE [dbo].[AxillaryBooks_EducationBooks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AxillaryBooks_EducationBooks_dbo.EducationBooks_EducationBookId] FOREIGN KEY([EducationBookId])
REFERENCES [dbo].[EducationBooks] ([Id])
GO
ALTER TABLE [dbo].[AxillaryBooks_EducationBooks] CHECK CONSTRAINT [FK_dbo.AxillaryBooks_EducationBooks_dbo.EducationBooks_EducationBookId]
GO
ALTER TABLE [dbo].[Boxes]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Boxes_dbo.Teachers_TeacherId] FOREIGN KEY([TeacherId])
REFERENCES [dbo].[Teachers] ([Id])
GO
ALTER TABLE [dbo].[Boxes] CHECK CONSTRAINT [FK_dbo.Boxes_dbo.Teachers_TeacherId]
GO
ALTER TABLE [dbo].[Cities]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Cities_dbo.Provinces_ProvinceId] FOREIGN KEY([ProvinceId])
REFERENCES [dbo].[Provinces] ([Id])
GO
ALTER TABLE [dbo].[Cities] CHECK CONSTRAINT [FK_dbo.Cities_dbo.Provinces_ProvinceId]
GO
ALTER TABLE [dbo].[Controllers]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Controllers_dbo.Modules_ModuleId] FOREIGN KEY([ModuleId])
REFERENCES [dbo].[Modules] ([Id])
GO
ALTER TABLE [dbo].[Controllers] CHECK CONSTRAINT [FK_dbo.Controllers_dbo.Modules_ModuleId]
GO
ALTER TABLE [dbo].[EducationBooks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EducationBooks_dbo.Lessons_LessonId] FOREIGN KEY([LessonId])
REFERENCES [dbo].[Lessons] ([Id])
GO
ALTER TABLE [dbo].[EducationBooks] CHECK CONSTRAINT [FK_dbo.EducationBooks_dbo.Lessons_LessonId]
GO
ALTER TABLE [dbo].[EducationSubGroups]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EducationSubGroups_dbo.EducationTrees_EducationTreeId] FOREIGN KEY([EducationTreeId])
REFERENCES [dbo].[EducationTrees] ([Id])
GO
ALTER TABLE [dbo].[EducationSubGroups] CHECK CONSTRAINT [FK_dbo.EducationSubGroups_dbo.EducationTrees_EducationTreeId]
GO
ALTER TABLE [dbo].[EducationTrees]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EducationTrees_dbo.EducationTrees_ParentEducationTreeId] FOREIGN KEY([ParentEducationTreeId])
REFERENCES [dbo].[EducationTrees] ([Id])
GO
ALTER TABLE [dbo].[EducationTrees] CHECK CONSTRAINT [FK_dbo.EducationTrees_dbo.EducationTrees_ParentEducationTreeId]
GO
ALTER TABLE [dbo].[EducationTrees]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EducationTrees_dbo.Lookups_LookupId_EducationTreeState] FOREIGN KEY([LookupId_EducationTreeState])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[EducationTrees] CHECK CONSTRAINT [FK_dbo.EducationTrees_dbo.Lookups_LookupId_EducationTreeState]
GO
ALTER TABLE [dbo].[EducationTrees_Lessons]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EducationTrees_Lessons_dbo.EducationTrees_EducationTreeId] FOREIGN KEY([EducationTreeId])
REFERENCES [dbo].[EducationTrees] ([Id])
GO
ALTER TABLE [dbo].[EducationTrees_Lessons] CHECK CONSTRAINT [FK_dbo.EducationTrees_Lessons_dbo.EducationTrees_EducationTreeId]
GO
ALTER TABLE [dbo].[EducationTrees_Lessons]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EducationTrees_Lessons_dbo.Lessons_LessonId] FOREIGN KEY([LessonId])
REFERENCES [dbo].[Lessons] ([Id])
GO
ALTER TABLE [dbo].[EducationTrees_Lessons] CHECK CONSTRAINT [FK_dbo.EducationTrees_Lessons_dbo.Lessons_LessonId]
GO
ALTER TABLE [dbo].[Exams]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Exams_dbo.EducationTrees_EducationTreeId] FOREIGN KEY([EducationTreeId])
REFERENCES [dbo].[EducationTrees] ([Id])
GO
ALTER TABLE [dbo].[Exams] CHECK CONSTRAINT [FK_dbo.Exams_dbo.EducationTrees_EducationTreeId]
GO
ALTER TABLE [dbo].[Exams]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Exams_dbo.EducationYears_EducationYearId] FOREIGN KEY([EducationYearId])
REFERENCES [dbo].[EducationYears] ([Id])
GO
ALTER TABLE [dbo].[Exams] CHECK CONSTRAINT [FK_dbo.Exams_dbo.EducationYears_EducationYearId]
GO
ALTER TABLE [dbo].[HistoryEducations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.HistoryEducations_dbo.EducationSubGroups_EducationSubGroup_Id] FOREIGN KEY([EducationSubGroup_Id])
REFERENCES [dbo].[EducationSubGroups] ([Id])
GO
ALTER TABLE [dbo].[HistoryEducations] CHECK CONSTRAINT [FK_dbo.HistoryEducations_dbo.EducationSubGroups_EducationSubGroup_Id]
GO
ALTER TABLE [dbo].[HistoryEducations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.HistoryEducations_dbo.EducationTrees_EducationTreeId] FOREIGN KEY([EducationTreeId])
REFERENCES [dbo].[EducationTrees] ([Id])
GO
ALTER TABLE [dbo].[HistoryEducations] CHECK CONSTRAINT [FK_dbo.HistoryEducations_dbo.EducationTrees_EducationTreeId]
GO
ALTER TABLE [dbo].[HistoryEducations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.HistoryEducations_dbo.Exams_ExamId] FOREIGN KEY([ExamId])
REFERENCES [dbo].[Exams] ([Id])
GO
ALTER TABLE [dbo].[HistoryEducations] CHECK CONSTRAINT [FK_dbo.HistoryEducations_dbo.Exams_ExamId]
GO
ALTER TABLE [dbo].[HistoryEducations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.HistoryEducations_dbo.Students_StudentId] FOREIGN KEY([StudentId])
REFERENCES [dbo].[Students] ([Id])
GO
ALTER TABLE [dbo].[HistoryEducations] CHECK CONSTRAINT [FK_dbo.HistoryEducations_dbo.Students_StudentId]
GO
ALTER TABLE [dbo].[HistoryEducations_Cities]  WITH CHECK ADD  CONSTRAINT [FK_dbo.HistoryEducations_Cities_dbo.Cities_CityId] FOREIGN KEY([CityId])
REFERENCES [dbo].[Cities] ([Id])
GO
ALTER TABLE [dbo].[HistoryEducations_Cities] CHECK CONSTRAINT [FK_dbo.HistoryEducations_Cities_dbo.Cities_CityId]
GO
ALTER TABLE [dbo].[HistoryEducations_Cities]  WITH CHECK ADD  CONSTRAINT [FK_dbo.HistoryEducations_Cities_dbo.HistoryEducations_HistoryEducationId] FOREIGN KEY([HistoryEducationId])
REFERENCES [dbo].[HistoryEducations] ([Id])
GO
ALTER TABLE [dbo].[HistoryEducations_Cities] CHECK CONSTRAINT [FK_dbo.HistoryEducations_Cities_dbo.HistoryEducations_HistoryEducationId]
GO
ALTER TABLE [dbo].[HistoryEducations_UniversityBranchs]  WITH CHECK ADD  CONSTRAINT [FK_dbo.HistoryEducations_UniversityBranchs_dbo.HistoryEducations_HistoryEducationId] FOREIGN KEY([HistoryEducationId])
REFERENCES [dbo].[HistoryEducations] ([Id])
GO
ALTER TABLE [dbo].[HistoryEducations_UniversityBranchs] CHECK CONSTRAINT [FK_dbo.HistoryEducations_UniversityBranchs_dbo.HistoryEducations_HistoryEducationId]
GO
ALTER TABLE [dbo].[HistoryEducations_UniversityBranchs]  WITH CHECK ADD  CONSTRAINT [FK_dbo.HistoryEducations_UniversityBranchs_dbo.UniversityBranches_UniversityBranchId] FOREIGN KEY([UniversityBranchId])
REFERENCES [dbo].[UniversityBranches] ([Id])
GO
ALTER TABLE [dbo].[HistoryEducations_UniversityBranchs] CHECK CONSTRAINT [FK_dbo.HistoryEducations_UniversityBranchs_dbo.UniversityBranches_UniversityBranchId]
GO
ALTER TABLE [dbo].[Lessons]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Lessons_dbo.Lookups_LookupId_Nezam] FOREIGN KEY([LookupId_Nezam])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[Lessons] CHECK CONSTRAINT [FK_dbo.Lessons_dbo.Lookups_LookupId_Nezam]
GO
ALTER TABLE [dbo].[Lessons_LessonDepartments]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Lessons_LessonDepartments_dbo.LessonDepartments_LessonDepartmentId] FOREIGN KEY([LessonDepartmentId])
REFERENCES [dbo].[LessonDepartments] ([Id])
GO
ALTER TABLE [dbo].[Lessons_LessonDepartments] CHECK CONSTRAINT [FK_dbo.Lessons_LessonDepartments_dbo.LessonDepartments_LessonDepartmentId]
GO
ALTER TABLE [dbo].[Lessons_LessonDepartments]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Lessons_LessonDepartments_dbo.Lessons_LessonId] FOREIGN KEY([LessonId])
REFERENCES [dbo].[Lessons] ([Id])
GO
ALTER TABLE [dbo].[Lessons_LessonDepartments] CHECK CONSTRAINT [FK_dbo.Lessons_LessonDepartments_dbo.Lessons_LessonId]
GO
ALTER TABLE [dbo].[Lessons_Users]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Lessons_Users_dbo.Lessons_UserId] FOREIGN KEY([LessonId])
REFERENCES [dbo].[Lessons] ([Id])
GO
ALTER TABLE [dbo].[Lessons_Users] CHECK CONSTRAINT [FK_dbo.Lessons_Users_dbo.Lessons_UserId]
GO
ALTER TABLE [dbo].[Lessons_Users]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Lessons_Users_dbo.Users_LessonId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Lessons_Users] CHECK CONSTRAINT [FK_dbo.Lessons_Users_dbo.Users_LessonId]
GO
ALTER TABLE [dbo].[QuestionAnswers]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionAnswers_dbo.Lookups_LookupId_AnswerType] FOREIGN KEY([LookupId_AnswerType])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[QuestionAnswers] CHECK CONSTRAINT [FK_dbo.QuestionAnswers_dbo.Lookups_LookupId_AnswerType]
GO
ALTER TABLE [dbo].[QuestionAnswers]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionAnswers_dbo.Questions_QuestionId] FOREIGN KEY([QuestionId])
REFERENCES [dbo].[Questions] ([Id])
GO
ALTER TABLE [dbo].[QuestionAnswers] CHECK CONSTRAINT [FK_dbo.QuestionAnswers_dbo.Questions_QuestionId]
GO
ALTER TABLE [dbo].[QuestionAnswers]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionAnswers_dbo.Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[QuestionAnswers] CHECK CONSTRAINT [FK_dbo.QuestionAnswers_dbo.Users_UserId]
GO
ALTER TABLE [dbo].[QuestionAnswers]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionAnswers_dbo.Writers_WriterId] FOREIGN KEY([WriterId])
REFERENCES [dbo].[Writers] ([Id])
GO
ALTER TABLE [dbo].[QuestionAnswers] CHECK CONSTRAINT [FK_dbo.QuestionAnswers_dbo.Writers_WriterId]
GO
ALTER TABLE [dbo].[QuestionAnswerViews]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionAnswerViews_dbo.QuestionAnswers_AnswerId] FOREIGN KEY([AnswerId])
REFERENCES [dbo].[QuestionAnswers] ([Id])
GO
ALTER TABLE [dbo].[QuestionAnswerViews] CHECK CONSTRAINT [FK_dbo.QuestionAnswerViews_dbo.QuestionAnswers_AnswerId]
GO
ALTER TABLE [dbo].[QuestionAnswerViews]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionAnswerViews_dbo.Students_StudentId] FOREIGN KEY([StudentId])
REFERENCES [dbo].[Students] ([Id])
GO
ALTER TABLE [dbo].[QuestionAnswerViews] CHECK CONSTRAINT [FK_dbo.QuestionAnswerViews_dbo.Students_StudentId]
GO
ALTER TABLE [dbo].[QuestionEquals]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionEquals_dbo.Questions_QuestionId1] FOREIGN KEY([QuestionId1])
REFERENCES [dbo].[Questions] ([Id])
GO
ALTER TABLE [dbo].[QuestionEquals] CHECK CONSTRAINT [FK_dbo.QuestionEquals_dbo.Questions_QuestionId1]
GO
ALTER TABLE [dbo].[QuestionEquals]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionEquals_dbo.Questions_QuestionId2] FOREIGN KEY([QuestionId2])
REFERENCES [dbo].[Questions] ([Id])
GO
ALTER TABLE [dbo].[QuestionEquals] CHECK CONSTRAINT [FK_dbo.QuestionEquals_dbo.Questions_QuestionId2]
GO
ALTER TABLE [dbo].[QuestionGroups]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionGroups_dbo.Lessons_LessonId] FOREIGN KEY([LessonId])
REFERENCES [dbo].[Lessons] ([Id])
GO
ALTER TABLE [dbo].[QuestionGroups] CHECK CONSTRAINT [FK_dbo.QuestionGroups_dbo.Lessons_LessonId]
GO
ALTER TABLE [dbo].[QuestionGroups]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionGroups_dbo.Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[QuestionGroups] CHECK CONSTRAINT [FK_dbo.QuestionGroups_dbo.Users_UserId]
GO
ALTER TABLE [dbo].[QuestionGroups_Questions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionGroups_Questions_dbo.QuestionGroups_QuestionGroupId] FOREIGN KEY([QuestionGroupId])
REFERENCES [dbo].[QuestionGroups] ([Id])
GO
ALTER TABLE [dbo].[QuestionGroups_Questions] CHECK CONSTRAINT [FK_dbo.QuestionGroups_Questions_dbo.QuestionGroups_QuestionGroupId]
GO
ALTER TABLE [dbo].[QuestionGroups_Questions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionGroups_Questions_dbo.Questions_QuestionId] FOREIGN KEY([QuestionId])
REFERENCES [dbo].[Questions] ([Id])
GO
ALTER TABLE [dbo].[QuestionGroups_Questions] CHECK CONSTRAINT [FK_dbo.QuestionGroups_Questions_dbo.Questions_QuestionId]
GO
ALTER TABLE [dbo].[QuestionJudges]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionJudges_dbo.Lookups_Lookup_QuestionHardnessType_Id] FOREIGN KEY([LookupId_QuestionHardnessType])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[QuestionJudges] CHECK CONSTRAINT [FK_dbo.QuestionJudges_dbo.Lookups_Lookup_QuestionHardnessType_Id]
GO
ALTER TABLE [dbo].[QuestionJudges]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionJudges_dbo.Lookups_Lookup_RepeatnessType_Id] FOREIGN KEY([LookupId_RepeatnessType])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[QuestionJudges] CHECK CONSTRAINT [FK_dbo.QuestionJudges_dbo.Lookups_Lookup_RepeatnessType_Id]
GO
ALTER TABLE [dbo].[QuestionJudges]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionJudges_dbo.Lookups_LookupId_QuestionRank] FOREIGN KEY([LookupId_QuestionRank])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[QuestionJudges] CHECK CONSTRAINT [FK_dbo.QuestionJudges_dbo.Lookups_LookupId_QuestionRank]
GO
ALTER TABLE [dbo].[QuestionJudges]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionJudges_dbo.Lookups_LookupId_ReasonProblem] FOREIGN KEY([LookupId_ReasonProblem])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[QuestionJudges] CHECK CONSTRAINT [FK_dbo.QuestionJudges_dbo.Lookups_LookupId_ReasonProblem]
GO
ALTER TABLE [dbo].[QuestionJudges]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionJudges_dbo.Lookups_LookupId_WhereProblem] FOREIGN KEY([LookupId_WhereProblem])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[QuestionJudges] CHECK CONSTRAINT [FK_dbo.QuestionJudges_dbo.Lookups_LookupId_WhereProblem]
GO
ALTER TABLE [dbo].[QuestionJudges]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionJudges_dbo.Questions_QuestionId] FOREIGN KEY([QuestionId])
REFERENCES [dbo].[Questions] ([Id])
GO
ALTER TABLE [dbo].[QuestionJudges] CHECK CONSTRAINT [FK_dbo.QuestionJudges_dbo.Questions_QuestionId]
GO
ALTER TABLE [dbo].[QuestionJudges]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionJudges_dbo.Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[QuestionJudges] CHECK CONSTRAINT [FK_dbo.QuestionJudges_dbo.Users_UserId]
GO
ALTER TABLE [dbo].[QuestionOptions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionOptions_dbo.Questions_QuestionId] FOREIGN KEY([QuestionId])
REFERENCES [dbo].[Questions] ([Id])
GO
ALTER TABLE [dbo].[QuestionOptions] CHECK CONSTRAINT [FK_dbo.QuestionOptions_dbo.Questions_QuestionId]
GO
ALTER TABLE [dbo].[Questions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Questions_dbo.Lookups_LookupId_AreaType] FOREIGN KEY([LookupId_AreaType])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[Questions] CHECK CONSTRAINT [FK_dbo.Questions_dbo.Lookups_LookupId_AreaType]
GO
ALTER TABLE [dbo].[Questions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Questions_dbo.Lookups_LookupId_AuthorType] FOREIGN KEY([LookupId_AuthorType])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[Questions] CHECK CONSTRAINT [FK_dbo.Questions_dbo.Lookups_LookupId_AuthorType]
GO
ALTER TABLE [dbo].[Questions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Questions_dbo.Lookups_LookupId_QuestionHardnessType] FOREIGN KEY([LookupId_QuestionHardnessType])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[Questions] CHECK CONSTRAINT [FK_dbo.Questions_dbo.Lookups_LookupId_QuestionHardnessType]
GO
ALTER TABLE [dbo].[Questions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Questions_dbo.Lookups_LookupId_QuestionRank] FOREIGN KEY([LookupId_QuestionRank])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[Questions] CHECK CONSTRAINT [FK_dbo.Questions_dbo.Lookups_LookupId_QuestionRank]
GO
ALTER TABLE [dbo].[Questions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Questions_dbo.Lookups_LookupId_QuestionType] FOREIGN KEY([LookupId_QuestionType])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[Questions] CHECK CONSTRAINT [FK_dbo.Questions_dbo.Lookups_LookupId_QuestionType]
GO
ALTER TABLE [dbo].[Questions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Questions_dbo.Lookups_LookupId_RepeatnessType] FOREIGN KEY([LookupId_RepeatnessType])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[Questions] CHECK CONSTRAINT [FK_dbo.Questions_dbo.Lookups_LookupId_RepeatnessType]
GO
ALTER TABLE [dbo].[Questions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Questions_dbo.Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Questions] CHECK CONSTRAINT [FK_dbo.Questions_dbo.Users_UserId]
GO
ALTER TABLE [dbo].[Questions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Questions_dbo.Writers_WriterId] FOREIGN KEY([WriterId])
REFERENCES [dbo].[Writers] ([Id])
GO
ALTER TABLE [dbo].[Questions] CHECK CONSTRAINT [FK_dbo.Questions_dbo.Writers_WriterId]
GO
ALTER TABLE [dbo].[Questions_Boxes]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Questions_Boxes_dbo.Boxes_BoxId] FOREIGN KEY([BoxId])
REFERENCES [dbo].[Boxes] ([Id])
GO
ALTER TABLE [dbo].[Questions_Boxes] CHECK CONSTRAINT [FK_dbo.Questions_Boxes_dbo.Boxes_BoxId]
GO
ALTER TABLE [dbo].[Questions_Boxes]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Questions_Boxes_dbo.Questions_QuestionId] FOREIGN KEY([QuestionId])
REFERENCES [dbo].[Questions] ([Id])
GO
ALTER TABLE [dbo].[Questions_Boxes] CHECK CONSTRAINT [FK_dbo.Questions_Boxes_dbo.Questions_QuestionId]
GO
ALTER TABLE [dbo].[Questions_Tags]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Questions_Tags_dbo.Questions_QuestionId] FOREIGN KEY([QuestionId])
REFERENCES [dbo].[Questions] ([Id])
GO
ALTER TABLE [dbo].[Questions_Tags] CHECK CONSTRAINT [FK_dbo.Questions_Tags_dbo.Questions_QuestionId]
GO
ALTER TABLE [dbo].[Questions_Tags]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Questions_Tags_dbo.Tags_TagId] FOREIGN KEY([TagId])
REFERENCES [dbo].[Tags] ([Id])
GO
ALTER TABLE [dbo].[Questions_Tags] CHECK CONSTRAINT [FK_dbo.Questions_Tags_dbo.Tags_TagId]
GO
ALTER TABLE [dbo].[Ratios]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Ratios_dbo.EducationSubGroups_EducationSubGroupId] FOREIGN KEY([EducationSubGroupId])
REFERENCES [dbo].[EducationSubGroups] ([Id])
GO
ALTER TABLE [dbo].[Ratios] CHECK CONSTRAINT [FK_dbo.Ratios_dbo.EducationSubGroups_EducationSubGroupId]
GO
ALTER TABLE [dbo].[Ratios]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Ratios_dbo.Lessons_LessonId] FOREIGN KEY([LessonId])
REFERENCES [dbo].[Lessons] ([Id])
GO
ALTER TABLE [dbo].[Ratios] CHECK CONSTRAINT [FK_dbo.Ratios_dbo.Lessons_LessonId]
GO
ALTER TABLE [dbo].[Resumes]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Resumes_dbo.Cities_CityId] FOREIGN KEY([CityId])
REFERENCES [dbo].[Cities] ([Id])
GO
ALTER TABLE [dbo].[Resumes] CHECK CONSTRAINT [FK_dbo.Resumes_dbo.Cities_CityId]
GO
ALTER TABLE [dbo].[Students]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Students_dbo.Users_Id] FOREIGN KEY([Id])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Students] CHECK CONSTRAINT [FK_dbo.Students_dbo.Users_Id]
GO
ALTER TABLE [dbo].[Teachers]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Teachers_dbo.Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Teachers] CHECK CONSTRAINT [FK_dbo.Teachers_dbo.Users_UserId]
GO
ALTER TABLE [dbo].[Topics]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Topics_dbo.Lessons_LessonId] FOREIGN KEY([LessonId])
REFERENCES [dbo].[Lessons] ([Id])
GO
ALTER TABLE [dbo].[Topics] CHECK CONSTRAINT [FK_dbo.Topics_dbo.Lessons_LessonId]
GO
ALTER TABLE [dbo].[Topics]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Topics_dbo.Lookups_LookupId_AreaType] FOREIGN KEY([LookupId_AreaType])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[Topics] CHECK CONSTRAINT [FK_dbo.Topics_dbo.Lookups_LookupId_AreaType]
GO
ALTER TABLE [dbo].[Topics]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Topics_dbo.Lookups_LookupId_HardnessType] FOREIGN KEY([LookupId_HardnessType])
REFERENCES [dbo].[Lookups] ([Id])
GO
ALTER TABLE [dbo].[Topics] CHECK CONSTRAINT [FK_dbo.Topics_dbo.Lookups_LookupId_HardnessType]
GO
ALTER TABLE [dbo].[Topics]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Topics_dbo.Topics_ParentTopicId] FOREIGN KEY([ParentTopicId])
REFERENCES [dbo].[Topics] ([Id])
GO
ALTER TABLE [dbo].[Topics] CHECK CONSTRAINT [FK_dbo.Topics_dbo.Topics_ParentTopicId]
GO
ALTER TABLE [dbo].[Topics_EducationBooks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Topics_EducationBooks_dbo.EducationBooks_EducationBookId] FOREIGN KEY([EducationBookId])
REFERENCES [dbo].[EducationBooks] ([Id])
GO
ALTER TABLE [dbo].[Topics_EducationBooks] CHECK CONSTRAINT [FK_dbo.Topics_EducationBooks_dbo.EducationBooks_EducationBookId]
GO
ALTER TABLE [dbo].[Topics_EducationBooks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Topics_EducationBooks_dbo.Topics_TopicId] FOREIGN KEY([TopicId])
REFERENCES [dbo].[Topics] ([Id])
GO
ALTER TABLE [dbo].[Topics_EducationBooks] CHECK CONSTRAINT [FK_dbo.Topics_EducationBooks_dbo.Topics_TopicId]
GO
ALTER TABLE [dbo].[Topics_Questions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Topics_Questions_dbo.Questions_QuestionId] FOREIGN KEY([QuestionId])
REFERENCES [dbo].[Questions] ([Id])
GO
ALTER TABLE [dbo].[Topics_Questions] CHECK CONSTRAINT [FK_dbo.Topics_Questions_dbo.Questions_QuestionId]
GO
ALTER TABLE [dbo].[Topics_Questions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Topics_Questions_dbo.Topics_TopicId] FOREIGN KEY([TopicId])
REFERENCES [dbo].[Topics] ([Id])
GO
ALTER TABLE [dbo].[Topics_Questions] CHECK CONSTRAINT [FK_dbo.Topics_Questions_dbo.Topics_TopicId]
GO
ALTER TABLE [dbo].[UniversityBranches]  WITH CHECK ADD  CONSTRAINT [FK_dbo.UniversityBranches_dbo.EducationSubGroups_EducationSubGroupId] FOREIGN KEY([EducationSubGroupId])
REFERENCES [dbo].[EducationSubGroups] ([Id])
GO
ALTER TABLE [dbo].[UniversityBranches] CHECK CONSTRAINT [FK_dbo.UniversityBranches_dbo.EducationSubGroups_EducationSubGroupId]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Users_dbo.Cities_CityId] FOREIGN KEY([CityId])
REFERENCES [dbo].[Cities] ([Id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_dbo.Users_dbo.Cities_CityId]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Users_dbo.Roles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Roles] ([Id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_dbo.Users_dbo.Roles_RoleId]
GO
ALTER TABLE [dbo].[Writers]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Writers_dbo.Users_User_Id] FOREIGN KEY([User_Id])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Writers] CHECK CONSTRAINT [FK_dbo.Writers_dbo.Users_User_Id]
GO
/****** Object:  StoredProcedure [dbo].[spUpdateAdminRole]    Script Date: 14/07/1398 04:54:34 ب.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateAdminRole]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   	update Roles set SumOfActionBit = (select dbo.fnGetAdminAcceess()) where id = 1
END

GO
