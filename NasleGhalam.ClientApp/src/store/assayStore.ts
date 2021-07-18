import AssayCreate from "src/models/IAssay";
import Vue from "Vue";
import {
  VuexModule,
  mutation,
  action,
  Module,
  getRawActionContext
} from "vuex-class-component";
import IMessageResult from "src/models/IMessageResult";
//import IAssay ,{DefaultAssayCreate} from "src/models/IAssay";
import axios, { AxiosResponse } from "src/plugins/axios";
import { MessageType } from "src/utilities/enumeration";
import { ASSAY_URL as baseUrl } from "src/utilities/site-config";
import utilities from "src/utilities";
import IQuestion from "src/models/IQuestion";
import IAssay from "src/models/IAssay";

@Module({ namespacedPath: "assayStore/" })
export class AssayStore extends VuexModule {
  openModal: { create: boolean; edit: boolean; delete: boolean; _0student: boolean; _1lesson: boolean; _2topic: boolean };
  assayCreate: AssayCreate;
  private _assayList: Array<IAssay>;

  private _indexVue: Vue;
  private _assayVue: Vue;
  private _0studentVue: Vue;
  private _1lessonVue: Vue;
  private _2topicVue: Vue;




  /**
   * initialize data
   */
  constructor() {
    super();
    this.assayCreate = new AssayCreate();
    this.openModal = {
      create: false,
      edit: false,
      delete: false,
      _0student: false,
      _1lesson: false,
      _2topic: false
    }
  }
  //#region ### getters ###
  get modelName() {
    return "آزمون";
  }

  get checkedLessons() {
    return this.assayCreate.Lessons.filter(x => x.Checked);
  }
  //#endregion

  //#region ### mutations ###
  @mutation
  SET_INDEX_VUE(vm: Vue) {
    this._indexVue = vm;
  }

  @mutation
  SET_ASSAY_VUE(vm: Vue) {
    this._assayVue = vm;
  }

  
  @mutation
  SET_0STUDENT_VUE(vm: Vue) {
    this._0studentVue = vm;
  }
  
  @mutation
  SET_1LESSON_VUE(vm: Vue) {
    this._1lessonVue = vm;
  }
  
  @mutation
  SET_2TOPIC_VUE(vm: Vue) {
    this._2topicVue = vm;
  }

  @mutation
  OPEN_MODAL_0STUDENT(open: boolean) {
    this.openModal._0student = open;
  }
  @mutation
  OPEN_MODAL_1LESSON(open: boolean) {
    
    this.openModal._1lesson = open;
  }
  @mutation
  OPEN_MODAL_2TOPIC(open: boolean) {
    this.openModal._2topic = open;
  }


  //#endregion

  //#region ### actions ###
  @action({ mode: "raw" })
  async validateForm(vm: any) {
    return new Promise(resolve => {
      vm.$v.assayCreate.$touch();
      if (vm.$v.assayCreate.$error) {
        const context = getRawActionContext(this);
        context.dispatch("notifyInvalidForm", vm, { root: true });
        resolve(false);
      }
      resolve(true);
    });
  }

  @action({ mode: "raw" })
  async notify(payload: { vm: Vue; data: IMessageResult }) {
    const context = getRawActionContext(this);
    return context.dispatch(
      "notify",
      {
        body: payload.data.Message,
        type: payload.data.MessageType,
        vm: payload.vm
      },
      { root: true }
    );
  }


  @action()
  async submitPreCreate() {
    let vm = this._assayVue;
    //if (!(await this.validateForm(vm))) return;

    var data = {
      Title: this.assayCreate.Title,
      Time: this.assayCreate.Time,
      LookupId_Importance: this.assayCreate.LookupId_Importance,
      LookupId_Type: this.assayCreate.LookupId_Type,
      LookupId_QuestionType: this.assayCreate.LookupId_QuestionType,
      IsPublic: this.assayCreate.IsPublic,
      IsOnline: this.assayCreate.IsOnline,
      RandomOptions: this.assayCreate.RandomOptions,
      RandomQuestion: this.assayCreate.RandomQuestion,
      Lessons: this.assayCreate.Lessons.filter(x => x.Checked)
    };
    data.Lessons.forEach(x => {
      x.Topics = x.Topics.filter(x => x.Checked);
    });

    type TQuestionAssay = { LessonId: number; Questions: Array<IQuestion> };
    return axios
      .post(`${baseUrl}/GetAllQuestion`, data)
      .then((response: AxiosResponse<Array<TQuestionAssay>>) => {
        let data = response.data;
        this.checkedLessons.forEach(lesson => {
          var found = data.find(x => x.LessonId == lesson.Id);
          if (found) lesson.Questions = found.Questions;
        });
      });
  }

  //#endregion
}

export const assayStore = AssayStore.ExtractVuexModule(AssayStore);
