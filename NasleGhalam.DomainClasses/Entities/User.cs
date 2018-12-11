﻿using System;
using System.Collections.Generic;

namespace NasleGhalam.DomainClasses.Entities
{
    public class User
    {
        public User()
        {
            Teachers = new HashSet<Teacher>();
            Questions = new HashSet<Question>();
            QuestionAnswers = new HashSet<QuestionAnswer>();
        }
        public int Id { get; set; }

        public string Name { get; set; }

        public string Family { get; set; }

        public string Username { get; set; }

        public string Password { get; set; }

        public string NationalNo { get; set; }

        public bool Gender { get; set; }

        public string Phone { get; set; }

        public string Mobile { get; set; }

        public bool IsAdmin { get; set; }

        public bool IsActive { get; set; }

        public DateTime LastLogin { get; set; }

        public Role Role { get; set; }

        public int RoleId { get; set; }

        public City City { get; set; }

        public int CityId { get; set; }

        public Student Student { get; set; }

        public ICollection<Teacher> Teachers { get; set; }

        public ICollection<Question> Questions { get; set; }

        public ICollection<QuestionAnswer> QuestionAnswers { get; set; }
    }
}
