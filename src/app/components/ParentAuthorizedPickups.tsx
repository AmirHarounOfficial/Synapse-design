import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Plus, User, QrCode, X } from 'lucide-react';

interface AuthorizedPerson {
  id: string;
  name: string;
  relationship: string;
  phone: string;
  photoUrl?: string;
  isSelf?: boolean;
}

export function ParentAuthorizedPickups() {
  const navigate = useNavigate();
  const [showAddForm, setShowAddForm] = useState(false);
  const [people, setPeople] = useState<AuthorizedPerson[]>([
    {
      id: 'self',
      name: 'Jennifer Thompson',
      relationship: 'Mother',
      phone: '(555) 123-4567',
      isSelf: true
    }
  ]);

  const [formData, setFormData] = useState({
    name: '',
    relationship: '',
    phone: ''
  });

  const handleAddPerson = () => {
    if (formData.name && formData.relationship && formData.phone) {
      const newPerson: AuthorizedPerson = {
        id: Date.now().toString(),
        name: formData.name,
        relationship: formData.relationship,
        phone: formData.phone
      };
      setPeople([...people, newPerson]);
      setFormData({ name: '', relationship: '', phone: '' });
      setShowAddForm(false);
    }
  };

  const handleRemovePerson = (id: string) => {
    setPeople(people.filter(p => p.id !== id));
  };

  const handleContinue = () => {
    navigate('/parent/onboarding/complete');
  };

  const formatPhoneNumber = (value: string) => {
    const cleaned = value.replace(/\D/g, '');
    if (cleaned.length <= 3) return cleaned;
    if (cleaned.length <= 6) return `(${cleaned.slice(0, 3)}) ${cleaned.slice(3)}`;
    return `(${cleaned.slice(0, 3)}) ${cleaned.slice(3, 6)}-${cleaned.slice(6, 10)}`;
  };

  const handlePhoneChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const formatted = formatPhoneNumber(e.target.value);
    setFormData({ ...formData, phone: formatted });
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex flex-col">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Progress Bar */}
      <div className="h-1 bg-gray-100">
        <div className="h-full bg-[#2563EB]" style={{ width: '87.5%' }} />
      </div>

      {/* App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200">
        <button
          onClick={() => navigate(-1)}
          className="w-10 h-10 -ml-2 flex items-center justify-center"
        >
          <ArrowLeft className="w-6 h-6 text-gray-900" />
        </button>
        <h1 className="flex-1 text-center font-medium text-gray-900 pr-10">
          Step 4 of 4 — Authorized Pickups
        </h1>
      </header>

      {/* Content */}
      <div className="flex-1 overflow-y-auto px-4 py-4">
        <div className="mb-4">
          <h2 className="text-[17px] font-semibold text-gray-900 mb-2">
            Who can pick up Maya?
          </h2>
          <p className="text-[13px] text-[#64748B]">
            Add people authorized to pick up your child from school
          </p>
        </div>

        {/* Authorized People List */}
        <div className="space-y-3 mb-4">
          {people.map((person) => (
            <div
              key={person.id}
              className="bg-white rounded-xl border border-gray-200 p-4"
            >
              <div className="flex items-start gap-3">
                {/* Avatar */}
                <div className="w-12 h-12 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                  <User className="w-6 h-6 text-[#2563EB]" />
                </div>

                <div className="flex-1">
                  <div className="flex items-start justify-between mb-2">
                    <div>
                      <div className="text-[15px] font-medium text-gray-900 mb-0.5">
                        {person.name}
                        {person.isSelf && (
                          <span className="ml-2 text-[11px] text-[#64748B] font-normal">
                            (You)
                          </span>
                        )}
                      </div>
                      <div className="text-[13px] text-[#64748B]">
                        {person.relationship}
                      </div>
                    </div>
                    {!person.isSelf && (
                      <button
                        onClick={() => handleRemovePerson(person.id)}
                        className="w-8 h-8 -mr-2 -mt-1 flex items-center justify-center text-[#DC2626]"
                      >
                        <X className="w-5 h-5" />
                      </button>
                    )}
                  </div>

                  <div className="text-[13px] text-[#64748B] mb-3">
                    {person.phone}
                  </div>

                  {/* QR Code Button */}
                  <button className="w-full min-h-[44px] px-3 py-2 bg-[#F8FAFC] border border-gray-200 rounded-lg flex items-center justify-center gap-2 text-[13px] font-medium text-gray-900">
                    <QrCode className="w-4 h-4" />
                    {person.isSelf ? 'View QR Code' : 'QR Code Generated'}
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Add Person Button */}
        {!showAddForm && (
          <button
            onClick={() => setShowAddForm(true)}
            className="w-full min-h-[52px] px-4 py-3.5 bg-white text-[#2563EB] border-2 border-[#2563EB] rounded-lg text-[15px] font-semibold flex items-center justify-center gap-2"
          >
            <Plus className="w-5 h-5" />
            Add Person
          </button>
        )}

        {/* Add Person Form */}
        {showAddForm && (
          <div className="bg-white rounded-xl border border-gray-200 p-4 mb-4">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-[15px] font-semibold text-gray-900">
                Add Authorized Person
              </h3>
              <button
                onClick={() => setShowAddForm(false)}
                className="w-8 h-8 -mr-2 flex items-center justify-center"
              >
                <X className="w-5 h-5 text-gray-900" />
              </button>
            </div>

            <div className="space-y-3">
              <div>
                <label className="block text-[13px] font-medium text-gray-900 mb-1.5">
                  Full Name
                </label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  placeholder="John Smith"
                  className="w-full h-11 px-3 border border-gray-200 rounded-lg text-[15px] focus:outline-none focus:border-[#2563EB]"
                />
              </div>

              <div>
                <label className="block text-[13px] font-medium text-gray-900 mb-1.5">
                  Relationship
                </label>
                <select
                  value={formData.relationship}
                  onChange={(e) => setFormData({ ...formData, relationship: e.target.value })}
                  className="w-full h-11 px-3 border border-gray-200 rounded-lg text-[15px] focus:outline-none focus:border-[#2563EB]"
                >
                  <option value="">Select relationship</option>
                  <option value="Father">Father</option>
                  <option value="Mother">Mother</option>
                  <option value="Grandparent">Grandparent</option>
                  <option value="Aunt/Uncle">Aunt/Uncle</option>
                  <option value="Sibling">Sibling</option>
                  <option value="Guardian">Legal Guardian</option>
                  <option value="Other">Other</option>
                </select>
              </div>

              <div>
                <label className="block text-[13px] font-medium text-gray-900 mb-1.5">
                  Phone Number
                </label>
                <input
                  type="tel"
                  value={formData.phone}
                  onChange={handlePhoneChange}
                  placeholder="(555) 123-4567"
                  maxLength={14}
                  className="w-full h-11 px-3 border border-gray-200 rounded-lg text-[15px] focus:outline-none focus:border-[#2563EB]"
                />
              </div>

              <div className="bg-[#F8FAFC] border border-gray-200 rounded-lg p-3">
                <p className="text-[11px] text-[#64748B] leading-relaxed">
                  A unique QR code will be generated for this person. They will need to show this code to school security during pickup.
                </p>
              </div>

              <button
                onClick={handleAddPerson}
                disabled={!formData.name || !formData.relationship || !formData.phone}
                className="w-full min-h-[48px] px-4 py-3 bg-[#2563EB] text-white rounded-lg text-[15px] font-semibold disabled:opacity-40 disabled:cursor-not-allowed"
              >
                Add Person
              </button>
            </div>
          </div>
        )}

        {/* Security Note */}
        <div className="bg-[#EFF6FF] border border-[#2563EB] rounded-xl p-3">
          <p className="text-[12px] text-[#1E40AF] leading-relaxed">
            For security, all authorized persons must present a valid government-issued ID and their unique QR code during pickup. Photos are required for visual verification.
          </p>
        </div>
      </div>

      {/* Bottom Action */}
      <div className="p-4 border-t border-gray-200 bg-white">
        <button
          onClick={handleContinue}
          className="w-full min-h-[52px] px-4 py-3.5 bg-[#10B981] text-white rounded-lg text-[15px] font-semibold"
        >
          Complete Setup
        </button>
      </div>
    </div>
  );
}
