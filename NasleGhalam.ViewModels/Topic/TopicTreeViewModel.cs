﻿using System.Collections.Generic;

namespace NasleGhalam.ViewModels.Topic
{
    public class TopicTreeViewModel
    {
        public int Id { get; set; }

        public string lable { get; set; }

        public IEnumerable<TopicTreeViewModel> children { get; set; }

    }
}
