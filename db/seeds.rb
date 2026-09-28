# Demo data for local development: bin/rails db:seed
# Login: demo@example.com / passwort123

user = User.find_or_create_by!(email_address: "demo@example.com") do |u|
  u.name = "Demo Nutzer"
  u.password = "passwort123"
end

church = Church.find_by(slug: "demo-gemeinde") || Church.create!(name: "Demo Gemeinde", slug: "demo-gemeinde")
church.memberships.find_or_create_by!(user: user) { |membership| membership.role = :owner }

prayer = church.forms.find_by(title: "Gebetsanliegen") || FormTemplate.find("prayer").build_for(church).tap do |form|
  form.consent_text = "Ich bin einverstanden, dass meine Angaben zur Bearbeitung meines Anliegens gespeichert werden."
  form.notification_emails = user.email_address
  form.save!
end

hub = church.hub
if hub.links.none?
  [
    { title: "Gottesdienst live", url: "https://example.com/live", description: "Sonntags um 10 Uhr", icon: "📺" },
    { title: "Termine", url: "https://example.com/termine", description: "Alle Veranstaltungen im Überblick", icon: "📅" },
    { title: "Kleingruppen", url: "https://example.com/gruppen", icon: "🤝" },
    { title: "Gebetsanliegen", kind: "form", form: prayer, description: "Wir beten für dich", icon: "🙏" },
    { title: "Spenden", url: "https://example.com/spenden", description: "Danke für deine Unterstützung", icon: "❤️" }
  ].each { |attributes| hub.links.create!(attributes) }
end

puts "Demo-Hub: /embed/#{hub.public_token}.js"
