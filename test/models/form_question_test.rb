require "test_helper"

class FormQuestionTest < ActiveSupport::TestCase
  def question(kind, **attributes)
    FormQuestion.new(form: forms(:prayer), kind: kind, label: "Frage", **attributes)
  end

  test "requires an answer only for required questions" do
    assert_equal [ nil, "Bitte beantworte diese Frage." ], question("short_text", required: true).parse_answer("  ")
    assert_equal [ nil, nil ], question("short_text").parse_answer("")
  end

  test "strips text answers and limits their length" do
    assert_equal [ "Hallo", nil ], question("short_text").parse_answer(" Hallo ")
    assert_match "200 Zeichen", question("short_text").parse_answer("a" * 201).last
  end

  test "checks formats" do
    assert_nil question("email").parse_answer("anna@example.com").last
    assert question("email").parse_answer("keine-adresse").last
    assert_nil question("phone").parse_answer("+49 (0)30 123-456").last
    assert question("phone").parse_answer("ruf mich an").last
    assert_nil question("number").parse_answer("3,5").last
    assert question("number").parse_answer("drei").last
    assert_nil question("date").parse_answer("2026-12-24").last
    assert question("date").parse_answer("2026-02-30").last
    assert_nil question("yes_no").parse_answer("Ja").last
    assert question("yes_no").parse_answer("Vielleicht").last
  end

  test "only accepts configured choices" do
    single = question("single_choice", choices: %w[ A B ])
    multiple = question("multiple_choice", choices: %w[ A B ])

    assert_equal [ "A", nil ], single.parse_answer("A")
    assert single.parse_answer("C").last
    assert_equal [ %w[ A B ], nil ], multiple.parse_answer([ "A", "B", "" ])
    assert multiple.parse_answer([ "A", "C" ]).last
  end

  test "choice questions need choices, others drop them" do
    assert_not question("single_choice").valid?

    text = question("short_text", choices_text: "A\nB")
    text.save!
    assert_equal [], text.choices
  end

  test "choices are entered one per line" do
    q = question("multiple_choice", choices_text: " Kinder \n\nJugend\nKinder\n")
    assert_equal %w[ Kinder Jugend ], q.choices
  end

  test "rejects unknown kinds" do
    assert_not question("html").valid?
  end

  test "new questions go to the end and can be reordered" do
    added = forms(:prayer).questions.create!(kind: "short_text", label: "Neu")
    assert_equal 4, added.position

    added.move_to(0)
    assert_equal [ "Neu", "Wofür dürfen wir beten?" ], forms(:prayer).questions.reload.first(2).map(&:label)
  end
end
