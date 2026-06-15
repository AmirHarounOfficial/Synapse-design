import { ArrowLeft, CheckCircle, AlertTriangle, Info } from 'lucide-react';
import { useNavigate, useParams } from 'react-router';
import { useState } from 'react';
import { LicenseAuthoritySelector } from './LicenseAuthoritySelector';

export function PrincipalAddEditStaff() {
  const navigate = useNavigate();
  const { staffId } = useParams();
  const isEditing = !!staffId;

  const [firstName, setFirstName] = useState(isEditing ? 'Sarah' : '');
  const [lastName, setLastName] = useState(isEditing ? 'Chen' : '');
  const [email, setEmail] = useState(isEditing ? 'sarah.chen@synapse.ae' : '');
  const [emailValid, setEmailValid] = useState(isEditing);
  const [selectedRole, setSelectedRole] = useState(isEditing ? 'nurse' : '');
  const [isActive, setIsActive] = useState(isEditing ? true : true);

  // Medical licensing fields (UAE DHA mandate)
  const [licenseAuthority, setLicenseAuthority] = useState('');
  const [licenseNumber, setLicenseNumber] = useState('');
  const [licenseExpiry, setLicenseExpiry] = useState('');
  const [specialty, setSpecialty] = useState('GP');

  const roles = [
    { id: 'nurse', label: 'School Nurse', permissions: 'Clinic visit categories · Medical alerts/contraindications only · No medication details' },
    { id: 'physician', label: 'School Physician', permissions: 'Manage medications · Protocol approvals · Clinical escalation triage' },
    { id: 'vice-principal', label: 'Vice Principal', permissions: 'All student records · Staff management · System settings' },
    { id: 'secretary', label: 'Secretary', permissions: 'Student directory (no medical) · Parent messages · Document imports' },
    { id: 'class-teacher', label: 'Class Teacher', permissions: 'Class roster · Health considerations · Attendance only' },
    { id: 'pe-teacher', label: 'PE Teacher', permissions: 'Activity restrictions · Weather advisories · No clinic data' },
    { id: 'music-teacher', label: 'Music Teacher', permissions: 'Activity restrictions · Weather advisories · No clinic data' },
    { id: 'counselor', label: 'Counselor', permissions: 'Psychosocial records only · No medical data · Confidential notes' },
    { id: 'cafeteria', label: 'Cafeteria', permissions: 'Allergen alerts only · No clinic data · Delivery confirmations' },
    { id: 'security', label: 'Security Guard', permissions: 'Pickup authorizations · QR verification · No health data' },
    { id: 'driver', label: 'Bus Driver', permissions: 'Route roster · Boarding status · No health data' }
  ];

  const validateEmail = (email: string) => {
    // Validate AE domains or school domain
    const isValid = email.includes('@') && (email.endsWith('.ae') || email.endsWith('@synapse.ae') || email.endsWith('@school.ae') || email.endsWith('@lakewood.edu'));
    setEmailValid(isValid);
  };

  const handleEmailBlur = () => {
    if (email) {
      validateEmail(email);
    }
  };

  const isLicenseValid = (selectedRole !== 'nurse' && selectedRole !== 'physician') || (licenseAuthority && licenseNumber && licenseExpiry);

  const handleSubmit = () => {
    if (firstName && lastName && email && emailValid && selectedRole && isLicenseValid) {
      alert(isEditing ? 'Staff account updated successfully' : 'Invitation sent to staff member');
      navigate('/principal/staff');
    }
  };

  const selectedRoleData = roles.find(r => r.id === selectedRole);

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
          {isEditing ? 'Edit Staff' : 'Add Staff'}
        </h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {/* Personal Info */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h3 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Personal Information
          </h3>
          <div className="space-y-3">
            <div>
              <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
                First Name
              </label>
              <input
                type="text"
                value={firstName}
                onChange={(e) => setFirstName(e.target.value)}
                placeholder="Enter first name"
                className="w-full h-[44px] px-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] placeholder:text-[#94A3B8] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
                Last Name
              </label>
              <input
                type="text"
                value={lastName}
                onChange={(e) => setLastName(e.target.value)}
                placeholder="Enter last name"
                className="w-full h-[44px] px-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] placeholder:text-[#94A3B8] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-[13px] font-medium text-[#0F172A] mb-2">
                School Email
              </label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                onBlur={handleEmailBlur}
                placeholder="name@synapse.ae"
                className="w-full h-[44px] px-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] placeholder:text-[#94A3B8] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
              />
              {email && emailValid && (
                <div className="flex items-center gap-1 mt-2">
                  <CheckCircle className="w-4 h-4 text-[#10B981]" />
                  <span className="text-[12px] text-[#10B981]">✓ Valid school email</span>
                </div>
              )}
              {email && !emailValid && (
                <div className="flex items-center gap-1 mt-2">
                  <AlertTriangle className="w-4 h-4 text-[#DC2626]" />
                  <span className="text-[12px] text-[#DC2626]">Must use a valid school email address (.ae or @synapse.ae)</span>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Role Assignment */}
        <div>
          <h3 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Role Assignment
          </h3>
          <div className="grid grid-cols-2 gap-2">
            {roles.map((role) => (
              <button
                key={role.id}
                type="button"
                onClick={() => setSelectedRole(role.id)}
                className={`p-3 rounded-lg border-2 text-[13px] font-medium transition-colors min-h-[56px] ${
                  selectedRole === role.id
                    ? 'border-[#2563EB] bg-[#EFF6FF] text-[#2563EB]'
                    : 'border-gray-200 bg-white text-[#0F172A] active:bg-gray-50'
                }`}
              >
                {role.label}
              </button>
            ))}
          </div>
        </div>

        {/* UAE License Fields for nurse or physician */}
        {(selectedRole === 'nurse' || selectedRole === 'physician') && (
          <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4 text-left">
            <h3 className="text-[14px] font-semibold text-[#0F172A] mb-1">
              Medical License Details
            </h3>
            
            <LicenseAuthoritySelector 
              value={licenseAuthority} 
              onChangeValue={setLicenseAuthority} 
              schoolEmirate="Dubai" 
            />

            <div className="space-y-3 pt-2">
              <div>
                <label className="block text-[13px] font-medium text-[#0F172A] mb-1.5">
                  License Number
                </label>
                <input
                  type="text"
                  value={licenseNumber}
                  onChange={(e) => setLicenseNumber(e.target.value)}
                  placeholder={`${licenseAuthority || 'DHA'}-XXXX-XX`}
                  className="w-full h-[44px] px-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-[13px] font-medium text-[#0F172A] mb-1.5">
                  License Expiry Date
                </label>
                <input
                  type="date"
                  value={licenseExpiry}
                  onChange={(e) => setLicenseExpiry(e.target.value)}
                  className="w-full h-[44px] px-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
                />
              </div>

              {selectedRole === 'physician' && (
                <div>
                  <label className="block text-[13px] font-medium text-[#0F172A] mb-1.5">
                    Specialty
                  </label>
                  <select
                    value={specialty}
                    onChange={(e) => setSpecialty(e.target.value)}
                    className="w-full h-[44px] px-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
                  >
                    <option value="GP">General Practitioner</option>
                    <option value="Pediatrician">Pediatrician</option>
                    <option value="Other">Other Specialist</option>
                  </select>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Permissions Preview */}
        {selectedRoleData && (
          <div className="bg-[#F1F5F9] rounded-lg p-4">
            <div className="flex items-start gap-2">
              <Info className="w-4 h-4 text-[#64748B] flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <div className="text-[12px] font-medium text-[#0F172A] mb-1">
                  Permissions for this role
                </div>
                <div className="text-[12px] text-[#64748B] leading-relaxed">
                  This role will see: {selectedRoleData.permissions}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Status */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="flex items-center justify-between">
            <div className="flex-1">
              <div className="text-[14px] font-medium text-[#0F172A] mb-0.5">
                Account Status
              </div>
              <div className="text-[12px] text-[#64748B]">
                {isActive ? 'User can access the system' : 'User cannot log in'}
              </div>
            </div>
            <button
              onClick={() => setIsActive(!isActive)}
              className={`w-11 h-6 rounded-full flex items-center px-1 transition-colors ${
                isActive ? 'bg-[#10B981]' : 'bg-gray-300'
              }`}
            >
              <div className={`w-4 h-4 bg-white rounded-full transition-transform ${
                isActive ? 'ml-auto' : ''
              }`} />
            </button>
          </div>
        </div>

        {/* Confidentiality Agreement Notice */}
        {!isEditing && (
          <div className="bg-[#FEF3C7] border border-[#FDE68A] rounded-lg p-4">
            <div className="flex items-start gap-2">
              <AlertTriangle className="w-4 h-4 text-[#F59E0B] flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <div className="text-[12px] font-medium text-[#92400E] mb-1">
                  Confidentiality Agreement Required
                </div>
                <div className="text-[12px] text-[#92400E] leading-relaxed">
                  User will be required to sign {selectedRoleData?.label || 'Role'} confidentiality agreement on first login
                </div>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Bottom Button */}
      <div className="bg-white border-t border-gray-200 p-4">
        <button
          onClick={handleSubmit}
          disabled={!firstName || !lastName || !email || !emailValid || !selectedRole || !isLicenseValid}
          className={`w-full h-[48px] rounded-lg font-medium text-[15px] transition-colors ${
            firstName && lastName && email && emailValid && selectedRole && isLicenseValid
              ? 'bg-[#2563EB] text-white active:bg-[#1D4ED8]'
              : 'bg-gray-200 text-gray-400 cursor-not-allowed'
          }`}
        >
          {isEditing ? 'Save changes' : 'Send invitation'}
        </button>
      </div>
    </div>
  );
}
