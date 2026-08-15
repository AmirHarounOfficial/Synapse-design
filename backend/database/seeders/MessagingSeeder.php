<?php

namespace Database\Seeders;

use App\Models\Message;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;

class MessagingSeeder extends Seeder
{
    /**
     * Seed ~8 realistic sample messages for the seeded school (school_id=1): a
     * mix of categories (attendance/health/general/urgent) and statuses, some
     * addressed to the secretary, some general/broadcast. Idempotent.
     */
    public function run(): void
    {
        $schoolId = 1;

        $secretary = User::where('email', 'secretary@schookeep.ae')->first();
        $parent = User::where('email', 'parent@schookeep.ae')->first();
        $nurse = User::where('email', 'nurse@schookeep.ae')->first();
        $principal = User::where('email', 'principal@schookeep.ae')->first();
        $teacher = User::where('email', 'teacher@schookeep.ae')->first();

        $now = Carbon::now();

        $samples = [
            [
                'sender_id' => $parent?->id,
                'sender_name' => 'Ahmed Al Mansoori',
                'recipient_id' => $secretary?->id,
                'category' => 'attendance',
                'subject' => 'Absence notice for Layla (Grade 4)',
                'body' => 'Good morning. Layla will be absent today due to a doctor\'s appointment and should return tomorrow. Please excuse her absence. Thank you.',
                'status' => 'unread',
                'read_at' => null,
                'created_at' => $now->copy()->subMinutes(35),
            ],
            [
                'sender_id' => $nurse?->id,
                'sender_name' => 'Sarah Johnson',
                'recipient_id' => $secretary?->id,
                'category' => 'health',
                'subject' => 'Clinic copy: Marcus Chen - minor injury',
                'body' => 'Marcus visited the clinic after a fall during PE. Minor scrape, cleaned and bandaged, no further action needed. Parents have been notified by phone.',
                'status' => 'read',
                'read_at' => $now->copy()->subHours(2),
                'created_at' => $now->copy()->subHours(3),
            ],
            [
                'sender_id' => $principal?->id,
                'sender_name' => 'Dr. Khalid Rahman',
                'recipient_id' => null,
                'category' => 'urgent',
                'subject' => 'Early dismissal Thursday - sandstorm warning',
                'body' => 'Due to the forecasted sandstorm, the school will dismiss at 12:30 PM on Thursday. Please coordinate updated pickup and bus schedules with all guardians today.',
                'status' => 'unread',
                'read_at' => null,
                'created_at' => $now->copy()->subHours(5),
            ],
            [
                'sender_id' => $parent?->id,
                'sender_name' => 'Fatima Al Zaabi',
                'recipient_id' => $secretary?->id,
                'category' => 'general',
                'subject' => 'Request for transcript copy',
                'body' => 'Assalamu alaikum. Could you please prepare an official transcript for my son Yousef for a university application? I can collect it from the front office this week.',
                'status' => 'unread',
                'read_at' => null,
                'created_at' => $now->copy()->subHours(8),
            ],
            [
                'sender_id' => $nurse?->id,
                'sender_name' => 'Sarah Johnson',
                'recipient_id' => null,
                'category' => 'health',
                'subject' => 'Reminder: medication consent forms due',
                'body' => 'Several students still have pending medication administration consent forms for the new term. Please follow up with the relevant guardians before Friday.',
                'status' => 'read',
                'read_at' => $now->copy()->subDay(),
                'created_at' => $now->copy()->subDays(1),
            ],
            [
                'sender_id' => $teacher?->id,
                'sender_name' => 'Fatima Hassan',
                'recipient_id' => $secretary?->id,
                'category' => 'attendance',
                'subject' => 'Late arrival log - Grade 6B',
                'body' => 'Three students in Grade 6B arrived after the second bell this morning. I have recorded them as late; please update the attendance register accordingly.',
                'status' => 'replied',
                'read_at' => $now->copy()->subHours(20),
                'created_at' => $now->copy()->subDays(1)->subHours(2),
            ],
            [
                'sender_id' => null,
                'sender_name' => 'ADEK Communications',
                'recipient_id' => $principal?->id,
                'category' => 'general',
                'subject' => 'Circular: updated first-aid training schedule',
                'body' => 'Please find the revised first-aid and CPR refresher training schedule for staff. Kindly nominate participants from your clinic and PE departments by the end of the month.',
                'status' => 'unread',
                'read_at' => null,
                'created_at' => $now->copy()->subDays(2),
            ],
            [
                'sender_id' => $parent?->id,
                'sender_name' => 'Omar Saeed',
                'recipient_id' => $secretary?->id,
                'category' => 'general',
                'subject' => 'Change of authorized pickup person',
                'body' => 'I would like to add my sister, Mariam Saeed, as an authorized person to pick up my daughter Noura. Please let me know what documents are required to update the records.',
                'status' => 'read',
                'read_at' => $now->copy()->subDays(2),
                'created_at' => $now->copy()->subDays(3),
            ],
        ];

        foreach ($samples as $sample) {
            Message::firstOrCreate(
                [
                    'school_id' => $schoolId,
                    'subject' => $sample['subject'],
                ],
                [
                    'sender_id' => $sample['sender_id'],
                    'sender_name' => $sample['sender_name'],
                    'recipient_id' => $sample['recipient_id'],
                    'category' => $sample['category'],
                    'body' => $sample['body'],
                    'status' => $sample['status'],
                    'read_at' => $sample['read_at'],
                    'created_at' => $sample['created_at'],
                    'updated_at' => $sample['created_at'],
                ],
            );
        }
    }
}
