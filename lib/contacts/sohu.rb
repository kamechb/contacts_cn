class Contacts
  class Sohu < Base
  	URL = "http://mail.sohu.com"
  	DOMAIN = "sohu.com"
    LOGIN_URL = "https://passport.sohu.com/sso/login.jsp"
    LOGIN_COOKIE = "IPLOC=CN3301; SUV=1008301317090277"
		MAIL_URL = "http://mail.sohu.com/bapp/81/main"
		PROTOCOL_ERROR = "sohu has changed its protocols, please upgrade this library first. you can also contact kamechb@gmail.com"

    def real_connect
    	login_for_cookies
    end

    def contacts
			return @contacts if @contacts
      if connected?
      	data, resp, cookies, forward = get(MAIL_URL,@cookies)
      	if resp.code_type != Net::HTTPOK
          raise ConnectionError, self.class.const_get(:PROTOCOL_ERROR)
        end
        parse(data)
      end
    end

    private


    def parse(data)
			data.match(/ADDRESSES.*?'(\{.*?\})';/m)
			contacts = ActiveSupport::JSON.decode($1)
			contacts['contact'].map{|contactor|
				[contactor['nickname'],contactor['email']]
			}
    end

		def login_for_cookies
			data = {
				:userid => @login,
				:password => @password,
				:appid => '1000',
				:persistentcookie => '0',
				:s => '1283173792650',
				:b => '2',
				:w => '1280',
				:pwdtype => '0',
				:v => '26'
			}
			data, resp, cookies, forward = get("#{LOGIN_URL}?#{data.to_query_string}",LOGIN_COOKIE)
			login_faile_flag = %r{login_status.*?error}
			if data.match(login_faile_flag)
				raise AuthenticationError, "Username or password error"
			end
			@cookies = cookies
		end

    TYPES[:sohu] = Sohu
  end

end
