require "test_helper"

class FormSubmissionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "lists submissions and filters unread ones" do
    get form_submissions_path(forms(:prayer))
    assert_response :success
    assert_match "Für meine Familie", response.body
    assert_match "=SUMME(A1)", response.body

    get form_submissions_path(forms(:prayer), filter: "unread")
    assert_match "Für meine Familie", response.body
    assert_no_match "=SUMME(A1)", response.body
  end

  test "shows the unread count in the navigation" do
    get forms_path
    assert_select ".sidebar-menu__button .badge", text: "1"
  end

  test "opening a submission marks it as read" do
    get form_submission_path(forms(:prayer), form_submissions(:unread))

    assert_response :success
    assert form_submissions(:unread).reload.read?
  end

  test "toggles the read state" do
    patch toggle_read_form_submission_path(forms(:prayer), form_submissions(:read))

    assert_not form_submissions(:read).reload.read?
  end

  test "exports csv without formulas" do
    get form_submissions_path(forms(:prayer), format: :csv)

    assert_response :success
    assert_equal "text/csv", response.media_type
    rows = CSV.parse(response.body.delete_prefix("﻿"), col_sep: ";")
    assert_equal [ "Eingegangen am", "Gelesen", "Wofür dürfen wir beten?", "Wie heißt du?", "Wer darf davon erfahren?", "Deine E-Mail-Adresse" ], rows.first
    assert_includes rows.map { |row| row[2] }, "'=SUMME(A1)"
    assert_includes rows.map { |row| row[2] }, "Für meine Familie"
  end

  test "deletes one or all submissions" do
    assert_difference -> { forms(:prayer).submissions.count }, -1 do
      delete form_submission_path(forms(:prayer), form_submissions(:read))
    end

    delete destroy_all_form_submissions_path(forms(:prayer))
    assert_equal 0, forms(:prayer).submissions.count
    assert FormSubmission.exists?(form_submissions(:other).id)
  end

  test "cannot see submissions of another church" do
    get form_submissions_path(forms(:other))
    assert_response :not_found

    get form_submission_path(forms(:prayer), form_submissions(:other))
    assert_response :not_found
  end
end
