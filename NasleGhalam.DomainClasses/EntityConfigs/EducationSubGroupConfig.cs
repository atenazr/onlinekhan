﻿using System.Data.Entity.ModelConfiguration;
using NasleGhalam.DomainClasses.Entities;

namespace NasleGhalam.DomainClasses.EntityConfigs
{
    public class EducationSubGroupConfig : EntityTypeConfiguration<EducationSubGroup>
    {
        public EducationSubGroupConfig()
        {
            this.HasKey(x => x.Id);
            this.Property(x => x.Name).HasMaxLength(50).IsRequired();
        }
    }
}
