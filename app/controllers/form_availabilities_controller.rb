class FormAvailabilitiesController < ApplicationController
  before_action :require_church
  before_action :set_form

  def edit
  end

  def update
    if @form.update(availability_params)
      redirect_to edit_form_availability_path(@form), notice: t(".notice")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_form
      @form = current_church.forms.find(params[:form_id])
    end

    def availability_params
      params.expect(form: %i[ opens_at closes_at submission_limit when_full full_message ])
    end
end
