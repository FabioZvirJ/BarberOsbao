import { Service } from '../types';
import { ApiClient } from './api';
import { getInitialDB, saveDB } from './mockData';

export class ServiceService {
  public static async getServices(): Promise<Service[]> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      return db.services;
    });
  }

  public static async createService(newService: Omit<Service, 'id'>): Promise<Service> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      const created: Service = {
        ...newService,
        id: `srv-${Math.random().toString(36).substring(2, 9)}`
      };
      db.services.push(created);
      saveDB(db);
      return created;
    });
  }
}
