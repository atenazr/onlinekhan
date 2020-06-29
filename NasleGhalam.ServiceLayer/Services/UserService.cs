﻿using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using AutoMapper;
using NasleGhalam.Common;
using NasleGhalam.DataAccess.Context;
using NasleGhalam.DomainClasses.Entities;
using NasleGhalam.ServiceLayer.Configs;
using NasleGhalam.ServiceLayer.Jwt;
using NasleGhalam.ViewModels.User;

namespace NasleGhalam.ServiceLayer.Services
{
    public class UserService
    {
        private const string Title = "کاربر";
        private readonly IUnitOfWork _uow;
        private readonly IDbSet<User> _users;
        private readonly IDbSet<Student> _students;
        private readonly IDbSet<Teacher> _teachers;

        private readonly Lazy<RoleService> _roleService;
        private readonly Lazy<ActionService> _actionService;

        public UserService(IUnitOfWork uow,
            Lazy<RoleService> roleService,
            Lazy<ActionService> actionService)
        {
            _uow = uow;
            _users = _uow.Set<User>();
            _students = _uow.Set<Student>();
            _teachers = _uow.Set<Teacher>();
            _roleService = roleService;
            _actionService = actionService;
        }

    

        /// <summary>
        /// گرفتن  کاربر با آی دی
        /// </summary>
        /// <param name="id"></param>
        /// <param name="userRoleLevel"></param>
        /// <returns></returns>
        public UserViewModel GetById(int id, byte userRoleLevel)
        {
            return _users
                .Include(current => current.City)
                .Include(current => current.Role)
                .Where(current => current.Id == id)
                .Where(current => current.Role.Level > userRoleLevel)
                .Where(current => current.Role.UserType == UserType.Organ)
                .AsNoTracking()
                .AsEnumerable()
                .Select(Mapper.Map<UserViewModel>)
                .FirstOrDefault();
        }

        /// <summary>
        /// گرفتن  کاربر با آی دی
        /// </summary>
        /// <param name="id"></param>
        /// <param name="userRoleLevel"></param>
        /// <returns></returns>
        public UserViewModel GetByIdPrivate(int id, byte userRoleLevel)
        {
            return _users
                .Include(current => current.City)
                .Include(current => current.Role)
                .Where(current => current.Id == id)
                .AsNoTracking()
                .AsEnumerable()
                .Select(Mapper.Map<UserViewModel>)
                .FirstOrDefault();
        }


        /// <summary>
        /// گرفتن همه کاربر های ناظر
        /// </summary>
        /// <param name="userRoleLevel"></param>
        /// <param name="userType"></param>
        /// <returns></returns>
        public IList<UserViewModel> GetAllSupervisors()
        {
            return _users
                .Where(current => current.Role.Level == 3)
                .AsNoTracking()
                .AsEnumerable()
                .Select(Mapper.Map<UserViewModel>)
                .ToList();
        }


        /// <summary>
        /// گرفتن همه کاربر ها
        /// </summary>
        /// <param name="userRoleLevel"></param>
        /// <param name="userType"></param>
        /// <returns></returns>
        public IList<UserViewModel> GetAll(byte userRoleLevel, UserType userType)
        {
            return _users
                .Include(current => current.City)
                .Include(current => current.Role)
                .Where(current => current.Role.Level > userRoleLevel)
                .Where(current => current.Role.UserType == UserType.Organ)
                .AsNoTracking()
                .AsEnumerable()
                .Select(Mapper.Map<UserViewModel>)
                .ToList();
        }

        /// <summary>
        /// جستجوی همه کاربر ها
        /// </summary>
        /// <param name="userRoleLevel"></param>
        /// <param name="nationalNo"></param>
        /// <param name="family"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        public IList<UserViewModel> Search(string nationalNo, string family, string name, byte userRoleLevel)
        {
            return _users
                .Where(current => current.Role.Level > userRoleLevel)
                .Where(current => string.IsNullOrEmpty(nationalNo) || current.NationalNo.Contains(nationalNo))
                .Where(current => string.IsNullOrEmpty(family) || current.Family.Contains(family))
                .Where(current => string.IsNullOrEmpty(name) || current.Name.Contains(name))
                .Take(SiteConfig.MaxDdlCount)
                .AsNoTracking()
                .AsEnumerable()
                .Select(Mapper.Map<UserViewModel>)
                .ToList();
        }


        /// <summary>
        /// ثبت نام کاربر
        /// </summary>
        /// <param name="userViewModel"></param>
        /// <param name="userRoleLevel"></param>
        /// <returns></returns>
        public ClientMessageResult Register(UserCreateViewModel userViewModel)
        {
            var user = Mapper.Map<User>(userViewModel);
            if (userViewModel.RoleId == -1)
            {
                //دبیر
                //var teacher = Mapper.Map<Teacher>(userViewModel);
                var teacher = new Teacher();
                teacher.User = user;
                teacher.User.LastLogin = DateTime.Now;
                teacher.User.RoleId = 2015;
                _teachers.Add(teacher);

                // user.RoleId =2015;
            }
            else if (userViewModel.RoleId == -2)
            {
                //دانش آموز

                //var student = Mapper.Map<Student>(userViewModel);
                var student = new Student();
                student.User = user;
                student.User.LastLogin = DateTime.Now;

                student.User.RoleId = 2005;
                _students.Add(student);







            }
            else if (userViewModel.RoleId == -3)
            {
                //مشاور
                //user.RoleId = 2010;
            }
            else
            {
                return new ClientMessageResult()
                {
                    Message = $"خطا امنیتی در سطح دسترسی!",
                    MessageType = MessageType.Error
                };
            }

            //user.IsActive = true;
            //user.IsAdmin = false;


            //user.LastLogin = DateTime.Now;
            //_users.Add(user);

            var serverResult = _uow.CommitChanges(CrudType.Create, Title);
            var clientResult = Mapper.Map<ClientMessageResult>(serverResult);

            if (serverResult.ErrorNumber == 2601 && serverResult.EnMessage.Contains("UK_User_NationalNo"))
            {
                clientResult.Message = "کد ملی تکراری می باشد";
            }
            else if (serverResult.ErrorNumber == 2601 && serverResult.EnMessage.Contains("UK_User_Username"))
            {
                clientResult.Message = "نام کاربری تکراری می باشد";
            }

            return clientResult;
        }

        /// <summary>
        /// ثبت کاربر
        /// </summary>
        /// <param name="userViewModel"></param>
        /// <param name="userRoleLevel"></param>
        /// <returns></returns>
        public ClientMessageResult Create(UserCreateViewModel userViewModel, byte userRoleLevel)
        {
            // سطح نقش باید بزرگتر از سطح نقش کاربر ویرایش کننده باشد
            var role = _roleService.Value.GetById(userViewModel.RoleId, userRoleLevel);
            if (role.Level <= userRoleLevel)
            {
                return new ClientMessageResult()
                {
                    Message = $"سطح نقش باید بزرگتر از ({userRoleLevel}) باشد",
                    MessageType = MessageType.Error
                };
            }

            var user = Mapper.Map<User>(userViewModel);
            user.LastLogin = DateTime.Now;
            _users.Add(user);

            var serverResult = _uow.CommitChanges(CrudType.Create, Title);
            var clientResult = Mapper.Map<ClientMessageResult>(serverResult);

            if (clientResult.MessageType == MessageType.Success)
            {
                clientResult.Obj = GetById(user.Id, userRoleLevel);
            }
            else if (serverResult.ErrorNumber == 2601 && serverResult.EnMessage.Contains("UK_User_NationalNo"))
            {
                clientResult.Message = "کد ملی تکراری می باشد";
            }
            else if (serverResult.ErrorNumber == 2601 && serverResult.EnMessage.Contains("UK_User_Username"))
            {
                clientResult.Message = "نام کاربری تکراری می باشد";
            }

            return clientResult;
        }

        /// <summary>
        /// ویرایش کاربر
        /// </summary>
        /// <param name="userViewModel"></param>
        /// <param name="userRoleLevel"></param>
        /// <returns></returns>
        public ClientMessageResult Update(UserUpdateViewModel userViewModel, byte userRoleLevel)
        {
            // سطح نقش باید بزرگتر از سطح نقش کاربر ویرایش کننده باشد
            var role = _roleService.Value.GetById(userViewModel.RoleId, userRoleLevel);
            if (role == null)
            {
                return new ClientMessageResult()
                {
                    Message = "نقش یافت نگردید",
                    MessageType = MessageType.Error
                };
            }

            if (role.Level <= userRoleLevel)
            {
                return new ClientMessageResult()
                {
                    Message = $"سطح نقش باید بزرگتر از ({userRoleLevel}) باشد",
                    MessageType = MessageType.Error
                };
            }

            var user = Mapper.Map<UserUpdateViewModel, User>(userViewModel);
            if (string.IsNullOrEmpty(user.Password))
            {
                _uow.ExcludeFieldsFromUpdate(user, x => x.Password, x => x.LastLogin);
                _uow.ValidateOnSaveEnabled(false);
            }
            else
            {
                _uow.ExcludeFieldsFromUpdate(user, x => x.LastLogin);
            }

            var serverResult = _uow.CommitChanges(CrudType.Update, Title);
            var clientResult = Mapper.Map<ClientMessageResult>(serverResult);

            if (clientResult.MessageType == MessageType.Success)
            {
                clientResult.Obj = GetById(user.Id, userRoleLevel);
            }
            else if (serverResult.ErrorNumber == 2601 && serverResult.EnMessage.Contains("UK_User_NationalNo"))
            {
                clientResult.Message = "کد ملی تکراری می باشد";
            }
            else if (serverResult.ErrorNumber == 2601 && serverResult.EnMessage.Contains("UK_User_Username"))
            {
                clientResult.Message = "نام کاربری تکراری می باشد";
            }

            return clientResult;
        }

        /// <summary>
        /// ویرایش کاربر
        /// </summary>
        /// <param name="userViewModel"></param>
        /// <param name="userRoleLevel"></param>
        /// <returns></returns>
        public ClientMessageResult UpdateUser(UserUpdateViewModel userViewModel, byte userRoleLevel)
        {
            // سطح نقش باید بزرگتر از سطح نقش کاربر ویرایش کننده باشد
            var role = _roleService.Value.GetByIdPrivate(userViewModel.RoleId, userRoleLevel);
            if (role == null)
            {
                return new ClientMessageResult()
                {
                    Message = "نقش یافت نگردید",
                    MessageType = MessageType.Error
                };
            }

            if (role.Level < userRoleLevel)
            {
                return new ClientMessageResult()
                {
                    Message = $"سطح نقش باید بزرگتر از ({userRoleLevel}) باشد",
                    MessageType = MessageType.Error
                };
            }

            var user = Mapper.Map<UserUpdateViewModel, User>(userViewModel);
            if (string.IsNullOrEmpty(user.Password))
            {
                _uow.ExcludeFieldsFromUpdate(user, x => x.Password, x => x.LastLogin);
                _uow.ValidateOnSaveEnabled(false);
            }
            else
            {
                _uow.ExcludeFieldsFromUpdate(user, x => x.LastLogin);
            }

            var serverResult = _uow.CommitChanges(CrudType.Update, Title);
            var clientResult = Mapper.Map<ClientMessageResult>(serverResult);

            if (clientResult.MessageType == MessageType.Success)
            {
                clientResult.Obj = GetById(user.Id, userRoleLevel);
            }
            else if (serverResult.ErrorNumber == 2601 && serverResult.EnMessage.Contains("UK_User_NationalNo"))
            {
                clientResult.Message = "کد ملی تکراری می باشد";
            }
            else if (serverResult.ErrorNumber == 2601 && serverResult.EnMessage.Contains("UK_User_Username"))
            {
                clientResult.Message = "نام کاربری تکراری می باشد";
            }

            return clientResult;
        }



        /// <summary>
        /// تغییر رمز عبور
        /// </summary>
        /// <param name="userViewModel"></param>
        /// <param name="userRoleLevel"></param>
        /// <returns></returns>
        public ClientMessageResult UpdateUserPassword(UserChangePasswordViewModel userViewModel, byte userRoleLevel, int userID)
        {

            var user = _users
                .FirstOrDefault(current => current.Id == userID);

            if (user != null && userViewModel.OldPassword != user.Password)
            {
                return new ClientMessageResult()
                {
                    Message = "رمز عبور اشتباه است.",
                    MessageType = MessageType.Error
                };
            }

            if (userViewModel.NewPassword == userViewModel.ReNewPassword)
            {
                user.Password = userViewModel.NewPassword;
            }
            else
            {
                return new ClientMessageResult()
                {
                    Message = "تکرار رمز عبور برابر نیست.",
                    MessageType = MessageType.Error
                };
            }
            _uow.MarkAsChanged(user);
            _uow.ExcludeFieldsFromUpdate(user, x => x.LastLogin);
            _uow.UpdateFields(user, x => x.Password);
           


            var serverResult = _uow.CommitChanges(CrudType.Update, Title);
            var clientResult = Mapper.Map<ClientMessageResult>(serverResult);

            if (clientResult.MessageType == MessageType.Success)
            {
                if (user != null) clientResult.Obj = GetById(user.Id, userRoleLevel);
            }
          

            return clientResult;
        }

        /// <summary>
        /// ویرایش کاربر
        /// </summary>
        /// <param name="userViewModel"></param>
        /// <param name="userRoleLevel"></param>
        /// <returns></returns>
        public ClientMessageResult UpdateImage(UserViewModel userViewModel, byte userRoleLevel)
        {
            // سطح نقش باید بزرگتر از سطح نقش کاربر ویرایش کننده باشد
            var role = _roleService.Value.GetByIdPrivate(userViewModel.RoleId, userRoleLevel);
            if (role == null)
            {
                return new ClientMessageResult()
                {
                    Message = "نقش یافت نگردید",
                    MessageType = MessageType.Error
                };
            }

            if (role.Level < userRoleLevel)
            {
                return new ClientMessageResult()
                {
                    Message = $"سطح نقش باید بزرگتر از ({userRoleLevel}) باشد",
                    MessageType = MessageType.Error
                };
            }

            var user = Mapper.Map<UserViewModel, User>(userViewModel);
            _uow.MarkAsChanged(user);
            _uow.UpdateFields(user, x => x.ProfilePic);
            _uow.ExcludeFieldsFromUpdate(user, x => x.Password, x => x.LastLogin);
            _uow.ValidateOnSaveEnabled(false);

            var serverResult = _uow.CommitChanges(CrudType.Update, Title);
            var clientResult = Mapper.Map<ClientMessageResult>(serverResult);

            if (clientResult.MessageType == MessageType.Success)
            {
                clientResult.Obj = GetById(user.Id, userRoleLevel);
            }
            else if (serverResult.ErrorNumber == 2601 && serverResult.EnMessage.Contains("UK_User_NationalNo"))
            {
                clientResult.Message = "کد ملی تکراری می باشد";
            }
            else if (serverResult.ErrorNumber == 2601 && serverResult.EnMessage.Contains("UK_User_Username"))
            {
                clientResult.Message = "نام کاربری تکراری می باشد";
            }

            return clientResult;
        }

        /// <summary>
        /// حذف کاربر
        /// </summary>
        /// <param name="id"></param>
        /// <param name="userRoleLevel"></param>
        /// <returns></returns>
        public ClientMessageResult Delete(int id, byte userRoleLevel)
        {
            var userViewModel = GetById(id, userRoleLevel);
            if (userViewModel == null)
            {
                return ClientMessageResult.NotFound();
            }

            var user = Mapper.Map<User>(userViewModel);
            _uow.MarkAsDeleted(user);
            var msgRes = _uow.CommitChanges(CrudType.Delete, Title);
            return Mapper.Map<ClientMessageResult>(msgRes);
        }

        /// <summary>
        /// احراز هویت
        /// </summary>
        /// <param name="login"></param>
        /// <returns></returns>
        public LoginResultViewModel Login(LoginViewModel login)
        {
            var loginResult = new LoginResultViewModel
            {
                MessageType = MessageType.Error
            };

            var lstUsr = _users
                .Include(current => current.Role)
                .Where(current => current.Username == login.UserName)
                .Where(current => current.Password == login.Password)
                .ToList();

            if (lstUsr.Count == 1)
            {
                var usr = lstUsr[0];
                if (!usr.IsActive)
                {
                    loginResult.Message = "نام کاربری شما فعال نمی باشد.";
                }
                else
                {
                    loginResult.SubMenus = _actionService.Value.GetSubMenu(usr.Role.SumOfActionBit);
                    if (loginResult.SubMenus.Count == 0)
                    {
                        loginResult.Message = "شما به صفحه ای دسترسی ندارید";
                    }
                    else
                    {
                        var defaultPage = "";

                        if (lstUsr[0].Role.Level == 3)
                        {
                            defaultPage = "/panel/expertpanel";
                        }
                        else if (lstUsr[0].Role.Level < 3)
                        {
                            defaultPage = "/panel/adminpanel";
                        }
                        else if (lstUsr[0].Role.Id == 2015)
                        {
                            defaultPage = "/panel/teacherPanel";
                        }
                        else
                        {

                            foreach (var item in loginResult.SubMenus)
                            {
                                if (item.EnName == "/User")
                                {
                                    defaultPage = item.EnName;
                                    break;
                                }
                            }

                            if (string.IsNullOrEmpty(defaultPage))
                            {
                                defaultPage = loginResult.SubMenus[0].EnName;
                            }
                        }

                        loginResult.Message = "ورود موفقیت آمیز";
                        loginResult.MessageType = MessageType.Success;

                        loginResult.Menus = _actionService.Value.GetMenu(usr.Role.SumOfActionBit);
                        loginResult.DefaultPage = defaultPage;

                        loginResult.FullName = usr.Name + " " + usr.Family;
                        loginResult.ProfilePic = $"/Api/User/GetPictureFile/{usr.ProfilePic}".ToFullRelativePath();

                        loginResult.Token = JsonWebToken.CreateToken(usr.Role.Level,
                            usr.IsAdmin, usr.Id, usr.Role.SumOfActionBit, usr.Role.UserType);
                    }
                }
            }
            else
            {
                loginResult.Message = "نام کاربری یا رمز عبور اشتباه می باشد.";
            }

            return loginResult;
        }



    }
}
