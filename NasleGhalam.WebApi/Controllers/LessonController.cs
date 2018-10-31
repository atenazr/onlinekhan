﻿using System.Web.Http;
using NasleGhalam.Common;
using NasleGhalam.ServiceLayer.Services;
using NasleGhalam.WebApi.FilterAttribute;
using NasleGhalam.ViewModels.Lesson;
using NasleGhalam.WebApi.Extentions;
using Newtonsoft.Json;

namespace NasleGhalam.WebApi.Controllers
{
    /// <inheritdoc />
    /// <author>
    ///     name: حسین شری
    ///     date: 9/8/97
    /// </author>
    public class LessonController : ApiController
    {
        private readonly LessonService _lessonService;
        public LessonController(LessonService lessonService)
        {
            _lessonService = lessonService;
        }


        [HttpGet, CheckUserAccess(ActionBits.LessonReadAccess)]
        public IHttpActionResult GetAll()
        {
            return Ok(_lessonService.GetAll());
        }


        [HttpGet, CheckUserAccess(ActionBits.LessonReadAccess)]
        public string GetById(int id)
        {
            var lesson = _lessonService.GetById(id);
            if (lesson == null)
            {
                return null;
            }

            var resualt = JsonConvert.SerializeObject(lesson, new JsonSerializerSettings()
            {
                ReferenceLoopHandling = ReferenceLoopHandling.Ignore,
               
            });

            return resualt;

     
       

    }


        [HttpPost]
        [CheckUserAccess(ActionBits.LessonCreateAccess)]
        [CheckModelValidation]
        public IHttpActionResult Create(LessonCreateViewModel lessonViewModel)
        {
            return Ok(_lessonService.Create(lessonViewModel));
        }


        [HttpPost]
        [CheckUserAccess(ActionBits.LessonUpdateAccess)]
        [CheckModelValidation]
        public IHttpActionResult Update(LessonViewModel lessonViewModel)
        {
            return Ok(_lessonService.Update(lessonViewModel));
        }


        [HttpPost, CheckUserAccess(ActionBits.LessonDeleteAccess)]
        public IHttpActionResult Delete(int id)
        {
            return Ok(_lessonService.Delete(id));
        }
    }
}
