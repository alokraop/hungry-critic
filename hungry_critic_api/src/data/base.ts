import { ClassConstructor, classToPlain, plainToClass } from 'class-transformer';
import config from 'config';
import { Db, FilterQuery, MongoClient } from 'mongodb';
import { PageInfo } from '../models/internal';

let client: Promise<Db>;
async function db(): Promise<Db> {
  if (!client) {
    client = MongoClient.connect(config.get<string>('db.url'), {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    }).then((client) => client.db(config.get<string>('db.name')));
  }

  return client;
}

export class BaseDao<T extends Object> {
  constructor(private collection: string, private type: ClassConstructor<T>) {}

  async fetch(id: string, projection: any = { _id: 0 }): Promise<T | null> {
    const client = await this.init();
    return client.findOne({ id }, { projection });
  }

  async fetchExternal(id: string, projection: any = {}): Promise<T | null> {
    const result = await this.fetch(id, projection);
    return plainToClass(this.type, result);
  }

  async find(query: FilterQuery<any>, projection: any = {}): Promise<T | null> {
    const client = await this.init();
    return client.findOne(query, { projection });
  }

  async findAll(query: FilterQuery<any>, projection: any = {}, page?: PageInfo): Promise<T[]> {
    const client = await this.init();
    let cursor = client.find(query, { projection });
    if (page) {
      cursor = cursor.skip(page.offset).limit(page.limit);
    }
    return cursor.toArray();
  }

  async save(document: T): Promise<any> {
    const client = await this.init();
    const plain = classToPlain(document);
    return client.insertOne(plain);
  }

  async replace(id: string, document: any): Promise<any> {
    const client = await this.init();
    return client.replaceOne({ id }, document);
  }

  async saveAll(documents: T[]): Promise<any> {
    if (documents.length === 0) return;
    const client = await this.init();
    return client.insertMany(documents.map((d) => classToPlain(d)));
  }

  async update(query: FilterQuery<any>, update: any): Promise<any> {
    const client = await this.init();
    return client.updateOne(query, { $set: update });
  }

  async rawUpdate(query: FilterQuery<any>, update: any): Promise<any> {
    const client = await this.init();
    return client.updateOne(query, update);
  }

  async delete(query: FilterQuery<any>): Promise<any> {
    const client = await this.init();
    return client.deleteOne(query);
  }

  async deleteAll(query: FilterQuery<any>): Promise<any> {
    const client = await this.init();
    return client.deleteMany(query);
  }

  async init() {
    return db().then((d) => d.collection(this.collection));
  }
}
