﻿using System.Collections.Generic;

namespace NasleGhalam.DomainClasses.Entities
{
    public class EducationBook
    {
        public EducationBook()
        {
            Topics = new HashSet<Topic>();
            AxillaryBooks = new HashSet<AxillaryBook>();
        }
        public int Id { get; set; }

        public string Name { get; set; }

        public short PublishYear { get; set; }

        public bool IsExamSource { get; set; }

        public bool IsActive  { get; set; }

        public bool IsChanged { get; set; }

        public int GradeLevelId { get; set; }

        public GradeLevel GradeLevel { get; set; }

        public int EducationGroup_LessonId { get; set; }

        public EducationGroup_Lesson EducationGroup_Lesson { get; set; }

        public virtual ICollection<Topic> Topics { get; set; }

        public virtual ICollection<AxillaryBook> AxillaryBooks { get; set; }
    }
}
