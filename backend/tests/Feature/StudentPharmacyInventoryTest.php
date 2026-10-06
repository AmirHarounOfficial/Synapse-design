<?php

namespace Tests\Feature;

use App\Enums\Role;
use App\Models\PharmacyInventoryItem;
use App\Models\School;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class StudentPharmacyInventoryTest extends TestCase
{
    use RefreshDatabase;

    private Student $student;

    protected function setUp(): void
    {
        parent::setUp();
        $school = School::create(['name' => 'School A', 'code' => 'A', 'emirate' => 'Dubai']);
        $this->student = Student::create(['school_id' => $school->id, 'name' => 'Student A']);
        Sanctum::actingAs(User::factory()->create(['school_id' => $school->id, 'role' => Role::Nurse]));
    }

    private function payload(?int $studentId = null): array
    {
        return ['student_id' => $studentId, 'name' => 'Student medicine', 'category' => 'Maintenance', 'stock_quantity' => 10, 'min_threshold' => 3, 'unit' => 'tablets'];
    }

    public function test_school_and_each_student_have_separate_stock_and_history(): void
    {
        $other = Student::create(['school_id' => $this->student->school_id, 'name' => 'Student B']);
        $this->postJson('/api/pharmacy-inventory', $this->payload())->assertSuccessful();
        $own = $this->postJson('/api/pharmacy-inventory', $this->payload($this->student->id))->assertSuccessful()->json('data.id');
        $this->postJson('/api/pharmacy-inventory', $this->payload($other->id))->assertSuccessful();
        $this->getJson('/api/pharmacy-inventory')->assertJsonCount(1, 'data')->assertJsonPath('data.0.student_id', null);
        $this->getJson('/api/pharmacy-inventory?student_id='.$this->student->id)->assertJsonCount(1, 'data')->assertJsonPath('data.0.id', $own);
        $this->getJson('/api/pharmacy-inventory/logs?student_id='.$this->student->id)->assertJsonCount(1, 'data');
        $this->getJson('/api/pharmacy-inventory/logs')->assertJsonCount(1, 'data');
    }

    public function test_stock_changes_are_logged_and_over_dispensing_is_rejected(): void
    {
        $id = $this->postJson('/api/pharmacy-inventory', $this->payload($this->student->id))->json('data.id');
        $this->postJson("/api/pharmacy-inventory/$id/adjust-stock", ['adjustment' => -8, 'reason' => 'Dispensed'])
            ->assertSuccessful()->assertJsonPath('data.stock_quantity', 2)->assertJsonPath('data.status', 'low_stock');
        $this->postJson("/api/pharmacy-inventory/$id/adjust-stock", ['adjustment' => -3, 'reason' => 'Dispensed'])->assertUnprocessable();
        $this->assertDatabaseHas('pharmacy_inventory_items', ['id' => $id, 'stock_quantity' => 2]);
        $this->getJson('/api/pharmacy-inventory/logs?student_id='.$this->student->id)->assertJsonCount(2, 'data')->assertJsonPath('data.0.quantity_change', -8);
    }

    public function test_student_ownership_cannot_be_transferred_and_deleted_history_remains(): void
    {
        $id = $this->postJson('/api/pharmacy-inventory', $this->payload($this->student->id))->json('data.id');
        $this->patchJson("/api/pharmacy-inventory/$id", ['student_id' => null])->assertUnprocessable();
        $this->deleteJson("/api/pharmacy-inventory/$id")->assertSuccessful();
        $this->getJson('/api/pharmacy-inventory/logs?student_id='.$this->student->id)->assertJsonCount(2, 'data');
        $this->getJson('/api/pharmacy-inventory/logs')->assertJsonCount(0, 'data');
    }

    public function test_other_schools_student_inventory_cannot_be_read_or_changed(): void
    {
        $school = School::create(['name' => 'School B', 'code' => 'B', 'emirate' => 'Dubai']);
        $student = Student::create(['school_id' => $school->id, 'name' => 'Other student']);
        $item = PharmacyInventoryItem::create($this->payload($student->id));
        $this->getJson('/api/pharmacy-inventory?student_id='.$student->id)->assertForbidden();
        $this->getJson('/api/pharmacy-inventory/logs?student_id='.$student->id)->assertForbidden();
        $this->getJson('/api/pharmacy-inventory/'.$item->id)->assertForbidden();
        $this->patchJson('/api/pharmacy-inventory/'.$item->id, ['stock_quantity' => 0])->assertForbidden();
        $this->deleteJson('/api/pharmacy-inventory/'.$item->id)->assertForbidden();
        $this->postJson('/api/pharmacy-inventory', $this->payload($student->id))->assertForbidden();
        $this->getJson('/api/students?for_inventory=1')->assertJsonCount(1, 'data');
    }

    public function test_invalid_student_and_non_nurse_access_are_rejected(): void
    {
        $this->postJson('/api/pharmacy-inventory', $this->payload(999))->assertUnprocessable();
        Sanctum::actingAs(User::factory()->create(['role' => Role::Teacher]));
        $this->getJson('/api/pharmacy-inventory?student_id='.$this->student->id)->assertForbidden();
    }
}
