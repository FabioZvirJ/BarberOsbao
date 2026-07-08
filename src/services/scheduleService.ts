import { Schedule, Service, Barber } from '../types';
import { ApiClient } from './api';
import { getInitialDB, saveDB } from './mockData';

export class ScheduleService {
  public static async getSchedules(): Promise<Schedule[]> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      return db.schedules;
    });
  }

  public static async createSchedule(scheduleData: {
    barberId: string;
    services: Service[];
    date: string;
    time: string;
    notes?: string;
  }): Promise<Schedule> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      const barber = db.barbers.find(b => b.id === scheduleData.barberId);
      if (!barber) {
        throw new Error('Profissional selecionado não encontrado.');
      }

      // Calculate total price
      const totalValue = scheduleData.services.reduce((acc, curr) => acc + curr.price, 0);

      const newSchedule: Schedule = {
        id: `sch-${Math.random().toString(36).substring(2, 9)}`,
        userId: db.currentUser.id,
        barberId: barber.id,
        barberName: barber.name,
        barberAvatar: barber.avatarUrl,
        services: scheduleData.services,
        date: scheduleData.date,
        time: scheduleData.time,
        totalValue,
        status: 'confirmed',
        notes: scheduleData.notes
      };

      db.schedules.unshift(newSchedule); // Add to the top of list
      saveDB(db);
      return newSchedule;
    });
  }

  public static async cancelSchedule(id: string): Promise<Schedule> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      const schedule = db.schedules.find(s => s.id === id);
      if (!schedule) {
        throw new Error('Agendamento não encontrado.');
      }
      schedule.status = 'cancelled';
      saveDB(db);
      return schedule;
    });
  }

  public static async reschedule(id: string, newDate: string, newTime: string): Promise<Schedule> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      const schedule = db.schedules.find(s => s.id === id);
      if (!schedule) {
        throw new Error('Agendamento não encontrado.');
      }
      schedule.date = newDate;
      schedule.time = newTime;
      schedule.status = 'confirmed';
      saveDB(db);
      return schedule;
    });
  }

  public static async getAvailableSlots(barberId: string, date: string): Promise<string[]> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      const barber = db.barbers.find(b => b.id === barberId);
      if (!barber) {
        return [];
      }

      // Find hours already booked for this barber on this date
      const bookedHours = db.schedules
        .filter(s => s.barberId === barberId && s.date === date && s.status !== 'cancelled')
        .map(s => s.time);

      // Return availability list minus booked hours
      return barber.availableHours.filter(h => !bookedHours.includes(h));
    });
  }
}
