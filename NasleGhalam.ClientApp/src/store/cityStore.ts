import Vue from 'Vue';
import { AxiosResponse } from 'axios';

import ICity from 'src/models/ICity';
import IMessageResult from 'src/models/IMessageResult';

import util from 'src/utilities/util';
import { ModalType, MessageType } from 'src/utilities/enumeration';
import axios from 'src/utilities/axios';
import { CITY_URL as baseUrl } from 'src/utilities/site-config';
import {
  VuexModule,
  mutation,
  action,
  Module,
  getRawActionContext
} from 'vuex-class-component';

@Module({ namespacedPath: 'city/' })
export class CityStore extends VuexModule {
  city: ICity;
  cityList: Array<ICity>;
  private openModalCreate: boolean = false;
  private openModalEdit: boolean = false;
  private openModalDelete: boolean = false;
  private selectedId: number = 0;
  private modelChanged: boolean = true;
  private createVue: Vue;
  private editVue: Vue;

  /**
   * initialize data
   */
  constructor() {
    super();

    this.cityList = [];
    this.city = {
      Id: 0,
      Name: '',
      ProvinceId: 0,
      ProvinceName: ''
    };
  }

  //#region ### internal functions ###
  private getIndexById(id: number) {
    return this.cityList.findIndex(x => x.Id == id);
  }

  private findById(id: number) {
    return this.cityList.find(x => x.Id == id);
  }
  //#endregion

  //#region ### getters ###
  readonly modelName = 'شهر';
  readonly recordName = (this.city && this.city.Name) || '';

  get cityDdl() {
    return this.cityList.map(x => ({
      value: x.Id,
      name: x.Name
    }));
  }
  //#endregion

  //#region ### mutations ###
  @mutation
  private CREATE(city: ICity) {
    this.cityList.push(city);
  }

  @mutation
  private UPDATE(city: ICity) {
    let index = this.getIndexById(city.Id);
    if (index < 0) return;

    this.cityList[index].Id = city.Id;
    this.cityList[index].Name = city.Name;
    this.cityList[index].ProvinceId = city.ProvinceId;
    this.cityList[index].ProvinceName = city.ProvinceName;
  }

  @mutation
  private DELETE(id: number) {
    let index = this.getIndexById(id);
    if (index < 0) return;

    this.cityList.splice(index, 1);
  }

  @mutation
  private RESET() {
    this.city.Id = 0;
    this.city.Name = '';
    this.city.ProvinceId = 0;
    this.city.ProvinceName = '';
  }

  @mutation
  private SET_CITY_LIST(list: Array<ICity>) {
    this.cityList = list;
  }

  @mutation
  private TOGGLE_MODEL_CHANGED(b: boolean) {
    this.modelChanged = b;
  }

  @mutation
  TOGGLE_MODAL(payload: { type: ModalType; b: boolean }) {
    if (payload.type == ModalType.Create) {
      this.openModalCreate = payload.b;
    } else if (payload.type == ModalType.Update) {
      this.openModalEdit = payload.b;
    } else if (payload.type == ModalType.Delete) {
      this.openModalDelete = payload.b;
    }
  }

  @mutation
  SET_VUE(payload: { type: ModalType; vue: Vue }) {
    if (payload.type == ModalType.Create) {
      this.createVue = payload.vue;
    } else if (payload.type == ModalType.Update) {
      this.editVue = payload.vue;
    }
  }
  //#endregion

  //#region ### actions ###
  @action()
  getById() {
    return axios
      .get(`${baseUrl}/GetById`)
      .then((response: AxiosResponse<ICity>) => {
        this.city.Id = response.data.Id;
        this.city.Name = response.data.Name;
      });
  }

  @action()
  getAll() {
    if (this.modelChanged) {
      return axios
        .get(`${baseUrl}/GetAll`)
        .then((response: AxiosResponse<Array<ICity>>) => {
          this.SET_CITY_LIST(response.data);
          this.TOGGLE_MODEL_CHANGED(false);
        });
    }
  }

  @action({ mode: 'raw' })
  async validateForm(vm: any) {
    vm.$v.cityObj.$touch();
    if (vm.$v.cityObj.$error) {
      const context = getRawActionContext(this);
      await context.dispatch('notifyInvalidForm', vm, { root: true });
      return false;
    }
    return true;
  }

  @action({ mode: 'raw' })
  async notify(payload: { vm: Vue; data: IMessageResult }) {
    const context = getRawActionContext(this);
    await context.dispatch(
      'notify',
      {
        body: payload.data.Message,
        type: payload.data.MessageType,
        vm: payload.vm
      },
      { root: true }
    );
  }

  @action()
  submitCreate(vm: Vue) {
    if (!this.validateForm(vm)) return;

    return axios
      .post(`${baseUrl}/Create`, this.city)
      .then((response: AxiosResponse<IMessageResult>) => {
        let data = response.data;

        this.notify({ vm, data });
        if (data.MessageType == MessageType.Success) {
          this.CREATE(this.city);
          this.TOGGLE_MODAL({ type: ModalType.Create, b: true });
        }
      });
  }
  //#endregion
}

export const city = CityStore.ExtractVuexModule(CityStore);
