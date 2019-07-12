﻿using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using AutoMapper;
using NasleGhalam.Common;
using NasleGhalam.DataAccess.Context;
using NasleGhalam.DomainClasses.Entities;
using NasleGhalam.ViewModels.Assay;
using NasleGhalam.ViewModels.Question;

namespace NasleGhalam.ServiceLayer.Services
{
    public class AssayService
    {
        private const string Title = "آزمون";
        private readonly IUnitOfWork _uow;
        private readonly IDbSet<Assay> _assays;

        private readonly Lazy<QuestionService> _questionService;

        public AssayService(IUnitOfWork uow, Lazy<QuestionService> questionService)
        {
            _uow = uow;
            _assays = uow.Set<Assay>();
            _questionService = questionService;
        }

        /// <summary>
        /// گرفتن  آزمون با آی دی
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public AssayViewModel GetById(int id)
        {
            return _assays
                .Where(current => current.Id == id)
                .AsNoTracking()
                .AsEnumerable()
                .Select(Mapper.Map<AssayViewModel>)
                .FirstOrDefault();
        }


        /// <summary>
        /// گرفتن سوالات یک آزمون
        /// </summary>
        /// <returns></returns>
        public IList<QuestionAssayViewModel> GetAllQuestion(AssayGetQuestionsViewModel assayGetQuestionsViewModel)
        {
            List<QuestionAssayViewModel> questionsReturn = new List<QuestionAssayViewModel>();
            if (assayGetQuestionsViewModel.RandomQuestion)
            {
                foreach (var lesson in assayGetQuestionsViewModel.Lessons)
                {
                    var qEasy = _questionService.Value.GetAllByTopicIdsForAssay(
                        lesson.Topics.Select(x => x.Id).ToList(), 11,
                        lesson.CountOfEasy);
                    var qMedium = _questionService.Value.GetAllByTopicIdsForAssay(
                        lesson.Topics.Select(x => x.Id).ToList(), 12,
                        lesson.CountOfMedium);
                    var qHard = _questionService.Value.GetAllByTopicIdsForAssay(
                        lesson.Topics.Select(x => x.Id).ToList(), 13,
                        lesson.CountOfHard);

                    MergeQuestionLists(ref questionsReturn, qEasy, lesson.Id, lesson.Name);
                    MergeQuestionLists(ref questionsReturn, qMedium, lesson.Id, lesson.Name);
                    MergeQuestionLists(ref questionsReturn, qHard, lesson.Id, lesson.Name);
                }

                return questionsReturn;
            }
            else
            {
                foreach (var lesson in assayGetQuestionsViewModel.Lessons)
                {
                    foreach (var topic in lesson.Topics)
                    {
                        var qEasy = _questionService.Value.GetAllByTopicIdsForAssay(
                            new List<int> { topic.Id }, 11,
                            lesson.CountOfEasy);
                        var qMedium = _questionService.Value.GetAllByTopicIdsForAssay(
                            new List<int> { topic.Id }, 12,
                            lesson.CountOfMedium);
                        var qHard = _questionService.Value.GetAllByTopicIdsForAssay(
                            new List<int> { topic.Id }, 13,
                            lesson.CountOfHard);

                        MergeQuestionLists(ref questionsReturn, qEasy, lesson.Id, lesson.Name);
                        MergeQuestionLists(ref questionsReturn, qMedium, lesson.Id, lesson.Name);
                        MergeQuestionLists(ref questionsReturn, qHard, lesson.Id, lesson.Name);
                    }
                }

                return questionsReturn;
            }

        }

        /// <summary>
        /// گرفتن همه آزمون ها
        /// </summary>
        /// <returns></returns>
        public IList<AssayViewModel> GetAll()
        {
            return _assays
                .AsNoTracking()
                .AsEnumerable()
                .Select(Mapper.Map<AssayViewModel>)
                .ToList();
        }

        /// <summary>
        /// ثبت آزمون
        /// </summary>
        /// <param name="assayViewModel"></param>
        /// <returns></returns>
        public ClientMessageResult Create(AssayGetQuestionsViewModel assayViewModel)
        {
            var assay = Mapper.Map<Assay>(assayViewModel);
            _assays.Add(assay);

            foreach (var lesson in assayViewModel.Lessons)
            {
                foreach (var question in lesson.Questions)
                {
                    assay.AssayQuestions.Add(new AssayQuestion()
                    {
                        LessonId = lesson.Id,
                        QuestionId = question.Id,

                        //todo: complete
                        AnswerNumber = 0,
                        File = null
                    });
                }
            }


            var serverResult = _uow.CommitChanges(CrudType.Create, Title);
            var clientResult = Mapper.Map<ClientMessageResult>(serverResult);

            if (clientResult.MessageType == MessageType.Success)
                clientResult.Obj = GetById(assay.Id);

            return clientResult;
        }

        /// <summary>
        /// ویرایش آزمون
        /// </summary>
        /// <param name="assayViewModel"></param>
        /// <returns></returns>
        public ClientMessageResult Update(AssayViewModel assayViewModel)
        {
            var assay = Mapper.Map<Assay>(assayViewModel);
            _uow.MarkAsChanged(assay);

            var serverResult = _uow.CommitChanges(CrudType.Update, Title);
            var clientResult = Mapper.Map<ClientMessageResult>(serverResult);

            if (clientResult.MessageType == MessageType.Success)
                clientResult.Obj = GetById(assay.Id);

            return clientResult;
        }

        /// <summary>
        /// حذف آزمون
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public ClientMessageResult Delete(int id)
        {
            var assayViewModel = GetById(id);
            if (assayViewModel == null)
            {
                return ClientMessageResult.NotFound();
            }

            var assay = Mapper.Map<Assay>(assayViewModel);
            _uow.MarkAsDeleted(assay);

            var msgRes = _uow.CommitChanges(CrudType.Delete, Title);
            return Mapper.Map<ClientMessageResult>(msgRes);
        }



        private void MergeQuestionLists(ref List<QuestionAssayViewModel> questionAssayViewModels,
            IList<QuestionViewModel> questionViewModels, int lessonId, string lessonName)
        {
            foreach (var question in questionViewModels)
            {
                QuestionAssayViewModel q = Mapper.Map<QuestionAssayViewModel>(question);
                q.LessonId = lessonId;
                questionAssayViewModels.Add(q);
            }
        }
    }
}
