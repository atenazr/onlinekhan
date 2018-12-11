﻿using System.ComponentModel.DataAnnotations;

namespace NasleGhalam.ViewModels.Role
{
    public class RoleViewModel
    {
        public int Id { get; set; }


        [Required(ErrorMessageResourceType = typeof(ErrorResources), ErrorMessageResourceName = "Required")]
        [MaxLength(50, ErrorMessageResourceType = typeof(ErrorResources), ErrorMessageResourceName = "MaxLen")]
        [Display(Name = "نام")]
        public string Name { get; set; }


        [Required(ErrorMessageResourceType = typeof(ErrorResources), ErrorMessageResourceName = "Required")]
        [Display(Name = "سطح")]
        public byte Level { get; set; }


        public string SumOfActionBit { get; set; }
    }
}
