# Receives form submissions from the embedded launcher on church websites.
# Public and cross-origin like the embed script. The widget posts FormData
# (a "simple" CORS request, so no preflight) and never sends cookies, which
# is why there is no CSRF token.
class EmbedSubmissionsController < ActionController::Base
  # People need a few seconds for even the shortest form; bots don't.
  class_attribute :minimum_fill_time, default: 3.seconds

  skip_forgery_protection

  before_action :allow_cross_origin
  rate_limit to: 10, within: 10.minutes, only: :create,
    with: -> { render json: { error: "Zu viele Einsendungen. Bitte versuche es später noch einmal." }, status: :too_many_requests }

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Formular nicht gefunden." }, status: :not_found
  end

  def create
    form = find_form
    # Bots get a normal success response so they don't retry.
    return render(json: { ok: true }, status: :created) if spam?

    if form.consent_required? && params[:consent] != "1"
      return render json: { errors: { consent: "Bitte stimme der Datenverarbeitung zu." } }, status: :unprocessable_entity
    end

    submission = FormSubmission.build_from(form, raw_answers(form))

    if submission.save
      FormSubmissionMailer.received(submission).deliver_later if form.notification_email_list.any?
      render json: { ok: true }, status: :created
    else
      render json: { errors: submission.answer_errors }, status: :unprocessable_entity
    end
  end

  private
    def allow_cross_origin
      response.headers["Access-Control-Allow-Origin"] = "*"
    end

    # Only forms that the hub actually offers can receive submissions.
    def find_form
      hub = Hub.find_by!(public_token: params[:token], enabled: true)
      hub.links.kind_form.visible.where.not(form_id: nil).find_by!(form_id: params[:form_id]).form
    end

    def spam?
      params[:website].present? || params[:elapsed_ms].to_i < minimum_fill_time.in_milliseconds
    end

    def raw_answers(form)
      form.questions.to_h { |question| [ question.id.to_s, params.dig(:answers, question.id.to_s) ] }
    end
end
