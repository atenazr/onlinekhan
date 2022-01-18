import Vue from "Vue";
import ITeacherGroup, { DefaultTeacherGroup } from "src/models/ITeacherGroup";
import IMessageResult from "src/models/IMessageResult";
import axios, { AxiosResponse } from "src/plugins/axios";
import { MessageType } from "src/utilities/enumeration";
//edit api , below
import { TEACHER_GROUP_URL as baseUrl } from "src/utilities/site-config";
import util from "src/utilities";
import {
  VuexModule,
  mutation,
  action,
  Module,
  getRawActionContext
} from "vuex-class-component"


// ATI
import IUser from "src/models/IUser";

// ATI

@Module({ namespacedPath: "teacherGroupStore/" })
export class TeacherGroupStore extends VuexModule {
  openModal: { create: boolean; edit: boolean; delete: boolean };
  teacherGroup: ITeacherGroup;
  private _teacherGroupList: Array<ITeacherGroup>;
  private _modelChanged: boolean = true;
  private _createVue: Vue;
  private _editVue: Vue;

  // ATI
  private _userList: Array<IUser>;

  // ATI

  /**
   * initialize data
   */
  constructor() {
    super();

    this.teacherGroup = util.cloneObject(DefaultTeacherGroup);
    this._teacherGroupList = [];
    this.openModal = {
      create: false,
      edit: false,
      delete: false
    };

    // ati
    this._userList = [];

    // ati
  }

  //#region ### getters ###
  get modelName() {
    return "گروه دانش آموزی";
  }

  get recordName() {
    return this.teacherGroup.Name || "";
  }

  get ddl() {
    return this._teacherGroupList.map(x => ({
      value: x.Id,
      label: x.Name
    }));
  }

  get gridData() {
    return this._teacherGroupList;
  }


  // ATI
  get checkedUserIds() {
    return this._userList.filter(x => x.Checked).map(x => x.Id);
  }


  // ATI
  //#endregion

  //#region ### mutations ###
  @mutation
  private CREATE(teacherGroup: ITeacherGroup) {
    this._teacherGroupList.push(teacherGroup);
  }

  @mutation
  private UPDATE(teacherGroup: ITeacherGroup) {
    let index = this._teacherGroupList.findIndex(x => x.Id == this.teacherGroup.Id);
    if (index < 0) return;
    util.mapObject(teacherGroup, this._teacherGroupList[index]);
  }

  @mutation
  private DELETE() {
    let index = this._teacherGroupList.findIndex(x => x.Id == this.teacherGroup.Id);
    if (index < 0) return;
    this._teacherGroupList.splice(index, 1);
  }

  @mutation
  private RESET(vm: any) {
    util.mapObject(DefaultTeacherGroup, this.teacherGroup, "Id");
    if (vm.$v) {
      vm.$v.$reset();
    }
  }

  @mutation
  private SET_LIST(list: Array<ITeacherGroup>) {
    this._teacherGroupList = list;
  }

  @mutation
  private MODEL_CHANGED(changed: boolean) {
    this._modelChanged = changed;
  }

  @mutation
  OPEN_MODAL_CREATE(open: boolean) {
    this.openModal.create = open;
  }

  @mutation
  OPEN_MODAL_EDIT(open: boolean) {
    this.openModal.edit = open;
  }

  @mutation
  OPEN_MODAL_DELETE(open: boolean) {
    this.openModal.delete = open;
  }

  @mutation
  SET_CREATE_VUE(vm: Vue) {
    this._createVue = vm;
  }

  @mutation
  SET_EDIT_VUE(vm: Vue) {
    this._editVue = vm;
  }
  //#endregion

  //#region ### actions ###
  @action()
  async getById(id: number) {
    return axios
      .get(`${baseUrl}/GetById/${id}`)
      .then((response: AxiosResponse<ITeacherGroup>) => {
        util.mapObject(response.data, this.teacherGroup);
      });
  }

  @action()
  ///warning -ati- edit with new api
  async fillList() {
    
    if (this._modelChanged) {
      
      return axios
        .get(`${baseUrl}/GetAll`)
        .then((response: AxiosResponse<Array<ITeacherGroup>>) => {
          this.SET_LIST(response.data);
          this.MODEL_CHANGED(false);
        });
    } else {
      return Promise.resolve(this._teacherGroupList);
    }
  }

  @action({ mode: "raw" })
  async validateForm(vm: any) {
    return new Promise(resolve => {
      vm.$v.teacherGroup.$touch();
      if (vm.$v.teacherGroup.$error) {
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
  //warning -ati- edit with new api
  async submitCreate(closeModal: boolean) {
    let vm = this._createVue;
    
    this.teacherGroup['StudentsId']= [26,5678];
    this.teacherGroup['Id']= Number(this.teacherGroup['Id']);
    if (!(await this.validateForm(vm))) return;
    console.log('this.teachergroup',this.teacherGroup);
    return axios
      .post(`${baseUrl}/Create`,this.teacherGroup)
      .then((response: AxiosResponse<IMessageResult>) => {
        console.log('response',response);
        let data = response.data;
        this.notify({ vm, data });

        if (data.MessageType == MessageType.Success) {
          this.CREATE(data.Obj);
          this.OPEN_MODAL_CREATE(!closeModal);
          this.MODEL_CHANGED(true);
          this.resetCreate();
        }
      });
  }

  @action()
  async resetCreate() {
    this.teacherGroup.Id = 0;
    this.RESET(this._createVue);
  }

  @action()
  async submitEdit() {
    let vm = this._editVue;
    if (!(await this.validateForm(vm))) return;

    return axios
      .post(`${baseUrl}/Update`, this.teacherGroup)
      .then((response: AxiosResponse<IMessageResult>) => {
        let data = response.data;
        this.notify({ vm, data });

        if (data.MessageType == MessageType.Success) {
          this.UPDATE(data.Obj);
          this.OPEN_MODAL_EDIT(false);
          this.MODEL_CHANGED(true);
          this.resetEdit();
        }
      });
  }

  @action()
  async resetEdit() {
    this.RESET(this._editVue);
  }

  @action()
  async submitDelete(vm: Vue) {
    return axios
      .post(`${baseUrl}/Delete/${this.teacherGroup.Id}`)
      .then((response: AxiosResponse<IMessageResult>) => {
        let data = response.data;
        this.notify({ vm, data });
        if (data.MessageType == MessageType.Success) {
          this.DELETE();
          this.OPEN_MODAL_DELETE(false);
          this.MODEL_CHANGED(true);
        }
      });
  }
  //#endregion
}

export const teacherGroupStore = TeacherGroupStore.ExtractVuexModule(TeacherGroupStore);