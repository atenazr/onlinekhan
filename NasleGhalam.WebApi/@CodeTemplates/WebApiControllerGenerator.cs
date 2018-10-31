﻿using System.Web.Http;
using NasleGhalam.Common;
using NasleGhalam.ServiceLayer.Services;
using NasleGhalam.WebApi.FilterAttribute;
using NasleGhalam.ViewModels.Lesson;
using NasleGhalam.WebApi.Extentions;

namespace NasleGhalam.WebApi.Controllers
{
    /// <inheritdoc />
	/// <author>
	///     name: 
	///     date: 
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
        public IHttpActionResult GetById(int id)
        {
            var lesson = _lessonService.GetById(id);
            if (lesson == null)
            {
                return NotFound();
            }
            return Ok(lesson);
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
        public IHttpActionResult Update(LessonUpdateViewModel lessonViewModel)
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
