﻿using System.ComponentModel.DataAnnotations;

namespace NasleGhalam.ViewModels.Lesson
{
    public class LessonViewModel
    {
        public int Id { get; set; }


        [Display(Name = "نام")]
        public string Name { get; set; }


        [Display(Name = "اختصاصی")]
        public bool IsMain { get; set; }
    }
}
