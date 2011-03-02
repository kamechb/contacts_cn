class Contacts
  class Sina < Base
  	URL = "http://mail.sina.com.cn"
    LOGIN_URL = {
    	:sina_cn => "https://mail.sina.com.cn/cgi-bin/cnlogin.php",
    	:sina_com => "https://mail.sina.com.cn/cgi-bin/login.php"
    }
		LOGIN_COOKIE = {
			:sina_cn => "sina_cn_mail_id=nonobo_t; sina_cn_mail_recid=true",
			:sina_com => "sina_free_mail_id=fangs2; sina_free_mail_recid=true; sina_free_mail_ltype=uid; sina_vip_mail_recid=false"
		}
		DOMAIN = {
			:sina_cn => 'sina.cn',
			:sina_com => 'sina.com'
		}
		PROTOCOL_ERROR = "sina has changed its protocols, please upgrade this library first. you can also contact kamechb@gmail.com"

    def initialize(login, password, options={})
			@mail_type = get_mail_type(login)
			super(login,password,options)
    end

    def real_connect
			login_for_cookies
			redirect_for_location
    end

    def contacts
			return @contacts if @contacts
      if connected?
      	data, resp, cookies, forward = get(@mail_url,@cookies)
      	if resp.code_type != Net::HTTPOK
          raise ConnectionError, self.class.const_get(:PROTOCOL_ERROR)
        end
        parse(data)
      end
    end

    private

    def get_mail_type(username)
    	if username.include?("@sina.com")
    		:sina_com
    	elsif username.include?("@sina.cn")
    		:sina_cn
    	else
    		raise MailServerError, "there are only two mail servers that sina.com and sina.cn. please add domain after username"
    	end
    end

    def parse(data)
			data =~ /conf.*?contacts:.*?(\{.*?\}),\s*groups:/m
			contacts = $1.gsub("&quot;",'')
			contacts = ActiveSupport::JSON.decode(contacts)
			contacts['contact'].map{|contactor|
				[contactor['name'],contactor['email']]
			}
    end

    def login_for_cookies
    	data = {
    		:domain => DOMAIN[@mail_type],
				:logintype => 'uid',
				:u => @login,
				:psw => @password,
				:savelogin => 'on',
				:sshchk => 'on',
				:ssl => 'on'
    	}
    	data, resp, cookies, forward = post(LOGIN_URL[@mail_type],data.to_query_string,LOGIN_COOKIE[@mail_type])
    	login_faile_flag = %r{form.*?action.*?http.*?mail.sina.com.cn/cgi-bin/.*?login.php}m
    	if data.match(login_faile_flag)
    		raise AuthenticationError, "Username or password error"
    	end
    	data.match(/URL=(http:\/\/.*?)'>/)
			@redirect_url = $1
			@mail_server = @redirect_url.match(/(http:\/\/.*\..*?)\//)
			@cookies = cookies
    end

    def redirect_for_location
    	data, resp, cookies, forward = get(@redirect_url,@cookies)
    	location = resp['Location']
    	@mail_url = location.index("http://") ? location : "#{@mail_server}#{location}"
    	@cookies = cookies
    end

    TYPES[:sina] = Sina
  end

end
