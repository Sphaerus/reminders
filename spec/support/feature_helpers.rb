module FeatureHelpers
  def log_in(user)
    OmniAuth.config.mock_auth[:google_oauth2] =
      OmniAuth::AuthHash.new(
        provider: user.provider,
        uid: user.uid,
        info: { name: "John", email: "john@doe.pl" },
      )
    visit "/auth/google_oauth2"
  end

  def finished_jquery_requests?
    evaluate_script '(typeof jQuery === "undefined") || (jQuery.active == 0)'
  end

  def wait_for_jquery
    sleep(0.001) until finished_jquery_requests?
  end
end
