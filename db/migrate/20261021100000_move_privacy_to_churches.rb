# Consent text and privacy link are the same for every form of a church, so
# they move from the forms to the church settings.
class MovePrivacyToChurches < ActiveRecord::Migration[8.1]
  def up
    add_column :churches, :consent_text, :text
    add_column :churches, :privacy_url, :string

    execute <<~SQL
      UPDATE churches SET
        consent_text = (SELECT consent_text FROM forms WHERE forms.church_id = churches.id AND consent_text <> '' ORDER BY forms.id LIMIT 1),
        privacy_url = (SELECT privacy_url FROM forms WHERE forms.church_id = churches.id AND privacy_url <> '' ORDER BY forms.id LIMIT 1)
    SQL

    remove_column :forms, :consent_text
    remove_column :forms, :privacy_url
  end

  def down
    add_column :forms, :consent_text, :text
    add_column :forms, :privacy_url, :string

    execute <<~SQL
      UPDATE forms SET
        consent_text = (SELECT consent_text FROM churches WHERE churches.id = forms.church_id),
        privacy_url = (SELECT privacy_url FROM churches WHERE churches.id = forms.church_id)
    SQL

    remove_column :churches, :consent_text
    remove_column :churches, :privacy_url
  end
end
