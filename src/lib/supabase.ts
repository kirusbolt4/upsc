import { createClient } from '@supabase/supabase-js';

// Fallback to demo values if environment variables are not set
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://demo.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'demo-key';

// Only throw error in development
if ((!supabaseUrl || !supabaseAnonKey || supabaseUrl === 'https://demo.supabase.co') && import.meta.env.DEV) {
  console.warn('Missing Supabase environment variables. Please set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
    flowType: 'pkce',
    debug: import.meta.env.DEV,
    storage: typeof window !== 'undefined' ? window.localStorage : undefined,
    storageKey: 'upsc-tracker-auth'
  },
  global: {
    headers: {
      'X-Client-Info': 'upsc-tracker'
    }
  },
  db: {
    schema: 'public'
  },
  realtime: {
    params: {
      eventsPerSecond: 10
    }
  }
});

export type Database = {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          email: string;
          full_name: string | null;
          role: 'admin' | 'student';
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          email: string;
          full_name?: string | null;
          role?: 'admin' | 'student';
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          email?: string;
          full_name?: string | null;
          role?: 'admin' | 'student';
          created_at?: string;
          updated_at?: string;
        };
      };
      subjects: {
        Row: {
          id: string;
          name: string;
          description: string | null;
          order_index: number;
          is_active: boolean;
          created_by: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          description?: string | null;
          order_index?: number;
          is_active?: boolean;
          created_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          description?: string | null;
          order_index?: number;
          is_active?: boolean;
          created_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
      modules: {
        Row: {
          id: string;
          subject_id: string;
          name: string;
          description: string | null;
          order_index: number;
          is_active: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          subject_id: string;
          name: string;
          description?: string | null;
          order_index?: number;
          is_active?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          subject_id?: string;
          name?: string;
          description?: string | null;
          order_index?: number;
          is_active?: boolean;
          created_at?: string;
          updated_at?: string;
        };
      };
      sections: {
        Row: {
          id: string;
          module_id: string;
          name: string;
          type: 'source' | 'test' | 'resource' | 'pyq';
          content: string | null;
          link_url: string | null;
          order_index: number;
          is_required: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          module_id: string;
          name: string;
          type?: 'source' | 'test' | 'resource' | 'pyq';
          content?: string | null;
          link_url?: string | null;
          order_index?: number;
          is_required?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          module_id?: string;
          name?: string;
          type?: 'source' | 'test' | 'resource' | 'pyq';
          content?: string | null;
          link_url?: string | null;
          order_index?: number;
          is_required?: boolean;
          created_at?: string;
          updated_at?: string;
        };
      };
      questions: {
        Row: {
          id: string;
          section_id: string;
          question_text: string;
          option_a: string;
          option_b: string;
          option_c: string;
          option_d: string;
          correct_answer: string;
          explanation: string | null;
          order_index: number;
          created_at: string;
        };
        Insert: {
          id?: string;
          section_id: string;
          question_text: string;
          option_a: string;
          option_b: string;
          option_c: string;
          option_d: string;
          correct_answer: string;
          explanation?: string | null;
          order_index?: number;
          created_at?: string;
        };
        Update: {
          id?: string;
          section_id?: string;
          question_text?: string;
          option_a?: string;
          option_b?: string;
          option_c?: string;
          option_d?: string;
          correct_answer?: string;
          explanation?: string | null;
          order_index?: number;
          created_at?: string;
        };
      };
      user_progress: {
        Row: {
          id: string;
          user_id: string;
          subject_id: string;
          total_sections: number;
          completed_sections: number;
          last_accessed: string;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          subject_id: string;
          total_sections?: number;
          completed_sections?: number;
          last_accessed?: string;
          created_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          subject_id?: string;
          total_sections?: number;
          completed_sections?: number;
          last_accessed?: string;
          created_at?: string;
        };
      };
      user_section_progress: {
        Row: {
          id: string;
          user_id: string;
          section_id: string;
          is_completed: boolean;
          score: number;
          attempts: number;
          completed_at: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          section_id: string;
          is_completed?: boolean;
          score?: number;
          attempts?: number;
          completed_at?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          section_id?: string;
          is_completed?: boolean;
          score?: number;
          attempts?: number;
          completed_at?: string | null;
          created_at?: string;
        };
      };
    };
  };
};

// Helper function to handle database errors
export const handleDatabaseError = (error: any, operation: string) => {
  console.error(`Database error during ${operation}:`, error);
  
  if (error.code === 'PGRST116') {
    return 'Record not found';
  } else if (error.code === '23505') {
    return 'This record already exists';
  } else if (error.code === '23503') {
    return 'Cannot delete this record as it is referenced by other data';
  } else if (error.message?.includes('row-level security')) {
    return 'You do not have permission to perform this action';
  } else {
    return error.message || `Failed to ${operation}`;
  }
};