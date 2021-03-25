# encoding: utf-8
# frozen_string_literal: true

require 'base64'

# This is a backport of r30294 from ruby trunk because of a bug in net/smtp.
# http://svn.ruby-lang.org/cgi-bin/viewvc.cgi?view=rev&amp;revision=30294
#
# Fixed in Ruby 1.9.3 - tlsconnect also does not exist in some early versions of ruby
if RUBY_VERSION < '1.9.3'
  module Net
    class SMTP
      begin
        alias_method :original_tlsconnect, :tlsconnect

        def tlsconnect(s)
          verified = false
          begin
            original_tlsconnect(s).tap { verified = true }
          ensure
            unless verified
              s.close rescue nil
            end
          end
        end
      rescue NameError
      end
    end
  end
end

module Net
  class SMTP
    def send_xoauth2(auth_token)
      critical {
        get_response("AUTH XOAUTH2 #{auth_token}")
      }
    end
    private :send_xoauth2

    def get_final_status
      critical {
        get_response('')
      }
    end
    private :get_final_status

    def auth_xoauth2(user, oauth2_token)
      check_auth_args user, oauth2_token

      auth_string = build_oauth2_string(user, oauth2_token)
      res = send_xoauth2(base64_encode(auth_string))

      if res.continue?
        res = get_final_status
      end

      check_auth_response res
      res
    end

    def build_oauth2_string(user, oauth2_token)
      "user=%s\1auth=Bearer %s\1\1".encode("us-ascii") % [user, oauth2_token]
    end
    private :build_oauth2_string
  end
end
