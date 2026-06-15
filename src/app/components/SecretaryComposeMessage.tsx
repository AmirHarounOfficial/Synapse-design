import { ArrowLeft, Search, AlertTriangle } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function SecretaryComposeMessage() {
  const navigate = useNavigate();
  const [recipient, setRecipient] = useState('');
  const [subject, setSubject] = useState('');
  const [body, setBody] = useState('');
  const [isUrgent, setIsUrgent] = useState(false);
  const [showRecipientSearch, setShowRecipientSearch] = useState(false);

  const recipients = [
    { id: '1', name: 'James Thompson', type: 'Parent', email: 'james.thompson@email.com' },
    { id: '2', name: 'Sarah Williams', type: 'Parent', email: 'sarah.williams@email.com' },
    { id: '3', name: 'Nurse Chen', type: 'Clinic', email: 'nurse.chen@school.edu' },
    { id: '4', name: 'Principal Rodriguez', type: 'Admin', email: 'principal@school.edu' }
  ];

  const handleSend = () => {
    if (recipient && subject && body) {
      alert(`Message sent to ${recipient}${isUrgent ? ' (marked as urgent)' : ''}`);
      navigate('/secretary/messages');
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
        <h1 className="text-[17px] font-medium text-[#0F172A] flex-1">
          Compose Message
        </h1>
        <button
          onClick={handleSend}
          disabled={!recipient || !subject || !body}
          className={`text-[15px] font-medium ${
            recipient && subject && body
              ? 'text-[#2563EB]'
              : 'text-gray-400'
          }`}
        >
          Send
        </button>
      </header>

      <div className="flex-1 overflow-y-auto">
        <div className="p-4 space-y-4">
          {/* Recipient Field */}
          <div>
            <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
              Recipient
            </label>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#64748B]" />
              <input
                type="text"
                placeholder="Search parent, clinic, or admin..."
                value={recipient}
                onChange={(e) => {
                  setRecipient(e.target.value);
                  setShowRecipientSearch(true);
                }}
                onFocus={() => setShowRecipientSearch(true)}
                className="w-full h-[48px] pl-10 pr-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] placeholder:text-[#94A3B8] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
              />
            </div>

            {showRecipientSearch && recipient && (
              <div className="mt-2 bg-white border border-gray-200 rounded-lg divide-y divide-gray-100 max-h-[200px] overflow-y-auto">
                {recipients
                  .filter(r => r.name.toLowerCase().includes(recipient.toLowerCase()))
                  .map((r) => (
                    <button
                      key={r.id}
                      onClick={() => {
                        setRecipient(r.name);
                        setShowRecipientSearch(false);
                      }}
                      className="w-full p-3 flex items-center gap-3 text-left active:bg-gray-50"
                    >
                      <div className="flex-1">
                        <div className="text-[14px] font-medium text-[#0F172A]">
                          {r.name}
                        </div>
                        <div className="text-[12px] text-[#64748B]">
                          {r.type} • {r.email}
                        </div>
                      </div>
                    </button>
                  ))}
              </div>
            )}
          </div>

          {/* Subject Field */}
          <div>
            <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
              Subject
            </label>
            <input
              type="text"
              placeholder="Message subject"
              value={subject}
              onChange={(e) => setSubject(e.target.value)}
              className="w-full h-[48px] px-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] placeholder:text-[#94A3B8] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
            />
          </div>

          {/* Body Field */}
          <div>
            <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
              Message
            </label>
            <textarea
              placeholder="Type your message..."
              value={body}
              onChange={(e) => setBody(e.target.value)}
              className="w-full h-[200px] p-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] placeholder:text-[#94A3B8] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent resize-none"
            />
          </div>

          {/* Mark as Urgent Toggle */}
          <div className="bg-white rounded-xl border border-gray-200 p-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2 flex-1">
                <AlertTriangle className={`w-5 h-5 flex-shrink-0 ${isUrgent ? 'text-[#F59E0B]' : 'text-[#64748B]'}`} />
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                    Mark as urgent
                  </div>
                  <div className="text-[12px] text-[#64748B]">
                    Shows amber indicator to recipient
                  </div>
                </div>
              </div>
              <button
                onClick={() => setIsUrgent(!isUrgent)}
                className={`w-11 h-6 rounded-full flex items-center px-1 transition-colors ${
                  isUrgent ? 'bg-[#F59E0B]' : 'bg-gray-300'
                }`}
              >
                <div className={`w-4 h-4 bg-white rounded-full transition-transform ${
                  isUrgent ? 'ml-auto' : ''
                }`} />
              </button>
            </div>
          </div>

          {/* Tips */}
          <div className="bg-[#F1F5F9] rounded-lg p-3">
            <p className="text-[12px] text-[#64748B] leading-relaxed">
              <strong>Tip:</strong> Messages are automatically logged in the school communication system. Parents will receive a notification via their preferred channel (email, SMS, or app).
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
