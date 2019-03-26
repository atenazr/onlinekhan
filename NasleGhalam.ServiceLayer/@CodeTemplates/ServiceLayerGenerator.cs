﻿using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using AutoMapper;
using NasleGhalam.Common;
using NasleGhalam.DataAccess.Context;
using NasleGhalam.DomainClasses.Entities;
using NasleGhalam.ViewModels;
using NasleGhalam.ViewModels.QuestionJudge;

namespace NasleGhalam.ServiceLayer.Services
{
	public class QuestionJudgeService
	{
		private const string Title = "کارشناسی سوال";
        private readonly IUnitOfWork _uow;
        private readonly IDbSet<QuestionJudge> _questionJudges;
       
	    public QuestionJudgeService(IUnitOfWork uow)
        {
            _uow = uow;
            _questionJudges = uow.Set<QuestionJudge>();
        }


		/// <summary>
        /// گرفتن  کارشناسی سوال با آی دی
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public QuestionJudgeViewModel GetById(int id)
        {
            return _questionJudges
                .Where(current => current.Id == id)
                .AsNoTracking()
                .AsEnumerable()
                .Select(Mapper.Map<QuestionJudgeViewModel>)
                .FirstOrDefault();
        }


		/// <summary>
        /// گرفتن همه کارشناسی سوال ها
        /// </summary>
        /// <returns></returns>
        public IList<QuestionJudgeViewModel> GetAll()
        {
            return _questionJudges
                .AsNoTracking()
                .AsEnumerable()
                .Select(Mapper.Map<QuestionJudgeViewModel>)
                .ToList();
        }


		/// <summary>
        /// ثبت کارشناسی سوال
        /// </summary>
        /// <param name="questionJudgeViewModel"></param>
        /// <returns></returns>
        public ClientMessageResult Create(QuestionJudgeCreateViewModel questionJudgeViewModel)
        {
            var questionJudge = Mapper.Map<QuestionJudge>(questionJudgeViewModel);
            _questionJudges.Add(questionJudge);

			var msgRes =  _uow.CommitChanges(CrudType.Create, Title);
			msgRes.Id = questionJudge.Id;
            return Mapper.Map<ClientMessageResult>(msgRes);
        }


		/// <summary>
        /// ویرایش کارشناسی سوال
        /// </summary>
        /// <param name="questionJudgeViewModel"></param>
        /// <returns></returns>
        public ClientMessageResult Update(QuestionJudgeUpdateViewModel questionJudgeViewModel)
        {
            var questionJudge = Mapper.Map<QuestionJudge>(questionJudgeViewModel);
            _uow.MarkAsChanged(questionJudge);
			
			var msgRes = _uow.CommitChanges(CrudType.Update, Title);
			return Mapper.Map<ClientMessageResult>(msgRes);
        }


		/// <summary>
        /// حذف کارشناسی سوال
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public ClientMessageResult Delete(int id)
        {
			var  questionJudgeViewModel = GetById(id);
            if (questionJudgeViewModel == null)
            {
                return ClientMessageResult.NotFound();
            }

            var questionJudge = Mapper.Map<QuestionJudge>(questionJudgeViewModel);
            _uow.MarkAsDeleted(questionJudge);
            
			var msgRes = _uow.CommitChanges(CrudType.Delete, Title);
			return Mapper.Map<ClientMessageResult>(msgRes);
        }


        /// <summary>
        /// گرفتن همه کارشناسی سوال ها برای لیست کشویی
        /// </summary>
        /// <returns></returns>
        public IList<SelectViewModel> GetAllDdl()
        {
            return _questionJudges.Select(current => new SelectViewModel
            {
                value = current.Id,
                label = current.Name
            }).ToList();
        }
	}
}
