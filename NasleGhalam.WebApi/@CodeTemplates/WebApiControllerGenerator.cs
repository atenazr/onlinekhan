﻿using System.Web.Http;
using NasleGhalam.Common;
using NasleGhalam.ServiceLayer.Services;
using NasleGhalam.WebApi.FilterAttribute;
using NasleGhalam.ViewModels.UniversityBranch;
using NasleGhalam.WebApi.Extentions;

namespace NasleGhalam.WebApi.Controllers
{
    /// <inheritdoc />
	/// <author>
	///     name: 
	///     date: 
	/// </author>
	public class UniversityBranchController : ApiController
	{
        private readonly UniversityBranchService _universityBranchService;
		public UniversityBranchController(UniversityBranchService universityBranchService)
        {
            _universityBranchService = universityBranchService;
        }


		[HttpGet, CheckUserAccess(ActionBits.UniversityBranchReadAccess)]
        public IHttpActionResult GetAll()
        {
            return Ok(_universityBranchService.GetAll());
        }


		[HttpGet, CheckUserAccess(ActionBits.UniversityBranchReadAccess)]
        public IHttpActionResult GetById(int id)
        {
            var universityBranch = _universityBranchService.GetById(id);
            if (universityBranch == null)
            {
                return NotFound();
            }
            return Ok(universityBranch);
        }


		[HttpPost]
        [CheckUserAccess(ActionBits.UniversityBranchCreateAccess)]
        [CheckModelValidation]
        public IHttpActionResult Create(UniversityBranchViewModel universityBranchViewModel)
        {
            var msgRes = _universityBranchService.Create(universityBranchViewModel);
            return Ok(msgRes);
        }


        [HttpPost]
        [CheckUserAccess(ActionBits.UniversityBranchUpdateAccess)]
        [CheckModelValidation]
        public IHttpActionResult Update(UniversityBranchViewModel universityBranchViewModel)
        {
            var msgRes = _universityBranchService.Update(universityBranchViewModel);
            return Ok(msgRes);
        }


        [HttpPost, CheckUserAccess(ActionBits.UniversityBranchDeleteAccess)]
        public IHttpActionResult Delete(int id)
        {
            var msgRes = _universityBranchService.Delete(id);
            return Ok(msgRes);
        }
	}
}
