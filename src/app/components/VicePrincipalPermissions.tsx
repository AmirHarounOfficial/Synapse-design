import { ArrowLeft, Check, Lock, X, Mail } from 'lucide-react';
import { useNavigate } from 'react-router';

export function VicePrincipalPermissions() {
  const navigate = useNavigate();

  const permissions = [
    {
      id: '1',
      name: 'View aggregate health analytics',
      icon: Check,
      granted: true
    },
    {
      id: '2',
      name: 'View clinic readiness reports',
      icon: Check,
      granted: true
    },
    {
      id: '3',
      name: 'Manage staff accounts',
      icon: X,
      granted: false
    },
    {
      id: '4',
      name: 'Issue weather advisories',
      icon: X,
      granted: false
    },
    {
      id: '5',
      name: 'Access audit log',
      icon: X,
      granted: false
    },
    {
      id: '6',
      name: 'After-hours override authority',
      icon: X,
      granted: false
    },
    {
      id: '7',
      name: 'View student medical records',
      icon: X,
      granted: false
    },
    {
      id: '8',
      name: 'Modify permission matrix',
      icon: X,
      granted: false
    }
  ];

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
          My Access Level
        </h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {/* Header */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="text-[14px] font-medium text-[#0F172A] mb-1">
            Permissions granted by Principal M. Davis
          </div>
          <div className="text-[12px] text-[#64748B]">
            Delegated on May 1, 2026
          </div>
        </div>

        {/* Permissions List */}
        <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
          {permissions.map((permission) => {
            const Icon = permission.icon;
            return (
              <div key={permission.id} className="p-4 flex items-center gap-3">
                <div className={`w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${
                  permission.granted ? 'bg-[#D1FAE5]' : 'bg-[#F1F5F9]'
                }`}>
                  <Icon className={`w-5 h-5 ${
                    permission.granted ? 'text-[#10B981]' : 'text-[#64748B]'
                  }`} />
                </div>
                <div className="flex-1">
                  <div className="text-[14px] font-medium text-[#0F172A] mb-1">
                    {permission.name}
                  </div>
                  <div className={`inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium ${
                    permission.granted
                      ? 'bg-[#D1FAE5] text-[#10B981]'
                      : 'bg-[#F1F5F9] text-[#64748B]'
                  }`}>
                    {permission.granted ? 'Granted ✓' : 'Not granted'}
                  </div>
                </div>
                {!permission.granted && (
                  <Lock className="w-4 h-4 text-[#64748B] flex-shrink-0" />
                )}
              </div>
            );
          })}
        </div>

        {/* Request Additional Access */}
        <button
          onClick={() => navigate('/vice-principal/messages?compose=principal')}
          className="w-full bg-white rounded-xl border border-gray-200 p-4 flex items-center justify-center gap-2 active:bg-gray-50"
        >
          <Mail className="w-5 h-5 text-[#2563EB]" />
          <span className="text-[14px] font-medium text-[#2563EB]">
            Request additional permissions
          </span>
        </button>

        {/* Info */}
        <div className="bg-[#F1F5F9] rounded-lg p-3">
          <p className="text-[12px] text-[#64748B] leading-relaxed">
            Your access level is determined by the Principal. To request changes to your permissions, send a message explaining what additional access you need and why.
          </p>
        </div>
      </div>
    </div>
  );
}
