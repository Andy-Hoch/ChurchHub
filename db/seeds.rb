# Demo data for local development: bin/rails db:seed
# Login: demo@example.com / passwort123

user = User.find_or_create_by!(email_address: "demo@example.com") do |u|
  u.name = "Demo Nutzer"
  u.password = "passwort123"
end

church = Church.find_by(slug: "demo-gemeinde") || Church.create!(name: "Demo Gemeinde", slug: "demo-gemeinde")
church.memberships.find_or_create_by!(user: user) { |membership| membership.role = :owner }

hub = church.hub
if hub.links.none?
  [
    { title: "Gottesdienst live", url: "https://example.com/live", description: "Sonntags um 10 Uhr", icon: "📺" },
    { title: "Termine", url: "https://example.com/termine", description: "Alle Veranstaltungen im Überblick", icon: "📅" },
    { title: "Kleingruppen", url: "https://example.com/gruppen", icon: "🤝" },
    { title: "Gebetsanliegen", url: "https://example.com/gebet", icon: "🙏" },
    { title: "Spenden", url: "https://example.com/spenden", description: "Danke für deine Unterstützung", icon: "❤️" }
  ].each { |attributes| hub.links.create!(attributes) }
end

puts "Demo-Hub: /embed/#{hub.public_token}.js"
