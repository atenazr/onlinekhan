﻿using System.Web.Http;
using NasleGhalam.Common;
using NasleGhalam.ServiceLayer.Services;
using NasleGhalam.WebApi.FilterAttribute;
using NasleGhalam.ViewModels.EducationTree;
using NasleGhalam.WebApi.Extentions;

namespace NasleGhalam.WebApi.Controllers
{
    /// <inheritdoc />
	/// <author>
	///     name: 
	///     date: 
	/// </author>
	public class EducationTreeController : ApiController
	{
        private readonly EducationTreeService _educationTreeService;
		public EducationTreeController(EducationTreeService educationTreeService)
        {
            _educationTreeService = educationTreeService;
        }


		[HttpGet, CheckUserAccess(ActionBits.EducationTreeReadAccess)]
        public IHttpActionResult GetAll()
        {
            return Ok(_educationTreeService.GetAll());
        }


		[HttpGet, CheckUserAccess(ActionBits.EducationTreeReadAccess)]
        public IHttpActionResult GetById(int id)
        {
            var educationTree = _educationTreeService.GetById(id);
            if (educationTree == null)
            {
                return NotFound();
            }
            return Ok(educationTree);
        }


		[HttpPost]
        [CheckUserAccess(ActionBits.EducationTreeCreateAccess)]
        [CheckModelValidation]
        public IHttpActionResult Create(EducationTreeViewModel educationTreeViewModel)
        {
            return Ok(_educationTreeService.Create(educationTreeViewModel));
        }


        [HttpPost]
        [CheckUserAccess(ActionBits.EducationTreeUpdateAccess)]
        [CheckModelValidation]
        public IHttpActionResult Update(EducationTreeViewModel educationTreeViewModel)
        {
            return Ok(_educationTreeService.Update(educationTreeViewModel));
        }


        [HttpPost, CheckUserAccess(ActionBits.EducationTreeDeleteAccess)]
        public IHttpActionResult Delete(int id)
        {
            return Ok(_educationTreeService.Delete(id));
        }
	}
}
