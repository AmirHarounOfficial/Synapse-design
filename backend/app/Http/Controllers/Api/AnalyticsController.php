<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ClinicVisit;
use App\Models\DoseAdministration;
use App\Models\Document;
use App\Models\EmergencyConsent;
use App\Models\Medication;
use App\Models\Student;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Read-only aggregations over existing tables, always scoped to the
 * authenticated user's school. Returns plain associative arrays (no API
 * resources). Every count guards against empty tables and divide-by-zero.
 *
 * Scoping note: `clinic_visits` carries `school_id` directly, but
 * `medications`, `documents`, `emergency_consents` and `dose_administrations`
 * do NOT — they are scoped through their `student` relationship.
 */
class AnalyticsController extends Controller
{
    /**
     * GET /api/analytics/overview — headline counts for dashboard tiles.
     */
    public function overview(Request $request): JsonResponse
    {
        $schoolId = $request->user()->school_id;

        return response()->json([
            'total_students' => Student::where('school_id', $schoolId)->count(),
            'active_medications' => $this->medicationsForSchool($schoolId)
                ->where('status', 'active')->count(),
            'clinic_visits_today' => ClinicVisit::where('school_id', $schoolId)
                ->whereDate('visited_at', now()->toDateString())->count(),
            'clinic_visits_this_week' => ClinicVisit::where('school_id', $schoolId)
                ->whereBetween('visited_at', [now()->startOfWeek(), now()->endOfWeek()])->count(),
            'pending_documents' => $this->documentsForSchool($schoolId)
                ->where('status', 'pending')->count(),
            'open_emergency_consents' => $this->emergencyConsentsForSchool($schoolId)
                ->where('status', 'pending')->count(),
            'low_supply_medications' => $this->lowSupplyQuery($schoolId)->count(),
        ]);
    }

    /**
     * GET /api/analytics/health — breakdowns for the health-analytics charts.
     */
    public function health(Request $request): JsonResponse
    {
        $schoolId = $request->user()->school_id;

        return response()->json([
            'clinic_visits_by_severity' => ClinicVisit::where('school_id', $schoolId)
                ->selectRaw('severity, COUNT(*) as total')
                ->groupBy('severity')
                ->pluck('total', 'severity')
                ->all(),
            'clinic_visits_by_category' => ClinicVisit::where('school_id', $schoolId)
                ->selectRaw('reason as category, COUNT(*) as total')
                ->groupBy('reason')
                ->orderByDesc('total')
                ->pluck('total', 'category')
                ->all(),
            'medications_by_status' => $this->medicationsForSchool($schoolId)
                ->selectRaw('status, COUNT(*) as total')
                ->groupBy('status')
                ->pluck('total', 'status')
                ->all(),
            'students_with_allergens' => Student::where('school_id', $schoolId)
                ->whereHas('allergens')->count(),
            'doses_by_status' => $this->doseAdministrationsForSchool($schoolId)
                ->selectRaw('status, COUNT(*) as total')
                ->groupBy('status')
                ->pluck('total', 'status')
                ->all(),
        ]);
    }

    /**
     * GET /api/analytics/clinic-readiness — readiness indicators.
     */
    public function clinicReadiness(Request $request): JsonResponse
    {
        $schoolId = $request->user()->school_id;

        $totalStudents = Student::where('school_id', $schoolId)->count();

        $studentsWithApprovedDoc = Document::where('status', 'approved')
            ->whereHas('student', fn ($q) => $q->where('school_id', $schoolId))
            ->distinct('student_id')
            ->count('student_id');

        $approvedPct = $totalStudents > 0
            ? round(($studentsWithApprovedDoc / $totalStudents) * 100, 1)
            : 0.0;

        return response()->json([
            'total_students' => $totalStudents,
            'students_with_approved_document' => $studentsWithApprovedDoc,
            'students_with_approved_document_pct' => $approvedPct,
            'medications_needing_physician_review' => $this->medicationsForSchool($schoolId)
                ->where('requires_physician', true)
                ->where('status', 'pending')
                ->count(),
            'low_supply_medications' => $this->lowSupplyQuery($schoolId)->count(),
            'expiring_documents' => $this->documentsForSchool($schoolId)
                ->whereNotNull('expiry_date')
                ->whereBetween('expiry_date', [now()->toDateString(), now()->addDays(30)->toDateString()])
                ->count(),
        ]);
    }

    /**
     * GET /api/analytics/annual-report — yearly rollups. Optional `year` query
     * param (defaults to the current calendar year).
     */
    public function annualReport(Request $request): JsonResponse
    {
        $schoolId = $request->user()->school_id;
        $year = (int) $request->query('year', now()->year);

        return response()->json([
            'year' => $year,
            'total_clinic_visits' => ClinicVisit::where('school_id', $schoolId)
                ->whereYear('visited_at', $year)->count(),
            'clinic_visits_by_severity' => ClinicVisit::where('school_id', $schoolId)
                ->whereYear('visited_at', $year)
                ->selectRaw('severity, COUNT(*) as total')
                ->groupBy('severity')
                ->pluck('total', 'severity')
                ->all(),
            'total_doses_administered' => $this->doseAdministrationsForSchool($schoolId)
                ->where('status', 'given')
                ->whereYear('administered_at', $year)
                ->count(),
            'doses_by_status' => $this->doseAdministrationsForSchool($schoolId)
                ->whereYear('scheduled_for', $year)
                ->selectRaw('status, COUNT(*) as total')
                ->groupBy('status')
                ->pluck('total', 'status')
                ->all(),
            'total_emergency_consents' => $this->emergencyConsentsForSchool($schoolId)
                ->whereYear('created_at', $year)->count(),
            'emergency_consents_by_status' => $this->emergencyConsentsForSchool($schoolId)
                ->whereYear('created_at', $year)
                ->selectRaw('status, COUNT(*) as total')
                ->groupBy('status')
                ->pluck('total', 'status')
                ->all(),
            'documents_processed' => $this->documentsForSchool($schoolId)
                ->whereYear('created_at', $year)
                ->selectRaw('status, COUNT(*) as total')
                ->groupBy('status')
                ->pluck('total', 'status')
                ->all(),
        ]);
    }

    /**
     * Medications belonging to students in the given school.
     */
    private function medicationsForSchool(int $schoolId)
    {
        return Medication::whereHas('student', fn ($q) => $q->where('school_id', $schoolId));
    }

    /**
     * Documents belonging to students in the given school.
     */
    private function documentsForSchool(int $schoolId)
    {
        return Document::whereHas('student', fn ($q) => $q->where('school_id', $schoolId));
    }

    /**
     * Emergency consents belonging to students in the given school.
     */
    private function emergencyConsentsForSchool(int $schoolId)
    {
        return EmergencyConsent::whereHas('student', fn ($q) => $q->where('school_id', $schoolId));
    }

    /**
     * Dose administrations belonging to students in the given school.
     */
    private function doseAdministrationsForSchool(int $schoolId)
    {
        return DoseAdministration::whereHas('student', fn ($q) => $q->where('school_id', $schoolId));
    }

    /**
     * Medications at or below their low-supply threshold for the given school.
     */
    private function lowSupplyQuery(int $schoolId)
    {
        return $this->medicationsForSchool($schoolId)
            ->whereNotNull('supply_count')
            ->whereNotNull('low_supply_threshold')
            ->whereColumn('supply_count', '<=', 'low_supply_threshold');
    }
}
