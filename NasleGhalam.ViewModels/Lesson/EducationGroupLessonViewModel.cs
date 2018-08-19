﻿using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using NasleGhalam.ViewModels._Attributes;

namespace NasleGhalam.ViewModels.Lesson
{
    public class EducationGroupLessonViewModel
    {
        [Display(Name = "گروه آموزشی")]
        [RequiredDdlValidator(invalidValue: "0", ErrorMessageResourceType = typeof(NasleGhalam.ViewModels.ErrorResources), ErrorMessageResourceName = "RequiredDll")]
        public int EducationGroupId { get; set; }


        public string EducationGroupName { get; set; }


        public bool IsChecked { get; set; }

        


        public IEnumerable<RatioLessonViewModel> SubGroups { get; set; }   

    }
}
