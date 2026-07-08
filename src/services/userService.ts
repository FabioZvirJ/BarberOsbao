import { User } from '../types';
import { ApiClient } from './api';
import { getInitialDB, saveDB } from './mockData';

export class UserService {
  public static async getCurrentUser(): Promise<User> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      return db.currentUser;
    });
  }

  public static async updateUser(updatedUser: Partial<User>): Promise<User> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      db.currentUser = {
        ...db.currentUser,
        ...updatedUser,
        preferences: {
          ...db.currentUser.preferences,
          ...(updatedUser.preferences || {})
        }
      };
      saveDB(db);
      return db.currentUser;
    });
  }
}
