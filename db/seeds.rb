# Demo data for local development: bin/rails db:seed
# Login: demo@example.com / passwort123

# db:prepare also seeds a fresh production database (first boot with Kamal or ONCE),
# where a demo account with a known password must never exist.
return if Rails.env.production?

user = User.find_or_create_by!(email_address: "demo@example.com") do |u|
  u.name = "Demo Nutzer"
  u.password = "passwort123"
end

church = Church.find_by(slug: "demo-gemeinde") || Church.create!(name: "Demo Gemeinde", slug: "demo-gemeinde")
church.memberships.find_or_create_by!(user: user) { |membership| membership.role = :owner }
church.update!(consent_text: "Ich bin einverstanden, dass meine Angaben zur Bearbeitung meines Anliegens gespeichert werden.") if church.consent_text.blank?

prayer = church.forms.find_by(title: "Gebetsanliegen") || FormTemplate.find("prayer").build_for(church).tap do |form|
  form.notification_emails = user.email_address
  form.save!
end

hub = church.hub
if hub.links.none?
  [
    { title: "Gottesdienst live", url: "https://example.com/live" },
    { title: "Termine", url: "https://example.com/termine" },
    { title: "Kleingruppen", url: "https://example.com/gruppen" },
    { title: "Gebetsanliegen", kind: "form", form: prayer },
    { title: "Spenden", url: "https://example.com/spenden" }
  ].each { |attributes| hub.links.create!(attributes) }
end

puts "Demo-Hub: /embed/#{hub.public_token}.js"
