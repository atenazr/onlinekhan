
import ITopic from "./ITopic";

import IWriter, { DefaultWriter } from "./IWriter";


export default interface IMedia {
  Id: number;
  Title: string;
  WriterId: number;
  Description: string;
  FileName: string;
  // IsActive: boolean;
  LookupId_MediaType: number;
  Price: number;
  Writer?: IWriter;
  Topics?: Array<ITopic>;
  TopicIds?: Array<number>;

}

export const DefaultMedia: IMedia = {
  Id: 0,
  Title: "",
  WriterId: 0,
  Description: "",
  FileName: "",
  // IsActive: true,
  Price: 0,
  LookupId_MediaType: 0,
  Writer: DefaultWriter,

  Topics: [],

  TopicIds: []


};
