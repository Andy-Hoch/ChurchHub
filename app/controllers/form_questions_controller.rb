class FormQuestionsController < ApplicationController
  before_action :require_church
  before_action :set_form
  before_action :set_question, only: %i[ edit update destroy position ]

  def new
    @question = @form.questions.new
  end

  def create
    @question = @form.questions.new(question_params)

    if @question.save
      redirect_to form_path(@form), notice: "Frage hinzugefügt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @question.update(question_params)
      redirect_to form_path(@form), notice: "Frage gespeichert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @question.destroy
    redirect_to form_path(@form), notice: "Frage gelöscht.", status: :see_other
  end

  def position
    @question.move_to(params[:position])
    head :no_content
  end

  private
    def set_form
      @form = current_church.forms.find(params[:form_id])
    end

    def set_question
      @question = @form.questions.find(params[:id])
    end

    def question_params
      params.expect(form_question: %i[ kind label help_text required choices_text ])
    end
end
