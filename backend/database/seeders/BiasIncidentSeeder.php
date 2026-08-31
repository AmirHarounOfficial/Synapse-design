<?php

namespace Database\Seeders;

use App\Models\BiasIncident;
use App\Models\Student;
use Illuminate\Database\Seeder;

class BiasIncidentSeeder extends Seeder
{
    public function run(): void
    {
        $student = Student::first();
        $studentId = $student ? $student->id : 1;
        $studentName = $student ? $student->name : 'Sami Al-Mansoor';

        BiasIncident::create([
            'student_id' => $studentId,
            'student_name' => $studentName,
            'reporter_role' => 'teacher',
            'reporter_name' => 'Sarah Jenkins (Classroom Teacher)',
            'location' => 'hallway',
            'category' => 'verbal_slur',
            'severity' => 'medium',
            'status' => 'submitted',
            'description' => 'Overheard offensive racial slurs directed at a student during hallway passing period.',
            'immediate_action_taken' => 'Intervened immediately, separated both students, and reminded them of school zero-tolerance policy.',
            'witnesses' => 'Teacher Asst. David Miller',
            'counselor_notes' => null,
            'resolution_plan' => null,
        ]);

        BiasIncident::create([
            'student_id' => $studentId,
            'student_name' => $studentName,
            'reporter_role' => 'bus_driver',
            'reporter_name' => 'Robert Vance (Bus Driver)',
            'location' => 'bus',
            'bus_route_number' => 'Route #12 (North Campus)',
            'category' => 'exclusion',
            'severity' => 'high',
            'status' => 'under_review',
            'description' => 'Repeated exclusion and verbal intimidation regarding seating assignment on morning route.',
            'immediate_action_taken' => 'Moved student to front row seat near driver and issued verbal warning to involved parties.',
            'witnesses' => 'Bus Monitor A. Rodriguez',
            'counselor_notes' => 'Scheduled 1-on-1 restorative counseling session for Wednesday morning.',
            'resolution_plan' => 'Assign permanent seating plan for Route #12 and organize peer conflict resolution workshop.',
        ]);
    }
}
