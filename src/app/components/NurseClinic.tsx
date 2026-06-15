export function NurseClinic() {
  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* App Bar */}
      <div className="h-[56px] bg-[#FFFFFF] px-4 flex items-center border-b border-[#E2E8F0]">
        <h1 className="text-[17px] font-medium text-[#0F172A]" style={{ fontWeight: 500 }}>
          Clinic Visits
        </h1>
      </div>

      {/* Placeholder Content */}
      <div className="px-4 pt-6">
        <p className="text-[#64748B]">Nurse Clinic View</p>
      </div>
    </div>
  );
}
