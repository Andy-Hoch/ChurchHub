require "test_helper"

class EmbedSubmissionsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    @link = hubs(:one).links.create!(title: "Gebet", kind: "form", form: forms(:prayer))
  end

  def submit(form: forms(:prayer), token: hubs(:one).public_token, answers: valid_answers, **params)
    post embed_form_submissions_path(token, form),
      params: { answers: answers, consent: "1", website: "", elapsed_ms: "8000" }.merge(params),
      headers: { "Origin" => "https://www.gemeinde-eins.example" }
  end

  def valid_answers
    { form_questions(:request).id => "Für meine Familie", form_questions(:visibility).id => "Nur das Gebetsteam" }
  end

  test "stores a submission and notifies admins" do
    assert_difference -> { forms(:prayer).submissions.count } do
      assert_enqueued_emails 1 do
        submit
      end
    end

    assert_response :created
    assert_equal "*", response.headers["Access-Control-Allow-Origin"]
    assert_not forms(:prayer).submissions.first.read?
  end

  test "accepts multiple choice answers" do
    question = forms(:prayer).questions.create!(kind: "multiple_choice", label: "Was?", choices: %w[ A B C ])
    submit answers: valid_answers.merge(question.id => %w[ A C ])

    assert_response :created
    assert_equal %w[ A C ], forms(:prayer).submissions.first.answers.last["value"]
  end

  test "returns errors per question" do
    assert_no_difference "FormSubmission.count" do
      submit answers: { form_questions(:email).id => "kaputt" }
    end

    assert_response :unprocessable_entity
    errors = response.parsed_body["errors"]
    assert_equal [ form_questions(:request), form_questions(:visibility), form_questions(:email) ].map { |q| q.id.to_s }.sort, errors.keys.sort
  end

  test "requires consent when the form asks for it" do
    assert_no_difference "FormSubmission.count" do
      submit consent: "0"
    end

    assert_response :unprocessable_entity
    assert response.parsed_body.dig("errors", "consent")
  end

  test "silently drops spam" do
    assert_no_difference "FormSubmission.count" do
      submit website: "https://spam.example"
      assert_response :created

      submit elapsed_ms: "500"
      assert_response :created
    end
  end

  test "only accepts forms offered by an enabled hub" do
    submit form: forms(:other)
    assert_response :not_found

    @link.update!(visible: false)
    submit
    assert_response :not_found

    @link.update!(visible: true)
    hubs(:one).update!(enabled: false)
    submit
    assert_response :not_found

    submit token: "unbekannt"
    assert_response :not_found
  end

  test "checks the origin when the church restricts the launcher to its website" do
    assert churches(:one).embed_restricted?

    assert_difference -> { forms(:prayer).submissions.count } do
      submit
    end
    assert_response :created

    assert_no_difference "FormSubmission.count" do
      post embed_form_submissions_path(hubs(:one).public_token, forms(:prayer)),
        params: { answers: valid_answers, consent: "1", elapsed_ms: "8000" },
        headers: { "Origin" => "https://fremd.example" }
    end
    assert_response :forbidden
  end

  test "accepts any origin without a website restriction" do
    churches(:one).update!(website_url: nil)

    post embed_form_submissions_path(hubs(:one).public_token, forms(:prayer)),
      params: { answers: valid_answers, consent: "1", elapsed_ms: "8000" },
      headers: { "Origin" => "https://fremd.example" }

    assert_response :created
  end

  test "the launcher script contains the form" do
    get embed_path(hubs(:one).public_token, format: :js)

    assert_match "Wofür dürfen wir beten?", response.body
    assert_match "Nur das Gebetsteam", response.body
  end

  test "form buttons are not shown on the public hub page" do
    get public_hub_path(churches(:one).slug)

    assert_response :success
    assert_select ".link-title", text: "Gebet", count: 0
    assert_match "Gottesdienst live", response.body
  end
end
