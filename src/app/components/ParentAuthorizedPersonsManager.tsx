import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, User, QrCode, Plus, Edit2, Trash2, X } from 'lucide-react';

interface AuthorizedPerson {
  id: string;
  name: string;
  relationship: string;
  phone: string;
  photoUrl?: string;
  isSelf?: boolean;
}

export function ParentAuthorizedPersonsManager() {
  const navigate = useNavigate();
  const [people, setPeople] = useState<AuthorizedPerson[]>([
    {
      id: 'self',
      name: 'Jennifer Thompson',
      relationship: 'Mother',
      phone: '(555) 123-4567',
      isSelf: true
    },
    {
      id: '1',
      name: 'Michael Thompson',
      relationship: 'Father',
      phone: '(555) 987-6543'
    },
    {
      id: '2',
      name: 'Barbara Thompson',
      relationship: 'Grandmother',
      phone: '(555) 456-7890'
    }
  ]);

  const [showQR, setShowQR] = useState<string | null>(null);
  const [showRemoveConfirm, setShowRemoveConfirm] = useState<string | null>(null);

  const handleShowQR = (personId: string) => {
    navigate(`/parent/app/full-qrcode/${personId}`);
  };

  const handleRemove = (personId: string) => {
    setPeople(people.filter(p => p.id !== personId));
    setShowRemoveConfirm(null);
  };

  const selectedPerson = people.find(p => p.id === showQR);

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="flex items-center px-4 h-14 bg-white border-b border-gray-200">
        <button
          onClick={() => navigate(-1)}
          className="w-10 h-10 -ml-2 flex items-center justify-center"
        >
          <ArrowLeft className="w-6 h-6 text-gray-900" />
        </button>
        <h1 className="flex-1 text-center font-medium text-gray-900 pr-10">
          Authorized Pickups
        </h1>
      </header>

      <div className="px-4 py-4 space-y-3">
        {/* Person Cards */}
        {people.map((person) => (
          <div
            key={person.id}
            className="bg-white rounded-xl border border-gray-200 p-4"
          >
            <div className="flex items-start gap-3 mb-4">
              {/* Avatar */}
              <div className="w-20 h-20 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                <User className="w-10 h-10 text-[#2563EB]" />
              </div>

              <div className="flex-1">
                <div className="text-[17px] font-semibold text-gray-900 mb-1">
                  {person.name}
                  {person.isSelf && (
                    <span className="ml-2 text-[12px] text-[#64748B] font-normal">
                      (You)
                    </span>
                  )}
                </div>
                <div className="text-[14px] text-[#64748B] mb-1">
                  {person.relationship}
                </div>
                <div className="text-[13px] text-[#64748B]">
                  {person.phone}
                </div>
              </div>

              {!person.isSelf && (
                <div className="flex gap-2">
                  <button className="w-9 h-9 flex items-center justify-center text-[#64748B]">
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => setShowRemoveConfirm(person.id)}
                    className="w-9 h-9 flex items-center justify-center text-[#DC2626]"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              )}
            </div>

            {/* QR Button */}
            <button
              onClick={() => handleShowQR(person.id)}
              className="w-full min-h-[48px] px-4 py-3 bg-[#2563EB] text-white rounded-lg flex items-center justify-center gap-2 text-[15px] font-semibold"
            >
              <QrCode className="w-5 h-5" />
              View QR Code
            </button>
          </div>
        ))}

        {/* Add Person Card */}
        <button
          onClick={() => navigate('/parent/app/add-authorized-person')}
          className="w-full min-h-[80px] bg-white border-2 border-dashed border-gray-300 rounded-xl flex items-center justify-center gap-2 text-[#2563EB] active:bg-gray-50"
        >
          <Plus className="w-6 h-6" />
          <span className="text-[15px] font-semibold">Add Person</span>
        </button>

        {/* Security Info */}
        <div className="bg-[#EFF6FF] border border-[#2563EB] rounded-xl p-4">
          <p className="text-[12px] text-[#1E40AF] leading-relaxed">
            All authorized persons must present their unique QR code and a valid government-issued ID to school security during pickup. QR codes rotate every 24 hours for security.
          </p>
        </div>
      </div>

      {/* Remove Confirmation */}
      {showRemoveConfirm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50">
          <div className="bg-white rounded-2xl p-6 max-w-sm w-full">
            <div className="w-16 h-16 rounded-full bg-[#FEE2E2] flex items-center justify-center mx-auto mb-4">
              <Trash2 className="w-8 h-8 text-[#DC2626]" />
            </div>

            <h3 className="text-[17px] font-semibold text-gray-900 mb-2 text-center">
              Remove Authorized Person?
            </h3>
            <p className="text-[14px] text-[#64748B] mb-6 text-center">
              This person will no longer be able to pick up your child from school. This action can be undone by adding them again.
            </p>

            <div className="flex gap-3">
              <button
                onClick={() => setShowRemoveConfirm(null)}
                className="flex-1 min-h-[52px] px-4 py-3.5 bg-white text-gray-900 border border-gray-200 rounded-lg text-[15px] font-medium"
              >
                Cancel
              </button>
              <button
                onClick={() => handleRemove(showRemoveConfirm)}
                className="flex-1 min-h-[52px] px-4 py-3.5 bg-[#DC2626] text-white rounded-lg text-[15px] font-semibold"
              >
                Remove
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}