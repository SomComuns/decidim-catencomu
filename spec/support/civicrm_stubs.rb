# frozen_string_literal: true

module CivicrmStubs
  ## User
  def stub_user_valid_request
    stub_successful_request_for(user_request_url, file_fixture("user_valid_response.json"))
  end

  def stub_user_not_found_request
    stub_successful_request_for(user_request_url, file_fixture("empty_response.json"))
  end

  def stub_user_invalid_request
    stub_successful_request_for(user_request_url, file_fixture("error_response.json"))
  end

  ## Contact
  def stub_contact_valid_request
    stub_successful_request_for(contact_request_url, file_fixture("contact_valid_response.json"))
  end

  ## Groups
  def stub_groups_valid_request
    stub_successful_request_for(groups_request_url, file_fixture("groups_valid_response.json"))
  end

  ## Users in group
  def stub_users_in_group_valid_request
    stub_successful_request_for(users_in_group_request_url, file_fixture("users_in_group_valid_response.json"))
  end

  private

  def user_request_url
    "https://api.base/?action=Get&api_key=api-key&entity=User&id=42&json=%7B%22sequential%22:1%7D&key=secret"
  end

  def contact_request_url
    "https://api.base/?action=Get&api_key=api-key&contact_id=9999&entity=Contact&json=%7B%22sequential%22:1,%22return%22:%22roles,display_name%22,%22api.Address.get%22:%7B%22return%22:%22custom_23%22%7D%7D&key=secret"
  end

  def groups_request_url
    "https://api.base/?action=Get&api_key=api-key&entity=Group&json=%7B%22sequential%22:1,%22options%22:%7B%22limit%22:0%7D,%22return%22:%22id,%20name,%20title,%20description,%20group_type,%20visibility%22,%22is_active%22:true%7D&key=secret"
  end

  def users_in_group_request_url
    "https://api.base/?action=Get&api_key=api-key&entity=Contact&json=%7B%22sequential%22:1,%22options%22:%7B%22limit%22:0%7D,%22group%22:%22Administrators%22,%22return%22:%22id,display_name,group%22,%22api.User.get%22:%7B%22return%22:%22id%22%7D%7D&key=secret"
  end

  # This will change depending on your gems versions.
  def headers
    {
      "Accept" => "*/*",
      "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "User-Agent" => "Faraday v1.2.0"
    }
  end

  def stub_successful_request_for(url, body)
    stub_request(:get, url)
      .with(
        headers: headers
      ).to_return(
        status: 200,
        body: body,
        headers: {}
      )
  end
end
