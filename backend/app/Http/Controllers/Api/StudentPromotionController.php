<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Student;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * Year-end batch promotion. Advances each student's `grade` by one numeric
 * level, scoped to the caller's school. Grades are stored as strings; only
 * purely-numeric grades are incremented ("5" -> "6"). Non-numeric grades
 * (e.g. "KG", "Reception") are left untouched and reported as skipped.
 */
class StudentPromotionController extends Controller
{
    /**
     * POST /api/students/promote — batch-advance students within the school.
     *
     * Body: { "from_grade"?: string } — when present, only that grade is
     * promoted; otherwise every student in the school is considered.
     */
    public function promote(Request $request): JsonResponse
    {
        $data = $request->validate([
            'from_grade' => ['nullable', 'string'],
        ]);

        $schoolId = $request->user()->school_id;

        $query = Student::where('school_id', $schoolId);
        if (array_key_exists('from_grade', $data) && $data['from_grade'] !== null && $data['from_grade'] !== '') {
            $query->where('grade', $data['from_grade']);
        }

        $promoted = [];
        $skipped = [];

        DB::transaction(function () use ($query, &$promoted, &$skipped) {
            // Order high-to-low so re-reads within the txn never collide; and
            // lock the rows we intend to update.
            $students = $query->orderBy('id')->lockForUpdate()->get();

            foreach ($students as $student) {
                $current = $student->grade;

                // Only advance purely-numeric grades. ctype_digit guards against
                // null, empty, and alphanumeric values in one check.
                if ($current !== null && ctype_digit((string) $current)) {
                    $next = (string) ((int) $current + 1);
                    $student->grade = $next;
                    $student->save();

                    $promoted[] = [
                        'id' => $student->id,
                        'name' => $student->name,
                        'from_grade' => (string) $current,
                        'to_grade' => $next,
                    ];
                } else {
                    $skipped[] = [
                        'id' => $student->id,
                        'name' => $student->name,
                        'grade' => $current,
                        'reason' => 'non_numeric_grade',
                    ];
                }
            }
        });

        return response()->json([
            'promoted_count' => count($promoted),
            'skipped_count' => count($skipped),
            'details' => [
                'promoted' => $promoted,
                'skipped' => $skipped,
            ],
        ]);
    }
}
