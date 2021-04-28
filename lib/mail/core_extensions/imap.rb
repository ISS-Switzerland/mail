# frozen_string_literal: true

require 'net/imap'

module ImapXoauth2
  class Authenticator
    
    def process(data)
      build_oauth2_string(@user, @oauth2_token)
    end
    
  private
    
    def initialize(user, oauth2_token)
      @user = user
      @oauth2_token = oauth2_token
    end
    
    def build_oauth2_string(user, oauth2_token)
      "user=%s\1auth=Bearer %s\1\1".encode("us-ascii") % [user, oauth2_token]
    end
  end
end

Net::IMAP.add_authenticator('XOAUTH2', ImapXoauth2::Authenticator)
