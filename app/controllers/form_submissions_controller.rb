require "csv"

class FormSubmissionsController < ApplicationController
  before_action :require_church
  before_action :set_form
  before_action :set_submission, only: %i[ show destroy toggle_read ]

  def index
    @submissions = @form.submissions
    @submissions = @submissions.unread if params[:filter] == "unread"

    respond_to do |format|
      format.html
      format.csv do
        send_data submissions_csv, filename: "#{@form.title.parameterize.presence || "formular"}-#{Date.current.iso8601}.csv", type: "text/csv; charset=utf-8"
      end
    end
  end

  def show
    @submission.mark_read!
  end

  def toggle_read
    @submission.toggle_read!
    redirect_back_or_to form_submissions_path(@form), status: :see_other
  end

  def destroy
    @submission.destroy
    redirect_to form_submissions_path(@form), notice: "Einsendung gelöscht.", status: :see_other
  end

  def destroy_all
    @form.submissions.delete_all
    redirect_to form_submissions_path(@form), notice: "Alle Einsendungen gelöscht.", status: :see_other
  end

  private
    def set_form
      @form = current_church.forms.find(params[:form_id])
    end

    def set_submission
      @submission = @form.submissions.find(params[:id])
    end

    # One column per question. Answers to questions that were deleted in the
    # meantime keep their own column with the label they had back then.
    def submissions_csv
      submissions = @submissions.to_a
      columns = @form.questions.to_h { |question| [ question.id, question.label ] }
      submissions.each { |submission| submission.answers.each { |answer| columns[answer["question_id"]] ||= answer["label"] } }

      # Excel needs the BOM to read UTF-8 and prefers semicolons in German locales.
      "﻿" + CSV.generate(col_sep: ";") do |csv|
        csv << [ "Eingegangen am", "Gelesen", *columns.values ]
        submissions.each do |submission|
          answers = submission.answers.index_by { |answer| answer["question_id"] }
          csv << [
            submission.created_at.strftime("%d.%m.%Y %H:%M"),
            submission.read? ? "ja" : "nein",
            *columns.keys.map { |id| csv_safe(answers[id] && FormSubmission.format_value(answers[id])) }
          ]
        end
      end
    end

    # Keep spreadsheet apps from treating answers as formulas.
    def csv_safe(value)
      value.to_s.start_with?("=", "+", "-", "@", "\t", "\r") ? "'#{value}" : value
    end
end
