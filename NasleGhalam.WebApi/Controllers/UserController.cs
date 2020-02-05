﻿using System;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Web;
using System.Web.Http;
using NasleGhalam.Common;
using NasleGhalam.ServiceLayer.Services;
using NasleGhalam.ViewModels.User;
using NasleGhalam.WebApi.Extensions;
using NasleGhalam.WebApi.FilterAttribute;

namespace NasleGhalam.WebApi.Controllers
{
    /// <inheritdoc />
    /// <author>
    ///     name: علیرضا اعتمادی
    ///     date: 1397.03.28
    /// </author>
    public class UserController : ApiController
    {
        private readonly UserService _userService;
        public UserController(UserService userService)
        {
            _userService = userService;
        }

        [HttpGet, CheckUserAccess(ActionBits.UserReadAccess)]
        public IHttpActionResult GetAll(UserType userType = UserType.Organ)
        {
            return Ok(_userService.GetAll(Request.GetRoleLevel(), userType));
        }

        [HttpGet, CheckUserAccess(ActionBits.WriterCreateAccess, ActionBits.WriterCreateAccess)]
        public IHttpActionResult Search(string nationalNo, string family, string name)
        {
            return Ok(_userService.Search(nationalNo, family, name, Request.GetRoleLevel()));
        }

        [HttpGet, CheckUserAccess(ActionBits.UserReadAccess)]
        public IHttpActionResult GetById(int id)
        {
            var user = _userService.GetById(id, Request.GetRoleLevel());
            if (user == null)
            {
                return NotFound();
            }
            return Ok(user);
        }

        [HttpPost]
        [CheckModelValidation]
        [CheckImageValidationNotRequired("img", 1024)]
        public IHttpActionResult Register([FromUri]UserCreateViewModel userViewModel)
        {
            var postedFile = HttpContext.Current.Request.Files.Get("img");
            if (postedFile != null && postedFile.ContentLength > 0)
            {
                /*{Path.GetExtension(postedFile.FileName)}*/
                userViewModel.ProfilePic = $"{Guid.NewGuid()}";
            }

            var msgRes = _userService.Register(userViewModel);
            if (msgRes.MessageType == MessageType.Success && !string.IsNullOrEmpty(userViewModel.ProfilePic))
            {
                postedFile?.SaveAs($"{SitePath.UserProfileRelPath}{userViewModel.ProfilePic}{Path.GetExtension(postedFile.FileName)}".ToAbsolutePath());
            }
            return Ok(msgRes);
        }


        [HttpPost]
        [CheckUserAccess(ActionBits.UserCreateAccess)]
        [CheckModelValidation]
        public IHttpActionResult Create(UserCreateViewModel userViewModel)
        {
            var msgRes = _userService.Create(userViewModel, Request.GetRoleLevel());
            return Ok(msgRes);
        }

        [HttpPost]
        [CheckUserAccess(ActionBits.UserUpdateAccess)]
        [CheckModelValidation]
        public IHttpActionResult Update(UserUpdateViewModel userViewModel)
        {
            var msgRes = _userService.Update(userViewModel, Request.GetRoleLevel());
            return Ok(msgRes);
        }

        [HttpPost, CheckUserAccess(ActionBits.UserDeleteAccess)]
        public IHttpActionResult Delete(int id)
        {
            var msgRes = _userService.Delete(id, Request.GetRoleLevel());
            return Ok(msgRes);
        }

        [HttpPost]
        public IHttpActionResult Login(LoginViewModel login)
        {

            return Ok(_userService.Login(login));
        }

        [HttpGet]
        public HttpResponseMessage GetPictureFile(string id = null)
        {
            var stream = new MemoryStream();
            id += ".png";
            var filestraem = File.OpenRead(SitePath.GetUserAbsPath(id));
            filestraem.CopyTo(stream);

            var result = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new ByteArrayContent(stream.ToArray())
            };
            result.Content.Headers.ContentDisposition =
                new ContentDispositionHeaderValue("attachment")
                {
                    FileName = id
                };
            result.Content.Headers.ContentType =
                new MediaTypeHeaderValue("application/octet-stream");
            filestraem.Dispose();
            stream.Dispose();
            return result;
        }
    }
}
