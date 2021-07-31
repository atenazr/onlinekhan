﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NasleGhalam.DomainClasses.Entities
{
    public class StudentMajorlist
    {

        public StudentMajorlist()
        {
            Majors = new HashSet<Majors>();
        }
        public int Id { get; set; }
        public string Title { get; set; }
        public int StudentId { get; set; }
        public DateTime CreationDate { get; set; }
        public Student Student { get; set; }
        public ICollection<Majors> Majors { get; set; }
    }
}
