class FormsController < ApplicationController
  before_action :require_church
  before_action :set_form, only: %i[ show edit update destroy ]

  def index
    @forms = current_church.forms.order(:title)
    @submission_counts = FormSubmission.where(form: @forms).group(:form_id).count
    @unread_counts = FormSubmission.unread.where(form: @forms).group(:form_id).count
  end

  def show
  end

  def new
    @form = current_church.forms.new
  end

  def create
    template = FormTemplate.find(params[:template]) if params[:template].present?
    @form = template ? template.build_for(current_church) : current_church.forms.new(form_params)

    if @form.save
      redirect_to form_path(@form), notice: "Formular angelegt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @form.update(form_params)
      redirect_to form_path(@form), notice: "Einstellungen gespeichert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @form.destroy
    redirect_to forms_path, notice: "Formular gelöscht.", status: :see_other
  end

  private
    def set_form
      @form = current_church.forms.find(params[:id])
    end

    def form_params
      params.expect(form: %i[ title intro thank_you_message submit_label notification_emails consent_text privacy_url retention_months ])
    end
end
