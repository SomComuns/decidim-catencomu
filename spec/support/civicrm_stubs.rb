# frozen_string_literal: true

module CivicrmStubs
  ## User
  def stub_user_valid_request
    stub_request(:get, user_request_url)
      .with(
        headers: headers
      ).to_return(
        status: 200,
        body: file_fixture("user_valid_response.txt").read,
        headers: {}
      )
  end

  def stub_user_not_found_request
    stub_request(:get, user_request_url)
      .with(
        headers: headers
      ).to_return(
        status: 200,
        body: file_fixture("user_not_found_response.txt").read,
        headers: {}
      )
  end

  def stub_user_invalid_request
    stub_request(:get, user_request_url)
      .with(
        headers: headers
      ).to_return(
        status: 200,
        body: file_fixture("user_invalid_response.txt").read,
        headers: {}
      )
  end

  ## Contact
  def stub_contact_valid_request
    stub_request(:get, contact_request_url)
      .with(
        headers: headers
      ).to_return(
        status: 200,
        body: file_fixture("contact_valid_response.txt").read,
        headers: {}
      )
  end

  ## Groups
  def stub_groups_valid_request
    stub_request(:get, groups_request_url)
      .with(
        headers: headers
      ).to_return(
        status: 200,
        body: file_fixture("groups_valid_response.txt").read,
        headers: {}
      )
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

  # This will change depending on your gems versions.
  def headers
    {
      "Accept" => "*/*",
      "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "User-Agent" => "Faraday v1.2.0"
    }
  end
end
