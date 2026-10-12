require "test_helper"

class MembershipsRolesTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
    @other = churches(:one).memberships.create!(user: users(:two))
  end

  test "owners make admins owner" do
    patch church_membership_path(@other), params: { role: "owner" }

    assert_redirected_to edit_church_path
    assert @other.reload.owner?
    assert_equal "Ben Beispiel ist jetzt Besitzer.", flash[:notice]
  end

  test "owners hand the church over by making themselves admin afterwards" do
    @other.owner!

    patch church_membership_path(memberships(:one)), params: { role: "admin" }

    assert memberships(:one).reload.admin?
    assert_equal "Anna Beispiel ist jetzt Admin.", flash[:notice]

    patch church_membership_path(@other), params: { role: "admin" }
    assert @other.reload.owner?, "former owners are admins now and may not change roles"
  end

  test "the last owner cannot become admin" do
    patch church_membership_path(memberships(:one)), params: { role: "admin" }

    assert memberships(:one).reload.owner?
    assert_match "keinen Besitzer mehr", flash[:alert]
  end

  test "rejects unknown roles" do
    patch church_membership_path(@other), params: { role: "boss" }

    assert @other.reload.admin?
    assert flash[:alert].present?
  end

  test "admins cannot change roles" do
    @other.owner!
    memberships(:one).admin!

    patch church_membership_path(memberships(:one)), params: { role: "owner" }
    assert memberships(:one).reload.admin?
  end

  test "cannot change roles in another church" do
    patch church_membership_path(memberships(:two)), params: { role: "admin" }

    assert_response :not_found
    assert memberships(:two).reload.owner?
  end

  test "the settings page offers the matching buttons" do
    get edit_church_path

    assert_select "form[action=?] input[name=role][value=owner]", church_membership_path(@other)
    assert_select "form[action=?] input[name=role]", church_membership_path(memberships(:one)), count: 0, message: "the only owner can't step down"

    @other.owner!
    get edit_church_path
    assert_select "form[action=?] input[name=role][value=admin]", church_membership_path(memberships(:one))
  end
end
