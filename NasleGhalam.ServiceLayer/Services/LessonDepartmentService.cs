﻿using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using AutoMapper;
using NasleGhalam.Common;
using NasleGhalam.DataAccess.Context;
using NasleGhalam.DomainClasses.Entities;
using NasleGhalam.ViewModels;
using NasleGhalam.ViewModels.LessonDepartment;

namespace NasleGhalam.ServiceLayer.Services
{
    public class LessonDepartmentService
    {
        private const string Title = "بخش";
        private readonly IUnitOfWork _uow;
        private readonly IDbSet<LessonDepartment> _lessonDepartments;

        public LessonDepartmentService(IUnitOfWork uow)
        {
            _uow = uow;
            _lessonDepartments = uow.Set<LessonDepartment>();
        }


        /// <summary>
        /// گرفتن  بخش با آی دی
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public LessonDepartmentViewModel GetById(int id)
        {
            return _lessonDepartments
                .Where(current => current.Id == id)
                .AsNoTracking()
                .AsEnumerable()
                .Select(Mapper.Map<LessonDepartmentViewModel>)
                .FirstOrDefault();
        }


        /// <summary>
        /// گرفتن همه بخش ها
        /// </summary>
        /// <returns></returns>
        public IList<LessonDepartmentViewModel> GetAll()
        {
            return _lessonDepartments
                .AsNoTracking()
                .AsEnumerable()
                .Select(Mapper.Map<LessonDepartmentViewModel>)
                .ToList();
        }


        /// <summary>
        /// ثبت بخش
        /// </summary>
        /// <param name="lessonDepartmentViewModel"></param>
        /// <returns></returns>
        public ClientMessageResult Create(LessonDepartmentViewModel lessonDepartmentViewModel)
        {
            var lessonDepartment = Mapper.Map<LessonDepartment>(lessonDepartmentViewModel);
            _lessonDepartments.Add(lessonDepartment);

            var msgRes = _uow.CommitChanges(CrudType.Create, Title);
            msgRes.Id = lessonDepartment.Id;
            return Mapper.Map<ClientMessageResult>(msgRes);
        }

        /// <summary>
        /// ثبت بخش
        /// </summary>
        /// <param name="lessonDepartmentViewModel"></param>
        /// <returns></returns>
        public ClientMessageResult Assign(LessonDepartmentAssignViewModel lessonDepartmentViewModel )
        {
            var lessonDepartment = Mapper.Map<LessonDepartment>(lessonDepartmentViewModel);
            var previousLessonDepartment =
                _lessonDepartments.Include(x => x.Lessons).First(x => x.Id == lessonDepartment.Id);

            //delete 
            var deleteList = lessonDepartment.Lessons
                .Where(oldLess => lessonDepartmentViewModel.ids.All(newLessId => newLessId != oldLess.Id))
                .ToList();
            foreach (var lesson in deleteList)
            {
                lessonDepartment.Lessons.Remove(lesson);
            }

            //add 
            var addList = lessonDepartmentViewModel.ids
                .Where(oldLessId => lessonDepartment.Lessons.All(newLess => newLess.Id != oldLessId))
                .ToList();
            foreach (var lessonId in addList)
            {
                var lesson = new Lesson() { Id = lessonId };
                _uow.MarkAsUnChanged(lesson);
                lessonDepartment.Lessons.Add(lesson);
            }

            var msgRes = _uow.CommitChanges(CrudType.Create, Title);
            msgRes.Id = lessonDepartment.Id;
            return Mapper.Map<ClientMessageResult>(msgRes);
        }


        /// <summary>
        /// ویرایش بخش
        /// </summary>
        /// <param name="lessonDepartmentViewModel"></param>
        /// <returns></returns>
        public ClientMessageResult Update(LessonDepartmentViewModel lessonDepartmentViewModel)
        {
            var lessonDepartment = Mapper.Map<LessonDepartment>(lessonDepartmentViewModel);
            _uow.MarkAsChanged(lessonDepartment);

            var msgRes = _uow.CommitChanges(CrudType.Update, Title);
            return Mapper.Map<ClientMessageResult>(msgRes);
        }


        /// <summary>
        /// حذف بخش
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public ClientMessageResult Delete(int id)
        {
            var lessonDepartmentViewModel = GetById(id);
            if (lessonDepartmentViewModel == null)
            {
                return ClientMessageResult.NotFound();
            }

            var lessonDepartment = Mapper.Map<LessonDepartment>(lessonDepartmentViewModel);
            _uow.MarkAsDeleted(lessonDepartment);

            var msgRes = _uow.CommitChanges(CrudType.Delete, Title);
            return Mapper.Map<ClientMessageResult>(msgRes);
        }


        /// <summary>
        /// گرفتن همه بخش ها برای لیست کشویی
        /// </summary>
        /// <returns></returns>
        public IList<SelectViewModel> GetAllDdl()
        {
            return _lessonDepartments.Select(current => new SelectViewModel
            {
                value = current.Id,
                label = current.Name
            }).ToList();
        }
    }
}
