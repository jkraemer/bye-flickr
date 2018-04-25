module ByeFlickr
  class Auth
    def self.call
      new.call
    end

    def call
      unless test_login
        request_auth
      end
      { username: @username, id: @id}
    end

    def test_login
      login = flickr.test.login
      @username = login.username
      @id = login.id
      true
    rescue
      puts $!
      false
    end

    def request_auth
      token = flickr.get_request_token
      auth_url = flickr.get_authorize_url(token['oauth_token'], perms: 'read')

      puts "Open this url in your browser to complete the authentication process:\n#{auth_url}"
      puts "Copy here the number given when you complete the process."

      verify = $stdin.gets.strip
      flickr.get_access_token(token['oauth_token'], token['oauth_token_secret'], verify)

      if test_login
        puts "You are now authenticated as #{@username} with token #{flickr.access_token} and secret #{flickr.access_secret}"
      else
        puts "Login failed."
      end
    end

  end
end
