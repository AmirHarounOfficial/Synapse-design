<?php

namespace Database\Seeders;

use App\Models\ChatbotConversation;
use App\Models\User;
use Illuminate\Database\Seeder;

class ChatbotSeeder extends Seeder
{
    /**
     * Seed ~5 chatbot escalations for the seeded school (school_id=1), each with
     * a small realistic thread (bot greeting -> parent question -> optional staff
     * reply) and varied status/priority. Idempotent.
     */
    public function run(): void
    {
        $schoolId = 1;
        $parent = User::where('email', 'parent@schookeep.ae')->first();
        $secretary = User::where('email', 'secretary@schookeep.ae')->first();

        $greeting = 'Hello! I am the SchooKeep Assistant. How can I help you today?';

        $conversations = [
            [
                'parent_name' => 'James Thompson',
                'subject' => 'Updating emergency contact information',
                'status' => 'pending',
                'priority' => 'normal',
                'thread' => [
                    ['bot', $greeting],
                    ['parent', 'How do I update my emergency contact information?'],
                    ['bot', "I'm not able to update contact records directly. I've escalated your question to the front office so a staff member can assist you."],
                ],
            ],
            [
                'parent_name' => 'Sarah Williams',
                'subject' => 'Field trip accommodation request',
                'status' => 'pending',
                'priority' => 'high',
                'thread' => [
                    ['bot', $greeting],
                    ['parent', 'My child needs a specific accommodation for field trips. Who do I talk to?'],
                    ['bot', "This needs a human review. I've escalated your request to the school's front office."],
                ],
            ],
            [
                'parent_name' => 'Carlos Martinez',
                'subject' => 'Immunization records deadline',
                'status' => 'assigned',
                'priority' => 'normal',
                'thread' => [
                    ['bot', $greeting],
                    ['parent', 'When is the deadline for submitting immunization records?'],
                    ['bot', "I don't have that specific date. I've passed this to the school secretary."],
                    ['staff', 'Hi Carlos, immunization records are due by the end of this month. You can upload them in the Documents section of the app.'],
                ],
            ],
            [
                'parent_name' => 'Aisha Khan',
                'subject' => 'Clinic opening hours',
                'status' => 'resolved',
                'priority' => 'low',
                'thread' => [
                    ['bot', $greeting],
                    ['parent', 'What time does the school clinic open?'],
                    ['bot', 'The school clinic opens at 8:00 AM and closes at 3:30 PM on school days. Is there anything else you need?'],
                    ['parent', 'That is all, thank you!'],
                ],
            ],
            [
                'parent_name' => 'Michael Chen',
                'subject' => 'Medication drop-off procedure',
                'status' => 'assigned',
                'priority' => 'high',
                'thread' => [
                    ['bot', $greeting],
                    ['parent', 'How do I drop off my child\'s daily medication at the clinic?'],
                    ['bot', "This one needs staff assistance. I've escalated it to the front office."],
                    ['staff', 'Hello Michael, please bring the medication in its original packaging to the clinic and complete the medication authorization form. The nurse will store and administer it.'],
                ],
            ],
        ];

        foreach ($conversations as $data) {
            $conversation = ChatbotConversation::firstOrCreate(
                [
                    'school_id' => $schoolId,
                    'subject' => $data['subject'],
                ],
                [
                    'parent_id' => $parent?->id,
                    'parent_name' => $data['parent_name'],
                    'status' => $data['status'],
                    'priority' => $data['priority'],
                    'assigned_to' => $data['status'] === 'pending' ? null : $secretary?->id,
                ],
            );

            if ($conversation->messages()->exists()) {
                continue;
            }

            foreach ($data['thread'] as [$sender, $body]) {
                $conversation->messages()->create([
                    'sender' => $sender,
                    'body' => $body,
                ]);
            }
        }
    }
}
