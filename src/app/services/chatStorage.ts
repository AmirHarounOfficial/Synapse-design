export interface ChatMessage {
  id: string;
  text: string;
  isBot: boolean;
  timestamp: string;
  reasoning?: string;
  showThinking?: boolean;
  attachment?: {
    name: string;
    size: string;
    type: string;
  };
}

export interface ChatThread {
  id: string;
  title: string;
  role: string;
  createdAt: string;
  updatedAt: string;
  messages: ChatMessage[];
}

const STORAGE_KEY = 'schookeep_ai_chat_threads_v1';

export const chatStorage = {
  getThreads(role?: string): ChatThread[] {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) return [];
      const threads: ChatThread[] = JSON.parse(raw);
      if (role) {
        return threads.filter(t => t.role === role);
      }
      return threads;
    } catch (e) {
      console.error('Failed to load chat threads', e);
      return [];
    }
  },

  saveThread(thread: ChatThread): void {
    try {
      const threads = this.getThreads();
      const index = threads.findIndex(t => t.id === thread.id);
      if (index >= 0) {
        threads[index] = thread;
      } else {
        threads.unshift(thread);
      }
      localStorage.setItem(STORAGE_KEY, JSON.stringify(threads));
    } catch (e) {
      console.error('Failed to save chat thread', e);
    }
  },

  deleteThread(id: string): void {
    try {
      const threads = this.getThreads().filter(t => t.id !== id);
      localStorage.setItem(STORAGE_KEY, JSON.stringify(threads));
    } catch (e) {
      console.error('Failed to delete chat thread', e);
    }
  },

  createNewThread(role: string = 'general', isRTL: boolean = false): ChatThread {
    const timeStr = new Date().toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
    const greetingText = isRTL
      ? 'مرحباً بك! أنا مساعد سكوكيب الذكي (SchooKeep AI). كيف يمكنني مساعدتك اليوم؟'
      : 'Hello! I am SchooKeep AI. How can I help you today?';

    const newThread: ChatThread = {
      id: `thread_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      title: isRTL ? 'محادثة جديدة' : 'New Chat',
      role: role,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      messages: [
        {
          id: '1',
          text: greetingText,
          isBot: true,
          timestamp: timeStr,
        },
      ],
    };

    this.saveThread(newThread);
    return newThread;
  }
};
