# Ready-made forms from config/form_templates.yml. Creating a form from a
# template copies it, so churches can change everything afterwards.
class FormTemplate
  attr_reader :key, :name, :icon, :description

  def self.all
    @all ||= YAML.load_file(Rails.root.join("config/form_templates.yml")).map { |key, attributes| new(key, attributes) }
  end

  def self.find(key)
    all.find { |template| template.key == key.to_s }
  end

  def initialize(key, attributes)
    @key = key
    @attributes = attributes
    @name, @icon, @description = @attributes.values_at("name", "icon", "description")
  end

  def questions
    @attributes["questions"]
  end

  def build_for(church)
    form = church.forms.new(@attributes.slice("title", "intro", "thank_you_message", "submit_label"))
    questions.each_with_index do |question, index|
      form.questions.build(question.slice("kind", "label", "help_text", "required", "choices").merge("position" => index))
    end
    form
  end
end
