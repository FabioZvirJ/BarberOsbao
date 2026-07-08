import { Notification } from '../types';
import { ApiClient } from './api';
import { getInitialDB, saveDB } from './mockData';

export class NotificationService {
  public static async getNotifications(): Promise<Notification[]> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      return db.notifications;
    });
  }

  public static async markAllAsRead(): Promise<Notification[]> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      db.notifications = db.notifications.map(n => ({
        ...n,
        read: true
      }));
      saveDB(db);
      return db.notifications;
    });
  }

  public static async addNotification(notification: Omit<Notification, 'id' | 'createdAt' | 'read' | 'userId'>): Promise<Notification> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      const newNotification: Notification = {
        ...notification,
        id: `ntf-${Math.random().toString(36).substring(2, 9)}`,
        userId: db.currentUser.id,
        read: false,
        createdAt: new Date().toISOString()
      };
      db.notifications.unshift(newNotification);
      saveDB(db);
      return newNotification;
    });
  }
}
