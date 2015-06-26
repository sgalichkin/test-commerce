class ThemeUpload
  UPLOADS_FOLDER_NAME = "uploads"
  attr_reader :policy_conditions
  attr_reader :policy
  attr_reader :encoded_policy
  attr_reader :encoded_signature

  def initialize bucket_name, redirect_url
    @policy_conditions = [[:eq, :$bucket, bucket_name],\
                          [:eq, :$acl, :private],\
                          [:"content-length-range", 1, Rails.configuration.max_theme_zip_file_length],\
                          [:"starts-with", :$key, UPLOADS_FOLDER_NAME + "/"],\
                          [:eq, :$success_action_redirect, redirect_url]]
    @policy = { conditions: @policy_conditions, expiration: (Time.now + 10*60*60).utc.iso8601 }
    @encoded_policy = Base64.encode64(@policy.to_json).gsub("\n","")
    @encoded_signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), Rails.configuration.aws_secret_key, @encoded_policy)).gsub("\n","")
  end
end