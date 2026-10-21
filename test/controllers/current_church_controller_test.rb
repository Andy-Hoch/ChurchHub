require "test_helper"

class CurrentChurchControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "owner updates the church" do
    patch church_path, params: { church: { name: "Neuer Name" } }

    assert_redirected_to edit_church_path
    assert_equal "Neuer Name", churches(:one).reload.name
  end

  test "owner sets and removes the church website" do
    patch church_path, params: { church: { website_url: "https://neu.example" } }
    assert_equal "https://neu.example", churches(:one).reload.website_url

    patch church_path, params: { church: { website_url: "" } }
    assert_nil churches(:one).reload.website_url
  end

  test "owner sets the privacy settings for all forms" do
    patch church_path, params: { church: { consent_text: "Ich stimme zu.", privacy_url: " https://example.com/datenschutz " } }

    assert_redirected_to edit_church_path
    church = churches(:one).reload
    assert_equal "Ich stimme zu.", church.consent_text
    assert_equal "https://example.com/datenschutz", church.privacy_url

    get edit_church_path
    assert_select "textarea[name='church[consent_text]']", text: "Ich stimme zu."
  end

  test "rejects an invalid church website" do
    patch church_path, params: { church: { website_url: "keine adresse" } }

    assert_response :unprocessable_entity
    assert_equal "https://gemeinde-eins.example", churches(:one).reload.website_url
  end

  test "admins cannot update the church" do
    memberships(:one).update_column(:role, "admin")
    patch church_path, params: { church: { name: "Neuer Name" } }

    assert_equal "Gemeinde Eins", churches(:one).reload.name
  end

  test "owner adds and removes a member" do
    assert_difference -> { churches(:one).memberships.count } do
      post church_memberships_path, params: { email_address: "two@example.com" }
    end

    membership = churches(:one).memberships.find_by!(user: users(:two))
    assert membership.admin?

    assert_difference -> { churches(:one).memberships.count }, -1 do
      delete church_membership_path(membership)
    end
  end

  test "owner with several churches deletes the current church" do
    church = churches(:one)
    add_second_church_and_switch_to(church)

    assert_difference [ "Church.count", "Hub.count" ], -1 do
      assert_difference "Link.count", -3 do
        delete church_path, params: { confirmation: "Gemeinde Eins" }
      end
    end

    assert_redirected_to hub_path
    assert_not Church.exists?(church.id)

    follow_redirect!
    assert_match "Andere Kirche", response.body
  end

  test "does not delete the church when the name does not match" do
    add_second_church_and_switch_to(churches(:one))

    assert_no_difference "Church.count" do
      delete church_path, params: { confirmation: "Gemeinde" }
    end

    assert_redirected_to edit_church_path
  end

  test "does not delete the only church" do
    assert_no_difference "Church.count" do
      delete church_path, params: { confirmation: "Gemeinde Eins" }
    end

    assert_redirected_to edit_church_path
    assert_match "Konto", flash[:alert]
  end

  test "admins cannot delete the church" do
    memberships(:one).update_column(:role, "admin")
    add_second_church_and_switch_to(churches(:one))

    assert_no_difference "Church.count" do
      delete church_path, params: { confirmation: "Gemeinde Eins" }
    end
  end

  test "switches between churches" do
    churches(:two).memberships.create!(user: users(:one))

    patch church_switch_path, params: { church_id: churches(:two).id }
    get hub_path

    assert_match "Andere Kirche", response.body
  end

  private
    def add_second_church_and_switch_to(church)
      churches(:two).memberships.create!(user: users(:one))
      patch church_switch_path, params: { church_id: church.id }
    end
end
