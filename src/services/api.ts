/**
 * API client configuration and helper for future integrations.
 * This class abstracts standard HTTP requests and JWT handling.
 * Currently, it simulates network delays and provides structured data.
 */

export class ApiClient {
  private static token: string | null = localStorage.getItem('barber_osbao_jwt') || null;

  public static setToken(token: string) {
    this.token = token;
    localStorage.setItem('barber_osbao_jwt', token);
  }

  public static getToken(): string | null {
    return this.token;
  }

  public static clearToken() {
    this.token = null;
    localStorage.removeItem('barber_osbao_jwt');
  }

  /**
   * Helper to simulate network latency for loading states and skeleton views.
   */
  public static async request<T>(execute: () => T, delayMs: number = 800): Promise<T> {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        try {
          // You can toggle this to test Error states!
          const simulateError = false;
          if (simulateError) {
            throw new Error('Erro de conexão com o servidor. Tente novamente.');
          }
          resolve(execute());
        } catch (error) {
          reject(error);
        }
      }, delayMs);
    });
  }

  /**
   * Placeholders for future payment processing integrations
   */
  public static async processPixPayment(amount: number): Promise<{ qrCode: string; transactionId: string }> {
    return this.request(() => ({
      qrCode: `00020101021226830014br.gov.bcb.pix2561api.barberosbao.com/pix/qr/v2/pay-${Math.random().toString(36).substring(7)}5204000053039865405${amount.toFixed(2)}5802BR5915BarberOsbao%20LTDA6009Sao%20Paulo62070503***6304`,
      transactionId: `pix_${Math.random().toString(36).substring(2, 15)}`
    }));
  }

  public static async processStripePayment(cardToken: string, amount: number): Promise<{ success: boolean; chargeId: string }> {
    return this.request(() => ({
      success: true,
      chargeId: `ch_${Math.random().toString(36).substring(2, 15)}`
    }));
  }

  public static async processMercadoPagoPayment(amount: number): Promise<{ paymentUrl: string; id: string }> {
    return this.request(() => ({
      paymentUrl: 'https://www.mercadopago.com.br/checkout/payments/...',
      id: `mp_${Math.random().toString(36).substring(2, 15)}`
    }));
  }

  /**
   * Placeholders for Push notifications
   */
  public static async registerPushToken(token: string): Promise<boolean> {
    return this.request(() => true);
  }

  /**
   * Placeholders for Check-in (Geo-location verification)
   */
  public static async performCheckIn(userId: string, lat: number, lng: number): Promise<{ success: boolean; distanceMeter: number }> {
    return this.request(() => ({
      success: true,
      distanceMeter: 12.5 // within barber shop radius
    }));
  }

  /**
   * Placeholders for Loyalty Program
   */
  public static async getLoyaltyPoints(userId: string): Promise<{ points: number; nextRewardAt: number }> {
    return this.request(() => ({
      points: 120,
      nextRewardAt: 150 // Free Combo at 150 points
    }));
  }
}
