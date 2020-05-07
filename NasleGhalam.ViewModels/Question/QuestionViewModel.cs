﻿using System;
using System.Collections.Generic;
using NasleGhalam.Common;
using NasleGhalam.ViewModels.Lookup;
using NasleGhalam.ViewModels.QuestionAnswer;
using NasleGhalam.ViewModels.QuestionOption;
using NasleGhalam.ViewModels.Tag;
using NasleGhalam.ViewModels.Topic;
using NasleGhalam.ViewModels.User;
using NasleGhalam.ViewModels.Writer;

namespace NasleGhalam.ViewModels.Question
{
    public class QuestionViewModel 
    {
        public int Id { get; set; }

        public int Code => Id;

        public string Context { get; set; }

        public int QuestionNumber { get; set; }

        public int QuestionPoint { get; set; }

        public bool UseEvaluation { get; set; }

        public bool IsStandard { get; set; }
        public bool IsDelete { get; set; }

        public short ResponseSecond { get; set; }

        public string Description { get; set; }

        public string FileName { get; set; }

        public DateTime InsertDateTime { get; set; }

        public int UserId { get; set; }

        public bool IsActive { get; set; }
        
        public bool IsHybrid { get; set; }

        public int AnswerNumber { get; set; }

        
        public string TopicAnswer { get; set; }

        public string QuestionWordPath => $"/Api/Question/GetWordFile/{FileName}".ToFullRelativePath();

        public string QuestionPicturePath => $"/Api/Question/GetPictureFile/{FileName}".ToFullRelativePath();

        public int LookupId_QuestionType { get; set; }

        public int LookupId_QuestionHardnessType { get; set; }

        public int LookupId_RepeatnessType { get; set; }

        public int LookupId_AuthorType { get; set; }

        public int LookupId_AreaType { get; set; }
        public int LookupId_QuestionRank { get; set; }
        

        public int WriterId { get; set; }

        public WriterViewModel Writer { get; set; }



        public  LookupViewModel Lookup_AreaType { get; set; }

        public List<QuestionOptionViewModel> QuestionOptions { get; set; } = new List<QuestionOptionViewModel>();

        public List<QuestionAnswerViewModel> QuestionAnswers { get; set; } = new List<QuestionAnswerViewModel>();

        public List<TopicViewModel> Topics { get; set; } = new List<TopicViewModel>();

        public List<TagViewModel> Tags { get; set; } = new List<TagViewModel>();

        public List<UserViewModel> Supervisors { get; set; } = new List<UserViewModel>();

    }
}
