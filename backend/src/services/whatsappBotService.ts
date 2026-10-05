import { prisma } from '../app';
import bcrypt from 'bcryptjs';

export interface BotSession {
  phone: string;
  step:
    | 'IDLE'
    | 'AWAITING_NAME'
    | 'AWAITING_BRANCH'
    | 'AWAITING_SERVICE'
    | 'AWAITING_BARBER'
    | 'AWAITING_DATE'
    | 'AWAITING_TIME'
    | 'CONFIRMING'
    | 'CANCEL_SELECT';
  userName?: string;
  clientId?: string;
  branchId?: string;
  branchName?: string;
  serviceId?: string;
  serviceName?: string;
  servicePrice?: number;
  serviceDuration?: number;
  barberId?: string;
  barberName?: string;
  selectedDate?: string; // YYYY-MM-DD
  selectedTime?: string; // HH:mm
  availableBranches?: Array<{ id: string; name: string }>;
  availableServices?: Array<{ id: string; name: string; price: number; duration: number }>;
  availableBarbers?: Array<{ id: string; name: string }>;
  availableDates?: Array<{ label: string; dateStr: string }>;
  availableSlots?: string[];
  userAppointmentsToCancel?: Array<{ id: string; details: string }>;
  lastInteraction: number;
}

export class WhatsAppBotService {
  private static sessions: Map<string, BotSession> = new Map();
  private static SESSION_TIMEOUT_MS = 20 * 60 * 1000; // 20 minutos de inatividade

  /**
   * Obtém ou cria a sessão do cliente para o número de WhatsApp
   */
  private static getSession(phone: string): BotSession {
    const now = Date.now();
    const existing = this.sessions.get(phone);

    if (existing && now - existing.lastInteraction < this.SESSION_TIMEOUT_MS) {
      existing.lastInteraction = now;
      return existing;
    }

    const newSession: BotSession = {
      phone,
      step: 'IDLE',
      lastInteraction: now,
    };
    this.sessions.set(phone, newSession);
    return newSession;
  }

  /**
   * Busca se o cliente já existe pelo telefone
   */
  private static async findClientByPhone(phone: string) {
    const clean = phone.replace(/\D/g, '');
    const phoneWithoutDDI = clean.startsWith('55') ? clean.substring(2) : clean;

    const client = await prisma.client.findFirst({
      where: {
        OR: [
          { phone: clean },
          { phone: phoneWithoutDDI },
          { phone: { contains: phoneWithoutDDI } },
        ],
      },
    });

    if (client) return client;

    // Tenta também no modelo User
    const user = await prisma.user.findFirst({
      where: {
        OR: [
          { phone: clean },
          { phone: phoneWithoutDDI },
          { phone: { contains: phoneWithoutDDI } },
        ],
      },
    });

    if (user) {
      return {
        id: user.id,
        name: user.name || 'Cliente',
        phone: user.phone || phone,
      };
    }

    return null;
  }

  /**
   * Processa a mensagem recebida e retorna a resposta de texto a ser enviada
   */
  public static async processMessage(fromPhone: string, text: string): Promise<string> {
    const session = this.getSession(fromPhone);
    const trimmed = text.trim();
    const lower = trimmed.toLowerCase();

    // Comandos globais de escape para voltar ao menu
    if (lower === 'menu' || lower === 'inicio' || lower === 'início' || lower === 'voltar' && session.step === 'IDLE') {
      session.step = 'IDLE';
    }

    // 1. Se estiver aguardando o nome para cadastro
    if (session.step === 'AWAITING_NAME') {
      return await this.handleRegistration(session, trimmed);
    }

    // 2. Se a sessão estiver IDLE (ou acabou de chamar)
    if (session.step === 'IDLE') {
      const client = await this.findClientByPhone(fromPhone);

      // Se não tem cadastro ainda, solicita o nome
      if (!client) {
        session.step = 'AWAITING_NAME';
        return (
          `💈 *Bem-vindo(a) à Barbearia BarberOsbao!* ✂️\n\n` +
          `Ainda não encontramos um cadastro para o seu número.\n` +
          `Para começarmos e agilizar seus agendamentos, por favor:\n\n` +
          `👉 *Digite o seu Nome Completo:*`
        );
      }

      session.userName = client.name;
      session.clientId = client.id;

      // Se o cliente digitou uma opção numérica do menu direto
      if (/^[1-5]$/.test(trimmed)) {
        return await this.handleMainMenuSelection(session, parseInt(trimmed, 10));
      }

      // Exibe menu principal
      return this.renderMainMenu(client.name);
    }

    // 3. Sub-estados do fluxo
    switch (session.step) {
      case 'AWAITING_BRANCH':
        return await this.handleBranchSelection(session, trimmed);
      case 'AWAITING_SERVICE':
        return await this.handleServiceSelection(session, trimmed);
      case 'AWAITING_BARBER':
        return await this.handleBarberSelection(session, trimmed);
      case 'AWAITING_DATE':
        return await this.handleDateSelection(session, trimmed);
      case 'AWAITING_TIME':
        return await this.handleTimeSelection(session, trimmed);
      case 'CONFIRMING':
        return await this.handleConfirmation(session, trimmed);
      case 'CANCEL_SELECT':
        return await this.handleCancelSelection(session, trimmed);
      default:
        session.step = 'IDLE';
        return this.renderMainMenu(session.userName || 'Cliente');
    }
  }

  /**
   * Renderiza a mensagem do Menu Principal
   */
  private static renderMainMenu(name: string): string {
    return (
      `💈 *Olá, ${name}! Bem-vindo(a) à BarberOsbao.* ✂️\n\n` +
      `Como posso te ajudar hoje?\n\n` +
      `1️⃣ 📅 *Agendar Novo Horário*\n` +
      `2️⃣ 📋 *Meus Agendamentos*\n` +
      `3️⃣ ❌ *Cancelar Agendamento*\n` +
      `4️⃣ 💈 *Ver Serviços & Valores*\n` +
      `5️⃣ 📍 *Horário de Funcionamento & Local*\n\n` +
      `_Digite o número da opção desejada:_`
    );
  }

  /**
   * Realiza o cadastro do novo cliente
   */
  private static async handleRegistration(session: BotSession, fullName: string): Promise<string> {
    if (fullName.length < 3 || !fullName.includes(' ')) {
      return (
        `⚠️ Por favor, digite seu *Nome e Sobrenome* completos para criarmos seu cadastro na barbearia:\n\n` +
        `_Exemplo: Lucas Silva_`
      );
    }

    const cleanName = fullName.slice(0, 80).trim();
    const cleanPhone = session.phone.replace(/\D/g, '');

    try {
      // Cria registro na tabela Client
      const newClient = await prisma.client.create({
        data: {
          name: cleanName,
          phone: cleanPhone,
          status: 'active',
          observacoes: 'Cadastrado automaticamente via WhatsApp Bot',
        },
      });

      // Cria também um User para login se desejar
      const emailGenerated = `whats_${cleanPhone}@barberosbao.com.br`;
      const existingUser = await prisma.user.findUnique({ where: { email: emailGenerated } });
      if (!existingUser) {
        const dummyPassword = await bcrypt.hash(`cli_${Date.now()}`, 10);
        await prisma.user.create({
          data: {
            name: cleanName,
            email: emailGenerated,
            phone: cleanPhone,
            password: dummyPassword,
            role: 'client',
          },
        });
      }

      session.userName = newClient.name;
      session.clientId = newClient.id;
      session.step = 'IDLE';

      return (
        `✅ *Cadastro realizado com sucesso, ${cleanName}!* 🎉\n\n` +
        this.renderMainMenu(cleanName)
      );
    } catch (err) {
      console.error('[Bot Registration Error]:', err);
      session.step = 'IDLE';
      return `❌ Ocorreu um erro ao salvar o cadastro. Por favor, tente novamente enviando "menu".`;
    }
  }

  /**
   * Processa a seleção no Menu Principal (1 a 5)
   */
  private static async handleMainMenuSelection(session: BotSession, option: number): Promise<string> {
    switch (option) {
      case 1:
        return await this.startBookingFlow(session);
      case 2:
        return await this.listMyAppointments(session);
      case 3:
        return await this.startCancelFlow(session);
      case 4:
        return await this.listServicesInfo();
      case 5:
        return this.renderShopInfo();
      default:
        return `⚠️ Opção inválida.\n\n` + this.renderMainMenu(session.userName || 'Cliente');
    }
  }

  /**
   * Inicia o fluxo de agendamento (Filial -> Serviços)
   */
  private static async startBookingFlow(session: BotSession): Promise<string> {
    // 1. Verifica filiais ativas
    try {
      const branches = await prisma.branch.findMany({
        where: { active: true },
        orderBy: { name: 'asc' },
      });

      if (branches.length > 1) {
        session.step = 'AWAITING_BRANCH';
        session.availableBranches = branches.map((b) => ({ id: b.id, name: b.name }));

        let msg = `📍 *Selecione a Unidade desejada:*\n\n`;
        session.availableBranches.forEach((b, idx) => {
          msg += `${idx + 1}️⃣ ${b.name}\n`;
        });
        msg += `\n0️⃣ Voltar ao menu principal\n\n_Digite o número da unidade:_`;
        return msg;
      }

      // Se só houver 1 ou nenhuma unidade específica, segue direto para os serviços
      if (branches.length === 1) {
        session.branchId = branches[0].id;
        session.branchName = branches[0].name;
      }
    } catch (_) {
      // Ignora se não houver tabela de filiais
    }

    return await this.renderServicesMenu(session);
  }

  /**
   * Processa a escolha da filial
   */
  private static async handleBranchSelection(session: BotSession, input: string): Promise<string> {
    if (input === '0') {
      session.step = 'IDLE';
      return this.renderMainMenu(session.userName || 'Cliente');
    }

    const idx = parseInt(input, 10) - 1;
    if (
      isNaN(idx) ||
      !session.availableBranches ||
      idx < 0 ||
      idx >= session.availableBranches.length
    ) {
      return `⚠️ Opção inválida. Digite um número da lista ou 0 para voltar.`;
    }

    const branch = session.availableBranches[idx];
    session.branchId = branch.id;
    session.branchName = branch.name;

    return await this.renderServicesMenu(session);
  }

  /**
   * Renderiza a lista de serviços para agendar
   */
  private static async renderServicesMenu(session: BotSession): Promise<string> {
    const services = await prisma.service.findMany({
      where: { status: true },
      orderBy: { orderIndex: 'asc' },
    });

    if (services.length === 0) {
      session.step = 'IDLE';
      return `❌ Nenhum serviço disponível no momento. Entre em contato com a barbearia.`;
    }

    session.availableServices = services.map((s) => ({
      id: s.id,
      name: s.name,
      price: s.price,
      duration: s.durationMinutes,
    }));
    session.step = 'AWAITING_SERVICE';

    let msg = `💈 *Escolha o Serviço desejado:*\n\n`;
    session.availableServices.forEach((s, idx) => {
      msg += `${idx + 1}️⃣ *${s.name}* - R$ ${s.price.toFixed(2).replace('.', ',')} (${s.duration} min)\n`;
    });
    msg += `\n0️⃣ Voltar ao menu principal\n\n_Digite o número do serviço desejado:_`;
    return msg;
  }

  /**
   * Processa a seleção do serviço
   */
  private static async handleServiceSelection(session: BotSession, input: string): Promise<string> {
    if (input === '0') {
      session.step = 'IDLE';
      return this.renderMainMenu(session.userName || 'Cliente');
    }

    const idx = parseInt(input, 10) - 1;
    if (
      isNaN(idx) ||
      !session.availableServices ||
      idx < 0 ||
      idx >= session.availableServices.length
    ) {
      return `⚠️ Opção inválida. Digite o número do serviço ou 0 para voltar ao menu.`;
    }

    const chosenService = session.availableServices[idx];
    session.serviceId = chosenService.id;
    session.serviceName = chosenService.name;
    session.servicePrice = chosenService.price;
    session.serviceDuration = chosenService.duration;

    // Busca barbeiros ativos
    const barbers = await prisma.employee.findMany({
      where: { status: true },
      orderBy: { name: 'asc' },
    });

    session.availableBarbers = [
      { id: 'any', name: 'Qualquer Barbeiro Disponível' },
      ...barbers.map((b) => ({ id: b.id, name: b.name })),
    ];
    session.step = 'AWAITING_BARBER';

    let msg = `✂️ *Serviço Selecionado:* ${chosenService.name}\n\n`;
    msg += `*Escolha o Barbeiro / Profissional:*\n\n`;
    session.availableBarbers.forEach((b, i) => {
      msg += `${i + 1}️⃣ ${b.name}\n`;
    });
    msg += `\n0️⃣ Voltar ao menu\n\n_Digite o número do profissional:_`;
    return msg;
  }

  /**
   * Processa a seleção do barbeiro
   */
  private static async handleBarberSelection(session: BotSession, input: string): Promise<string> {
    if (input === '0') {
      session.step = 'IDLE';
      return this.renderMainMenu(session.userName || 'Cliente');
    }

    const idx = parseInt(input, 10) - 1;
    if (
      isNaN(idx) ||
      !session.availableBarbers ||
      idx < 0 ||
      idx >= session.availableBarbers.length
    ) {
      return `⚠️ Opção inválida. Digite o número do barbeiro ou 0 para voltar.`;
    }

    const chosenBarber = session.availableBarbers[idx];
    session.barberId = chosenBarber.id;
    session.barberName = chosenBarber.name;

    // Prepara datas sugeridas (Hoje, Amanhã, Depois de amanhã)
    const dates: Array<{ label: string; dateStr: string }> = [];
    const now = new Date();
    const diasSemana = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];

    for (let i = 0; i < 4; i++) {
      const d = new Date(now);
      d.setDate(now.getDate() + i);
      const day = String(d.getDate()).padStart(2, '0');
      const month = String(d.getMonth() + 1).padStart(2, '0');
      const dateStr = `${d.getFullYear()}-${month}-${day}`;
      const dayName = diasSemana[d.getDay()];

      let label = `${day}/${month} (${dayName})`;
      if (i === 0) label = `Hoje - ${day}/${month} (${dayName})`;
      if (i === 1) label = `Amanhã - ${day}/${month} (${dayName})`;

      dates.push({ label, dateStr });
    }

    session.availableDates = dates;
    session.step = 'AWAITING_DATE';

    let msg = `📅 *Escolha a data do agendamento:*\n\n`;
    dates.forEach((d, i) => {
      msg += `${i + 1}️⃣ ${d.label}\n`;
    });
    msg += `\n0️⃣ Voltar ao menu principal\n\n_Digite o número da data ou DD/MM:_`;
    return msg;
  }

  /**
   * Processa a seleção da data e calcula horários disponíveis
   */
  private static async handleDateSelection(session: BotSession, input: string): Promise<string> {
    if (input === '0') {
      session.step = 'IDLE';
      return this.renderMainMenu(session.userName || 'Cliente');
    }

    let selectedDateStr = '';

    const idx = parseInt(input, 10) - 1;
    if (
      !isNaN(idx) &&
      session.availableDates &&
      idx >= 0 &&
      idx < session.availableDates.length
    ) {
      selectedDateStr = session.availableDates[idx].dateStr;
    } else if (/^\d{1,2}\/\d{1,2}$/.test(input)) {
      // Se digitou data no formato DD/MM
      const parts = input.split('/');
      const d = parts[0].padStart(2, '0');
      const m = parts[1].padStart(2, '0');
      const y = new Date().getFullYear();
      selectedDateStr = `${y}-${m}-${d}`;
    } else {
      return `⚠️ Data inválida. Escolha uma das opções numeradas ou digite no formato DD/MM (ex: 15/10).`;
    }

    session.selectedDate = selectedDateStr;

    // Calcula horários disponíveis para a data selecionada
    const availableSlots = await this.calculateAvailableSlots(
      selectedDateStr,
      session.barberName !== 'Qualquer Barbeiro Disponível' ? session.barberName : undefined,
    );

    if (availableSlots.length === 0) {
      return (
        `😔 Não temos mais horários disponíveis para o dia *${this.formatDisplayDate(selectedDateStr)}* com essa preferência.\n\n` +
        `Por favor, digite outro dia ou digite *0* para voltar ao menu.`
      );
    }

    session.availableSlots = availableSlots;
    session.step = 'AWAITING_TIME';

    let msg = `🕒 *Horários disponíveis para ${this.formatDisplayDate(selectedDateStr)}:*\n\n`;
    availableSlots.forEach((slot, i) => {
      msg += `${i + 1}️⃣ ${slot}\n`;
    });
    msg += `\n0️⃣ Voltar ao menu\n\n_Digite o número do horário desejado:_`;
    return msg;
  }

  /**
   * Processa a seleção do horário e gera a confirmação
   */
  private static async handleTimeSelection(session: BotSession, input: string): Promise<string> {
    if (input === '0') {
      session.step = 'IDLE';
      return this.renderMainMenu(session.userName || 'Cliente');
    }

    const idx = parseInt(input, 10) - 1;
    if (
      isNaN(idx) ||
      !session.availableSlots ||
      idx < 0 ||
      idx >= session.availableSlots.length
    ) {
      return `⚠️ Horário inválido. Digite o número correspondente ao horário ou 0 para voltar.`;
    }

    session.selectedTime = session.availableSlots[idx];
    session.step = 'CONFIRMING';

    const displayDate = this.formatDisplayDate(session.selectedDate!);
    const priceFormatted = (session.servicePrice || 0).toFixed(2).replace('.', ',');

    return (
      `📝 *RESUMO DO AGENDAMENTO:*\n` +
      `━━━━━━━━━━━━━━━━━━━━\n` +
      `💈 *Serviço:* ${session.serviceName}\n` +
      `✂️ *Barbeiro:* ${session.barberName}\n` +
      `📅 *Data:* ${displayDate}\n` +
      `🕒 *Horário:* ${session.selectedTime}\n` +
      `💰 *Valor:* R$ ${priceFormatted}\n` +
      `👤 *Cliente:* ${session.userName}\n` +
      (session.branchName ? `📍 *Unidade:* ${session.branchName}\n` : '') +
      `━━━━━━━━━━━━━━━━━━━━\n\n` +
      `1️⃣ ✅ *Confirmar Agendamento*\n` +
      `2️⃣ ❌ *Cancelar e Voltar ao Menu*\n\n` +
      `_Digite 1 para confirmar ou 2 para cancelar:_`
    );
  }

  /**
   * Confirmação final do agendamento
   */
  private static async handleConfirmation(session: BotSession, input: string): Promise<string> {
    if (input === '2' || input.toLowerCase() === 'cancelar') {
      session.step = 'IDLE';
      return `❌ Agendamento cancelado.\n\n` + this.renderMainMenu(session.userName || 'Cliente');
    }

    if (input !== '1' && input.toLowerCase() !== 'confirmar') {
      return `⚠️ Digite *1* para Confirmar ou *2* para Cancelar o agendamento.`;
    }

    try {
      const [year, month, day] = session.selectedDate!.split('-').map(Number);
      const [hour, min] = session.selectedTime!.split(':').map(Number);
      const dateTime = new Date(year, month - 1, day, hour, min);

      // Define barbeiro final (se for 'Qualquer', busca o primeiro ativo)
      let finalBarber = session.barberName!;
      if (finalBarber === 'Qualquer Barbeiro Disponível') {
        const firstActive = await prisma.employee.findFirst({ where: { status: true } });
        finalBarber = firstActive?.name || 'Profissional da Barbearia';
      }

      await prisma.appointment.create({
        data: {
          clientName: session.userName || 'Cliente WhatsApp',
          clientPhone: session.phone.replace(/\D/g, ''),
          barberName: finalBarber,
          serviceName: session.serviceName!,
          dateTime,
          price: session.servicePrice || 0,
          status: 'Confirmado',
          branchId: session.branchId || null,
          notes: 'Agendado pelo Bot do WhatsApp',
        },
      });

      const displayDate = this.formatDisplayDate(session.selectedDate!);
      const selectedTime = session.selectedTime;

      // Reseta estado
      session.step = 'IDLE';

      return (
        `🎉 *AGENDAMENTO CONFIRMADO!* 💈\n\n` +
        `Tudo pronto, *${session.userName}*!\n\n` +
        `✂️ *Serviço:* ${session.serviceName}\n` +
        `👤 *Profissional:* ${finalBarber}\n` +
        `📅 *Data:* ${displayDate} às ${selectedTime}\n` +
        (session.branchName ? `📍 *Unidade:* ${session.branchName}\n` : '') +
        `\nTe esperamos na barbearia! Se precisar cancelar ou alterar, é só nos chamar por aqui.`
      );
    } catch (err) {
      console.error('[Bot Confirm Appointment Error]:', err);
      session.step = 'IDLE';
      return `❌ Ocorreu um erro ao salvar o agendamento. Por favor, tente novamente enviando "menu".`;
    }
  }

  /**
   * Lista os agendamentos futuros do cliente
   */
  private static async listMyAppointments(session: BotSession): Promise<string> {
    const cleanPhone = session.phone.replace(/\D/g, '');
    const phoneWithoutDDI = cleanPhone.startsWith('55') ? cleanPhone.substring(2) : cleanPhone;

    const appointments = await prisma.appointment.findMany({
      where: {
        OR: [
          { clientPhone: cleanPhone },
          { clientPhone: phoneWithoutDDI },
          { clientPhone: { contains: phoneWithoutDDI } },
        ],
        dateTime: { gte: new Date(Date.now() - 30 * 60 * 1000) }, // próximos ou recentes
        status: { notIn: ['Cancelado'] },
      },
      orderBy: { dateTime: 'asc' },
      take: 5,
    });

    session.step = 'IDLE';

    if (appointments.length === 0) {
      return (
        `📋 *Meus Agendamentos:*\n\n` +
        `Você não possui nenhum agendamento futuro ativo no momento.\n\n` +
        `Para marcar um horário, digite *1*.\n\n` +
        this.renderMainMenu(session.userName || 'Cliente')
      );
    }

    let msg = `📋 *Seus Próximos Agendamentos:*\n\n`;
    appointments.forEach((a, i) => {
      const dt = new Date(a.dateTime);
      const dia = String(dt.getDate()).padStart(2, '0');
      const mes = String(dt.getMonth() + 1).padStart(2, '0');
      const hora = String(dt.getHours()).padStart(2, '0');
      const min = String(dt.getMinutes()).padStart(2, '0');

      msg += `${i + 1}️⃣ *${a.serviceName}*\n`;
      msg += `   ✂️ Barbeiro: ${a.barberName}\n`;
      msg += `   📅 ${dia}/${mes} às ${hora}:${min}\n`;
      msg += `   📌 Status: ${a.status}\n\n`;
    });

    msg += `_Para cancelar algum horário, escolha a opção 3 no menu._\n\n` +
      this.renderMainMenu(session.userName || 'Cliente');
    return msg;
  }

  /**
   * Inicia o fluxo de cancelamento
   */
  private static async startCancelFlow(session: BotSession): Promise<string> {
    const cleanPhone = session.phone.replace(/\D/g, '');
    const phoneWithoutDDI = cleanPhone.startsWith('55') ? cleanPhone.substring(2) : cleanPhone;

    const appointments = await prisma.appointment.findMany({
      where: {
        OR: [
          { clientPhone: cleanPhone },
          { clientPhone: phoneWithoutDDI },
          { clientPhone: { contains: phoneWithoutDDI } },
        ],
        dateTime: { gte: new Date() },
        status: { in: ['Pendente', 'Confirmado'] },
      },
      orderBy: { dateTime: 'asc' },
    });

    if (appointments.length === 0) {
      session.step = 'IDLE';
      return (
        `ℹ️ Você não possui agendamentos pendentes ou confirmados para cancelar.\n\n` +
        this.renderMainMenu(session.userName || 'Cliente')
      );
    }

    session.userAppointmentsToCancel = appointments.map((a) => {
      const dt = new Date(a.dateTime);
      const dia = String(dt.getDate()).padStart(2, '0');
      const mes = String(dt.getMonth() + 1).padStart(2, '0');
      const hora = String(dt.getHours()).padStart(2, '0');
      const min = String(dt.getMinutes()).padStart(2, '0');
      return {
        id: a.id,
        details: `${a.serviceName} com ${a.barberName} em ${dia}/${mes} às ${hora}:${min}`,
      };
    });

    session.step = 'CANCEL_SELECT';

    let msg = `❌ *Qual agendamento você deseja cancelar?*\n\n`;
    session.userAppointmentsToCancel.forEach((app, i) => {
      msg += `${i + 1}️⃣ ${app.details}\n`;
    });
    msg += `\n0️⃣ Voltar sem cancelar\n\n_Digite o número do agendamento:_`;
    return msg;
  }

  /**
   * Processa a seleção do cancelamento
   */
  private static async handleCancelSelection(session: BotSession, input: string): Promise<string> {
    if (input === '0') {
      session.step = 'IDLE';
      return this.renderMainMenu(session.userName || 'Cliente');
    }

    const idx = parseInt(input, 10) - 1;
    if (
      isNaN(idx) ||
      !session.userAppointmentsToCancel ||
      idx < 0 ||
      idx >= session.userAppointmentsToCancel.length
    ) {
      return `⚠️ Opção inválida. Digite o número do agendamento para cancelar ou 0 para voltar.`;
    }

    const appToCancel = session.userAppointmentsToCancel[idx];

    try {
      await prisma.appointment.update({
        where: { id: appToCancel.id },
        data: { status: 'Cancelado' },
      });

      session.step = 'IDLE';
      return (
        `✅ *Agendamento cancelado com sucesso!*\n\n` +
        `"${appToCancel.details}" foi desmarcado.\n\n` +
        this.renderMainMenu(session.userName || 'Cliente')
      );
    } catch (err) {
      console.error('[Bot Cancel Error]:', err);
      session.step = 'IDLE';
      return `❌ Erro ao cancelar o horário. Digite "menu" para recomeçar.`;
    }
  }

  /**
   * Tabela de serviços e valores
   */
  private static async listServicesInfo(): Promise<string> {
    const services = await prisma.service.findMany({
      where: { status: true },
      orderBy: { orderIndex: 'asc' },
    });

    let msg = `💈 *Nossos Serviços & Valores:* 💈\n\n`;
    services.forEach((s) => {
      msg += `✂️ *${s.name}* - R$ ${s.price.toFixed(2).replace('.', ',')}\n`;
      if (s.description) msg += `   _${s.description}_\n`;
    });

    msg += `\n_Digite 1 para agendar seu horário!_`;
    return msg;
  }

  /**
   * Informações de localização e funcionamento
   */
  private static renderShopInfo(): string {
    return (
      `📍 *Barbearia BarberOsbao* 💈\n\n` +
      `🕒 *Horário de Funcionamento:*\n` +
      `• Segunda a Sexta: 09:00 às 20:00\n` +
      `• Sábado: 08:30 às 19:00\n` +
      `• Domingo: Fechado\n\n` +
      `📌 *Endereço:* Rua das Palmeiras, 1020 - Centro\n` +
      `📞 *Contato:* (41) 99999-0000\n\n` +
      `_Digite 1 para agendar seu horário agora mesmo!_`
    );
  }

  /**
   * Calcula horários disponíveis no dia para o barbeiro
   */
  private static async calculateAvailableSlots(dateStr: string, barberName?: string): Promise<string[]> {
    const defaultSlots = [
      '09:00', '09:40', '10:20', '11:00', '11:40',
      '13:30', '14:10', '14:50', '15:30', '16:10', '17:00', '17:40', '18:20', '19:00',
    ];

    const [y, m, d] = dateStr.split('-').map(Number);
    const startOfDay = new Date(y, m - 1, d, 0, 0, 0);
    const endOfDay = new Date(y, m - 1, d, 23, 59, 59);

    const whereClause: any = {
      dateTime: { gte: startOfDay, lte: endOfDay },
      status: { notIn: ['Cancelado'] },
    };

    if (barberName) {
      whereClause.barberName = barberName;
    }

    const booked = await prisma.appointment.findMany({
      where: whereClause,
      select: { dateTime: true },
    });

    const bookedTimes = new Set(
      booked.map((b) => {
        const dt = new Date(b.dateTime);
        const hh = String(dt.getHours()).padStart(2, '0');
        const mm = String(dt.getMinutes()).padStart(2, '0');
        return `${hh}:${mm}`;
      }),
    );

    const now = new Date();
    const isToday =
      now.getFullYear() === y &&
      now.getMonth() === m - 1 &&
      now.getDate() === d;

    return defaultSlots.filter((slot) => {
      if (bookedTimes.has(slot)) return false;

      // Se for hoje, remove horários que já passaram
      if (isToday) {
        const [slotH, slotM] = slot.split(':').map(Number);
        const slotDate = new Date(y, m - 1, d, slotH, slotM);
        if (slotDate.getTime() <= now.getTime() + 15 * 60 * 1000) {
          return false;
        }
      }

      return true;
    });
  }

  private static formatDisplayDate(dateStr: string): string {
    const [y, m, d] = dateStr.split('-');
    return `${d}/${m}/${y}`;
  }
}
