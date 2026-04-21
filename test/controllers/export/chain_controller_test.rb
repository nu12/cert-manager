require "test_helper"

class Export::ChainControllerTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper
  test "should get show" do
    sign_in_as(users(:one))
    assert_raises(ArgumentError) do
      get export_chain_url(certificates(:root).serial)
    end

    get export_chain_url(certificates(:intermediate).serial)
    assert_response :success

    assert_raises(ArgumentError) do
      get export_chain_url(certificates(:server).serial)
    end
  end

  test "no authentication" do
    get export_chain_url(certificates(:root).serial)
    assert_redirected_to new_signin_url

    get export_chain_url(certificates(:intermediate).serial)
    assert_redirected_to new_signin_url

    get export_chain_url(certificates(:server).serial)
    assert_redirected_to new_signin_url
  end

  test "wrong user" do
    sign_in_as(users(:two))
    assert_raises(Pundit::NotAuthorizedError) do
      get export_chain_url(certificates(:root).serial)
    end

    assert_raises(Pundit::NotAuthorizedError) do
      get export_chain_url(certificates(:intermediate).serial)
    end

    assert_raises(Pundit::NotAuthorizedError) do
      get export_chain_url(certificates(:server).serial)
    end
  end
end
