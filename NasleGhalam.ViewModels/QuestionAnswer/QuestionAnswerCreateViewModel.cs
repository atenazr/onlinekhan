﻿using System.ComponentModel.DataAnnotations;

namespace NasleGhalam.ViewModels.QuestionAnswer
{
    public class QuestionAnswerCreateViewModel
    {
        [Display(Name = "عنوان")]
        public string Title { get; set; }


        [Display(Name = "متن")]
        public string Context { get; set; }


        [Display(Name = "درس")]
        public string LessonName { get; set; }

        [Display(Name = "توضیحات")]
        public string Description { get; set; }

        [Display(Name = "نویسنده")]
        public int WriterId { get; set; }

     

        [Display(Name = "اصلی")]
        public bool IsMaster { get; set; }

        [Display(Name = "فعال")]
        public bool IsActive { get; set; }

        [Display(Name = "کاربر")]
        public int UserId { get; set; }

        [Display(Name = "سوال")]
        public int QuestionId { get; set; }

        [Display(Name = "نوع جواب")]
        public int LookupId_AnswerType { get; set; }

        public string FilePath { get; set; }
        public string FileName { get; set; }


    }
}
