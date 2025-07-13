/*
  # UPSC Tracker Database Schema

  1. New Tables
    - `profiles` - User profiles with role management
    - `subjects` - Admin-created subjects
    - `modules` - Modules under subjects
    - `sections` - Content sections within modules (sources, tests, resources)
    - `questions` - MCQ questions for tests
    - `user_progress` - Student progress tracking
    - `user_section_progress` - Section-level progress

  2. Security
    - Enable RLS on all tables
    - Add policies for admin and student access
    - Separate admin and student data access
*/

-- Profiles table for user management
CREATE TABLE IF NOT EXISTS profiles (
  id uuid REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  email text UNIQUE NOT NULL,
  full_name text,
  role text DEFAULT 'student' CHECK (role IN ('admin', 'student')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Subjects table
CREATE TABLE IF NOT EXISTS subjects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  order_index integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_by uuid REFERENCES profiles(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Modules table
CREATE TABLE IF NOT EXISTS modules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id uuid REFERENCES subjects(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  order_index integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Sections table (sources, tests, resources)
CREATE TABLE IF NOT EXISTS sections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id uuid REFERENCES modules(id) ON DELETE CASCADE,
  name text NOT NULL,
  type text DEFAULT 'source' CHECK (type IN ('source', 'test', 'resource', 'pyq')),
  content text,
  link_url text,
  order_index integer DEFAULT 0,
  is_required boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Questions table for MCQs
CREATE TABLE IF NOT EXISTS questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  section_id uuid REFERENCES sections(id) ON DELETE CASCADE,
  question_text text NOT NULL,
  option_a text NOT NULL,
  option_b text NOT NULL,
  option_c text NOT NULL,
  option_d text NOT NULL,
  correct_answer text NOT NULL CHECK (correct_answer IN ('A', 'B', 'C', 'D')),
  explanation text,
  order_index integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- User progress tracking
CREATE TABLE IF NOT EXISTS user_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  subject_id uuid REFERENCES subjects(id) ON DELETE CASCADE,
  total_sections integer DEFAULT 0,
  completed_sections integer DEFAULT 0,
  last_accessed timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, subject_id)
);

-- Section-level progress
CREATE TABLE IF NOT EXISTS user_section_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  section_id uuid REFERENCES sections(id) ON DELETE CASCADE,
  is_completed boolean DEFAULT false,
  score integer DEFAULT 0,
  attempts integer DEFAULT 0,
  completed_at timestamptz,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, section_id)
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_section_progress ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Enable insert for authenticated users"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Subjects policies
CREATE POLICY "Everyone can read subjects"
  ON subjects FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage subjects"
  ON subjects FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.role = 'admin'
    )
  );

-- Modules policies
CREATE POLICY "Everyone can read modules"
  ON modules FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage modules"
  ON modules FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.role = 'admin'
    )
  );

-- Sections policies
CREATE POLICY "Everyone can read sections"
  ON sections FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage sections"
  ON sections FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.role = 'admin'
    )
  );

-- Questions policies
CREATE POLICY "Everyone can read questions"
  ON questions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage questions"
  ON questions FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.role = 'admin'
    )
  );

-- User progress policies
CREATE POLICY "Users can read own progress"
  ON user_progress FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own progress"
  ON user_progress FOR ALL
  TO authenticated
  USING (auth.uid() = user_id);

-- User section progress policies
CREATE POLICY "Users can read own section progress"
  ON user_section_progress FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own section progress"
  ON user_section_progress FOR ALL
  TO authenticated
  USING (auth.uid() = user_id);

-- Functions for automated progress tracking
CREATE OR REPLACE FUNCTION update_user_progress()
RETURNS TRIGGER AS $$
BEGIN
  -- Update overall progress when section progress changes
  INSERT INTO user_progress (user_id, subject_id, total_sections, completed_sections)
  SELECT 
    NEW.user_id,
    s.subject_id,
    COUNT(*) as total_sections,
    COUNT(*) FILTER (WHERE usp.is_completed = true) as completed_sections
  FROM sections sec
  JOIN modules m ON sec.module_id = m.id
  JOIN subjects s ON m.subject_id = s.id
  LEFT JOIN user_section_progress usp ON sec.id = usp.section_id AND usp.user_id = NEW.user_id
  WHERE s.id = (
    SELECT sub.id FROM subjects sub
    JOIN modules mod ON sub.id = mod.subject_id
    JOIN sections sect ON mod.id = sect.module_id
    WHERE sect.id = NEW.section_id
  )
  GROUP BY NEW.user_id, s.subject_id
  ON CONFLICT (user_id, subject_id)
  DO UPDATE SET
    total_sections = EXCLUDED.total_sections,
    completed_sections = EXCLUDED.completed_sections,
    last_accessed = now();
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for progress updates
CREATE TRIGGER trigger_update_user_progress
  AFTER INSERT OR UPDATE ON user_section_progress
  FOR EACH ROW
  EXECUTE FUNCTION update_user_progress();
