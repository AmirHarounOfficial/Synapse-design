import { ArrowLeft, CloudAlert, ExternalLink, AlertTriangle } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';
import { WhatsAppToggleRow } from './WhatsAppToggleRow';

export function PrincipalWeatherAdvisory() {
  const navigate = useNavigate();
  const [advisoryActive, setAdvisoryActive] = useState(false);
  const [showForm, setShowForm] = useState(false);
  const [advisoryType, setAdvisoryType] = useState('haboob');
  const [affectedGroups, setAffectedGroups] = useState<string[]>(['asthma']);
  const [message, setMessage] = useState('Due to an active Haboob (sandstorm) warning from UAE NCM, students with respiratory conditions must remain indoors. Outdoor recess suspended.');
  const [sendToStaff, setSendToStaff] = useState(true);
  const [sendToAffectedParents, setSendToAffectedParents] = useState(true);
  const [sendToAllParents, setSendToAllParents] = useState(false);
  const [sendWhatsApp, setSendWhatsApp] = useState(true);

  const aqiData = {
    temperature: '42°C',
    aqi: 156,
    condition: 'Haboob / Active Sandstorm Advisory (Source: UAE NCM)',
    level: 'unhealthy' as 'good' | 'moderate' | 'unhealthy-sensitive' | 'unhealthy'
  };

  const aqiColors = {
    'good': { bg: 'bg-[#D1FAE5]', text: 'text-[#10B981]', border: 'border-[#10B981]' },
    'moderate': { bg: 'bg-[#FEF3C7]', text: 'text-[#F59E0B]', border: 'border-[#F59E0B]' },
    'unhealthy-sensitive': { bg: 'bg-[#FED7AA]', text: 'text-[#F97316]', border: 'border-[#F97316]' },
    'unhealthy': { bg: 'bg-[#FEE2E2]', text: 'text-[#DC2626]', border: 'border-[#DC2626]' }
  };

  const currentAqi = aqiColors[aqiData.level];

  const advisoryTypes = [
    { id: 'haboob', label: 'Haboob (Sandstorm) / عاصفة رملية' },
    { id: 'aqi-dust', label: 'AQI / Dust' },
    { id: 'heat', label: 'Extreme Heat' },
    { id: 'flooding', label: 'Flooding' },
    { id: 'other', label: 'Other' }
  ];

  const affectedGroupOptions = [
    { id: 'asthma', label: 'Asthma students' },
    { id: 'all-students', label: 'All students' },
    { id: 'outdoor', label: 'Outdoor activities' },
    { id: 'bus', label: 'Bus routes' }
  ];

  const toggleAffectedGroup = (groupId: string) => {
    if (affectedGroups.includes(groupId)) {
      setAffectedGroups(affectedGroups.filter(g => g !== groupId));
    } else {
      setAffectedGroups([...affectedGroups, groupId]);
    }
  };

  const handleIssueAdvisory = () => {
    if (window.confirm('Issue advisory and send alerts to all selected recipients?')) {
      setAdvisoryActive(true);
      setShowForm(false);
      alert('Advisory issued successfully. Alerts sent to staff and parents.');
    }
  };

  const handleLiftAdvisory = () => {
    if (window.confirm('Lift the current advisory? All recipients will be notified.')) {
      setAdvisoryActive(false);
      alert('Advisory lifted. Notifications sent.');
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
          Weather Advisory
        </h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {/* Current Conditions Card */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Current Conditions
          </h2>
          <div className="grid grid-cols-2 gap-3 mb-3">
            <div>
              <div className="text-[11px] text-[#64748B] mb-0.5">Temperature</div>
              <div className="text-[16px] font-semibold text-[#0F172A]">{aqiData.temperature}</div>
            </div>
            <div>
              <div className="text-[11px] text-[#64748B] mb-0.5">AQI Score</div>
              <div className={`inline-flex items-center px-2 py-1 rounded-full text-[13px] font-semibold ${currentAqi.bg} ${currentAqi.text}`}>
                {aqiData.aqi}
              </div>
            </div>
          </div>
          <div className={`p-3 rounded-lg border ${currentAqi.border} ${currentAqi.bg} mb-3`}>
            <div className={`text-[12px] font-medium ${currentAqi.text}`}>
              {aqiData.condition}
            </div>
          </div>
          <button className="flex items-center gap-2 text-[13px] text-[#2563EB] font-medium">
            View full forecast
            <ExternalLink className="w-4 h-4" />
          </button>
        </div>

        {/* Advisory Status */}
        {!advisoryActive ? (
          <div className="bg-white rounded-xl border border-gray-200 p-4">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <CloudAlert className="w-5 h-5 text-[#64748B]" />
                <span className="text-[14px] font-medium text-[#0F172A]">No active advisory</span>
              </div>
            </div>
            {!showForm && (
              <button
                onClick={() => setShowForm(true)}
                className="w-full h-[44px] bg-[#2563EB] text-white rounded-lg font-medium text-[14px] active:bg-[#1D4ED8]"
              >
                Issue Advisory
              </button>
            )}
          </div>
        ) : (
          <div className="bg-[#FEF3C7] border border-[#F59E0B] rounded-xl p-4">
            <div className="flex items-start gap-3 mb-3">
              <AlertTriangle className="w-5 h-5 text-[#F59E0B] flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <div className="text-[14px] font-semibold text-[#92400E] mb-1">
                  ⚠ Advisory Active since 08:00 AM
                </div>
                <div className="text-[12px] text-[#92400E]">
                  All staff and affected parents have been notified
                </div>
              </div>
            </div>
            <button
              onClick={handleLiftAdvisory}
              className="w-full h-[44px] bg-white border border-[#F59E0B] text-[#92400E] rounded-lg font-medium text-[14px] active:bg-[#FEF3C7]"
            >
              Lift advisory
            </button>
          </div>
        )}

        {/* Issue Advisory Form */}
        {showForm && !advisoryActive && (
          <>
            {/* Advisory Type */}
            <div className="bg-white rounded-xl border border-gray-200 p-4">
              <h3 className="text-[13px] font-semibold text-[#0F172A] mb-3">
                Advisory Type
              </h3>
              <div className="flex flex-wrap gap-2">
                {advisoryTypes.map((type) => (
                  <button
                    key={type.id}
                    onClick={() => setAdvisoryType(type.id)}
                    className={`px-3 py-2 rounded-full text-[13px] font-medium transition-colors ${
                      advisoryType === type.id
                        ? 'bg-[#2563EB] text-white'
                        : 'bg-[#F1F5F9] text-[#64748B] active:bg-[#E2E8F0]'
                    }`}
                  >
                    {type.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Affected Groups */}
            <div className="bg-white rounded-xl border border-gray-200 p-4">
              <h3 className="text-[13px] font-semibold text-[#0F172A] mb-3">
                Affected Groups
              </h3>
              <div className="space-y-2">
                {affectedGroupOptions.map((group) => (
                  <label key={group.id} className="flex items-center gap-3">
                    <input
                      type="checkbox"
                      checked={affectedGroups.includes(group.id)}
                      onChange={() => toggleAffectedGroup(group.id)}
                      className="w-5 h-5 rounded border-gray-300 text-[#2563EB] focus:ring-[#2563EB]"
                    />
                    <span className="text-[14px] text-[#0F172A]">{group.label}</span>
                  </label>
                ))}
              </div>
            </div>

            {/* Message */}
            <div className="bg-white rounded-xl border border-gray-200 p-4">
              <h3 className="text-[13px] font-semibold text-[#0F172A] mb-2">
                Advisory Message
              </h3>
              <textarea
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                className="w-full h-[100px] p-3 bg-white border border-gray-300 rounded-lg text-[14px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent resize-none"
              />
            </div>

            {/* Send To */}
            <div className="bg-white rounded-xl border border-gray-200 p-4">
              <h3 className="text-[13px] font-semibold text-[#0F172A] mb-3">
                Send Alerts To
              </h3>
              <div className="space-y-3">
                <label className="flex items-center gap-3">
                  <input
                    type="checkbox"
                    checked={sendToStaff}
                    onChange={() => setSendToStaff(!sendToStaff)}
                    className="w-5 h-5 rounded border-gray-300 text-[#2563EB] focus:ring-[#2563EB]"
                  />
                  <span className="text-[14px] text-[#0F172A]">All staff</span>
                </label>
                <label className="flex items-center gap-3">
                  <input
                    type="checkbox"
                    checked={sendToAffectedParents}
                    onChange={() => setSendToAffectedParents(!sendToAffectedParents)}
                    className="w-5 h-5 rounded border-gray-300 text-[#2563EB] focus:ring-[#2563EB]"
                  />
                  <span className="text-[14px] text-[#0F172A]">Affected parents only</span>
                </label>
                <label className="flex items-center gap-3">
                  <input
                    type="checkbox"
                    checked={sendToAllParents}
                    onChange={() => setSendToAllParents(!sendToAllParents)}
                    className="w-5 h-5 rounded border-gray-300 text-[#2563EB] focus:ring-[#2563EB]"
                  />
                  <span className="text-[14px] text-[#0F172A]">All parents</span>
                </label>
                <div className="border-t border-gray-100 pt-1">
                  <WhatsAppToggleRow checked={sendWhatsApp} onChange={setSendWhatsApp} />
                </div>
              </div>
            </div>

            {/* Issue Button */}
            <button
              onClick={handleIssueAdvisory}
              disabled={affectedGroups.length === 0 || !message}
              className={`w-full h-[48px] rounded-lg font-medium text-[15px] border-2 transition-colors ${
                affectedGroups.length > 0 && message
                  ? 'border-[#DC2626] text-[#DC2626] active:bg-[#FEE2E2]'
                  : 'border-gray-200 text-gray-400 cursor-not-allowed'
              }`}
            >
              Issue Advisory & Send Alerts
            </button>
          </>
        )}
      </div>
    </div>
  );
}
