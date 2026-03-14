require "test_helper"

class RecurringActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    sign_in @user
    @activity = recurring_activities(:one)
  end

  test "should get index" do
    get recurring_activities_url
    assert_response :success
  end

  test "should get new" do
    get new_recurring_activity_url
    assert_response :success
  end

  test "should get edit" do
    get edit_recurring_activity_url(@activity)
    assert_response :success
  end

  # ---- POST create ----

  test "POST create con dati validi crea attività e redirect" do
    assert_difference "RecurringActivity.count", 1 do
      post recurring_activities_url, params: {
        recurring_activity: {
          topic: "study",
          weekday: "monday",
          periodicity: "weekly",
          starts_at: Time.current.change(hour: 9, min: 0),
          ends_at: Time.current.change(hour: 10, min: 0),
          active: false
        }
      }
    end
    assert_redirected_to recurring_activities_path
  end

  test "POST create con dati invalidi re-render new" do
    assert_no_difference "RecurringActivity.count" do
      post recurring_activities_url, params: {
        recurring_activity: {
          topic: nil,
          weekday: nil,
          periodicity: nil,
          starts_at: nil,
          ends_at: nil
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # ---- PATCH update ----

  test "PATCH update modifica attività esistente" do
    patch recurring_activity_url(@activity), params: {
      recurring_activity: {
        topic: @activity.topic,
        weekday: @activity.weekday,
        periodicity: @activity.periodicity,
        starts_at: Time.current.change(hour: 9, min: 0),
        ends_at: Time.current.change(hour: 10, min: 0),
        notes: "Note aggiornate",
        active: false
      }
    }
    assert_redirected_to recurring_activities_path
    assert_equal "Note aggiornate", @activity.reload.notes
  end

  # ---- DELETE destroy ----

  test "DELETE destroy elimina attività" do
    assert_difference "RecurringActivity.count", -1 do
      delete recurring_activity_url(@activity)
    end
    assert_redirected_to recurring_activities_path
  end

  # ---- Ownership ----

  test "edit di attività di altro utente restituisce 404" do
    other_activity = recurring_activities(:two)
    get edit_recurring_activity_url(other_activity)
    assert_response :not_found
  end

  test "destroy di attività di altro utente restituisce 404" do
    other_activity = recurring_activities(:two)
    delete recurring_activity_url(other_activity)
    assert_response :not_found
  end
end
