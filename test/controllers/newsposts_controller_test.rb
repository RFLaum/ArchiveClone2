require 'test_helper'

class NewspostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @newspost = newsposts(:one)
  end

  test "should get index" do
    get newsposts_url
    assert_response :success
  end

  test "should get new" do
    get new_newspost_url
    assert_response :success
  end

  test "should create newspost" do
    assert_difference('Newspost.count') do
      post newsposts_url, params: { newspost: { admin_name: @newspost.admin_name, content: @newspost.content, title: @newspost.title } }
    end

    assert_redirected_to newspost_url(Newspost.last)
  end

  test "should show newspost" do
    get newspost_url(@newspost)
    assert_response :success
  end

  test "should get edit" do
    get edit_newspost_url(@newspost)
    assert_response :success
  end

  test "should update newspost" do
    patch newspost_url(@newspost), params: { newspost: { admin_name: @newspost.admin_name, content: @newspost.content, title: @newspost.title } }
    assert_redirected_to newspost_url(@newspost)
  end

  test "should destroy newspost" do
    assert_difference('Newspost.count', -1) do
      delete newspost_url(@newspost)
    end

    assert_redirected_to newsposts_url
  end
end
