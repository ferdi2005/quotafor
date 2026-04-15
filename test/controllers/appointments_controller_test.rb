require "test_helper"

class AppointmentsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user = users(:one)
    @other_user = users(:two)
    @customer = customers(:one)
    @other_customer = customers(:two)
    @appointment = appointments(:one)
    sign_in @user
  end

  # ---- GET new ----

  test "GET new returns form" do
    get new_customer_appointment_url(@customer)
    assert_response :success
  end

  # ---- POST create con dati validi ----

  test "POST create crea appuntamento e CalendarEvent" do
    assert_difference [ "Appointment.count", "CalendarEvent.count" ], 1 do
      post customer_appointments_url(@customer), params: {
        appointment: {
          starts_at: 2.days.from_now,
          ends_at: 2.days.from_now + 1.hour,
          appointment_type: "first_meeting",
          status: "scheduled"
        }
      }
    end
    assert_redirected_to customer_path(@customer)
  end

  test "POST create crea più referral collegati al cliente" do
    assert_difference "Appointment.count", 1 do
      assert_difference "Customer.count", 2 do
        post customer_appointments_url(@customer), params: {
          appointment: {
            starts_at: 2.days.from_now,
            ends_at: 2.days.from_now + 1.hour,
            appointment_type: "first_meeting",
            status: "scheduled",
            referral_customers: {
              "0" => {
                first_name: "Nuovo",
                last_name: "Prospect",
                profession: "Imprenditore",
                phone: "3331112222",
                email: "nuovo@example.com"
              },
              "1" => {
                first_name: "Altro",
                last_name: "Referral",
                profession: "Consulente",
                phone: "3334445555",
                email: "altro@example.com"
              }
            }
          }
        }
      end
    end

    referred_customers = Customer.where(referred_by_customer: @customer).order(:created_at)
    assert_equal [ "Nuovo", "Altro" ], referred_customers.pluck(:first_name)
    assert_equal [ @user.id, @user.id ], referred_customers.pluck(:user_id)
    assert_equal [ "3331112222", "3334445555" ], referred_customers.pluck(:phone)
    assert_equal [ "nuovo@example.com", "altro@example.com" ], referred_customers.pluck(:email)
  end

  # ---- POST create con dati invalidi ----

  test "POST create con dati invalidi re-render form" do
    assert_no_difference "Appointment.count" do
      post customer_appointments_url(@customer), params: {
        appointment: {
          starts_at: nil,
          ends_at: nil,
          appointment_type: "first_meeting",
          status: "scheduled"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # ---- PATCH update ----

  test "PATCH update modifica appuntamento esistente" do
    patch customer_appointment_url(@customer, @appointment), params: {
      appointment: {
        starts_at: 2.days.from_now,
        ends_at: 2.days.from_now + 1.hour,
        appointment_type: "follow_up",
        status: "completed",
        outcome: "negative",
        negative_reason: "Non interessato"
      }
    }
    assert_redirected_to customer_path(@customer)
    assert_equal "negative", @appointment.reload.outcome
  end

  # ---- DELETE destroy ----

  test "DELETE destroy elimina appuntamento e CalendarEvent" do
    # Ensure there is a CalendarEvent linked to @appointment
    CalendarEvent.create!(
      user: @user, source: @appointment,
      title: "Test", description: "d",
      starts_at: 1.hour.from_now, ends_at: 2.hours.from_now,
      category: :customer_appointment, color: "#000"
    )
    assert_difference "Appointment.count", -1 do
      assert_difference "CalendarEvent.count", -1 do
        delete customer_appointment_url(@customer, @appointment)
      end
    end
    assert_redirected_to customer_path(@customer)
  end

  # ---- Ownership ----

  test "GET new per cliente di altro utente restituisce 404" do
    get new_customer_appointment_url(@other_customer)
    assert_response :not_found
  end

  test "PATCH update appuntamento di altro utente restituisce 404" do
    other_appointment = appointments(:two)
    patch customer_appointment_url(@other_customer, other_appointment), params: {
      appointment: { status: "completed" }
    }
    assert_response :not_found
  end

  test "DELETE destroy appuntamento di altro utente restituisce 404" do
    other_appointment = appointments(:two)
    delete customer_appointment_url(@other_customer, other_appointment)
    assert_response :not_found
  end
end
