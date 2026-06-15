import { ArrowLeft, Search, Cloud, CheckCircle } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function CounselorTagEntry() {
  const navigate = useNavigate();
  const isRamadanActive = localStorage.getItem('sys_ramadan_active') === 'true';
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedStudent, setSelectedStudent] = useState<string | null>(null);
  const [selectedTags, setSelectedTags] = useState<string[]>([]);
  const [notes, setNotes] = useState('');

  const availableTags = [
    'Sensory overload',
    'Confusion / disorientation',
    'Headache',
    'Anxiety / tension',
    'Low mood',
    'Withdrawn',
    'Sad',
    'Restless',
    'Difficulty focusing',
    'Other (free text)'
  ];

  const students = [
    { id: '1', name: 'Maya Thompson', grade: '4th Grade' },
    { id: '2', name: 'Ethan Williams', grade: '5th Grade' },
    { id: '3', name: 'Sophia Martinez', grade: '4th Grade' }
  ];

  const filteredStudents = students.filter(s =>
    s.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleTagToggle = (tag: string) => {
    if (selectedTags.includes(tag)) {
      setSelectedTags(selectedTags.filter(t => t !== tag));
    } else if (selectedTags.length < 3) {
      setSelectedTags([...selectedTags, tag]);
    }
  };

  const handleSubmit = () => {
    if (selectedStudent && selectedTags.length > 0) {
      // In real app, would submit to API
      navigate('/counselor/home');
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex flex-col" style={{ width: '393px', height: '852px' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200 px-4 py-3 flex items-center gap-3">
        <button
          onClick={() => navigate(-1)}
          className="p-2 -ml-2 hover:bg-gray-100 rounded-lg transition-colors min-w-[44px] min-h-[44px] flex items-center justify-center"
          aria-label="Go back"
        >
          <ArrowLeft className="w-5 h-5 text-[#0F172A]" />
        </button>
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          Add Wellbeing Tag
        </h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {/* Student Selector */}
        <div>
          <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
            Student
          </label>
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#64748B]" />
            <input
              type="text"
              placeholder="Search student name..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full h-[44px] pl-10 pr-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] placeholder:text-[#94A3B8] focus:outline-none focus:ring-2 focus:ring-[#7C3AED] focus:border-transparent"
            />
          </div>

          {searchQuery && (
            <div className="mt-2 bg-white border border-gray-200 rounded-lg divide-y divide-gray-100 max-h-[160px] overflow-y-auto">
              {filteredStudents.map((student) => (
                <button
                   key={student.id}
                  onClick={() => {
                    setSelectedStudent(student.id);
                    setSearchQuery(student.name);
                  }}
                  className="w-full p-3 flex items-center gap-3 text-left active:bg-gray-50"
                >
                  <div className="w-8 h-8 rounded-full bg-[#F3F0FF] flex items-center justify-center flex-shrink-0">
                    <span className="text-xs font-medium text-[#7C3AED]">
                      {student.name.split(' ').map(n => n[0]).join('')}
                    </span>
                  </div>
                  <div className="flex-1">
                    <div className="text-[14px] font-medium text-[#0F172A]">
                      {student.name}
                    </div>
                    <div className="text-[12px] text-[#64748B]">
                      {student.grade}
                    </div>
                  </div>
                  {selectedStudent === student.id && (
                    <CheckCircle className="w-5 h-5 text-[#10B981]" />
                  )}
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Environmental Context */}
        <div className="bg-[#EFF6FF] border border-[#BFDBFE] rounded-lg p-3">
          <div className="flex items-start gap-2">
            <Cloud className="w-4 h-4 text-[#2563EB] flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <div className="text-[12px] font-medium text-[#1E40AF] mb-0.5">
                Environmental Context (auto-captured)
              </div>
              <div className="text-[12px] text-[#1E40AF]">
                Current conditions: AQI Advisory, Indoor only{isRamadanActive ? ' • Ramadan Mode Active' : ''}
              </div>
            </div>
          </div>
        </div>

        {/* Seasonal Tags (Conditional) */}
        {isRamadanActive && (
          <div>
            <div className="flex items-center justify-between mb-2">
              <label className="block text-[13px] font-semibold text-[#B45309] flex items-center gap-1.5">
                <span>🌙</span> Seasonal Tags (Ramadan Mode)
              </label>
            </div>
            <div className="flex flex-wrap gap-2 p-3 bg-amber-50 rounded-lg border border-amber-100">
              {['Ramadan fatigue · إجهاد رمضان'].map((tag) => {
                const isSelected = selectedTags.includes(tag);
                const isDisabled = !isSelected && selectedTags.length >= 3;

                return (
                  <button
                    key={tag}
                    onClick={() => handleTagToggle(tag)}
                    disabled={isDisabled}
                    className={`px-3 py-2 rounded-full text-[13px] font-medium transition-colors min-h-[36px] ${
                      isSelected
                        ? 'bg-[#B45309] text-white'
                        : isDisabled
                        ? 'bg-amber-100 text-amber-400 cursor-not-allowed opacity-50'
                        : 'bg-[#FFFBEB] text-[#B45309] border border-[#FDE68A] active:bg-[#FEF3C7]'
                    }`}
                  >
                    {tag}
                  </button>
                );
              })}
            </div>
          </div>
        )}

        {/* Psychosocial Tags */}
        <div>
          <div className="flex items-center justify-between mb-2">
            <label className="block text-[13px] font-medium text-[#0F172A]">
              Psychosocial Tags
            </label>
            <span className="text-[12px] text-[#64748B]">
              {selectedTags.length}/3 selected
            </span>
          </div>
          <div className="flex flex-wrap gap-2">
            {availableTags.map((tag) => {
              const isSelected = selectedTags.includes(tag);
              const isDisabled = !isSelected && selectedTags.length >= 3;

              return (
                <button
                  key={tag}
                  onClick={() => handleTagToggle(tag)}
                  disabled={isDisabled}
                  className={`px-3 py-2 rounded-full text-[13px] font-medium transition-colors min-h-[36px] ${
                    isSelected
                      ? 'bg-[#7C3AED] text-white'
                      : isDisabled
                      ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                      : 'bg-[#F3F0FF] text-[#7C3AED] active:bg-[#EDE9FE]'
                  }`}
                >
                  {tag}
                </button>
              );
            })}
          </div>
        </div>

        {/* Notes */}
        <div>
          <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
            Notes (optional)
          </label>
          <textarea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Context or observations (confidential)"
            className="w-full h-[80px] p-3 bg-white border border-gray-300 rounded-lg text-[14px] text-[#0F172A] placeholder:text-[#94A3B8] focus:outline-none focus:ring-2 focus:ring-[#7C3AED] focus:border-transparent resize-none"
          />
        </div>

        {/* Visibility Notice */}
        <div className="bg-[#FEF3C7] border border-[#FDE68A] rounded-lg p-3">
          <p className="text-[12px] text-[#92400E] leading-relaxed">
            <strong>Privacy Notice:</strong> These notes are visible only to you and the school Principal.
          </p>
        </div>
      </div>

      {/* Bottom Button */}
      <div className="bg-white border-t border-gray-200 p-4">
        <button
          onClick={handleSubmit}
          disabled={!selectedStudent || selectedTags.length === 0}
          className={`w-full h-[48px] rounded-lg font-medium text-[15px] transition-colors ${
            selectedStudent && selectedTags.length > 0
              ? 'bg-[#10B981] text-white active:bg-[#059669]'
              : 'bg-gray-200 text-gray-400 cursor-not-allowed'
          }`}
        >
          Log Tag
        </button>
      </div>
    </div>
  );
}
