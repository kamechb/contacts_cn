class Contacts
  class NetEase < Base
  	URL = "http://www.163.com"
    LOGIN_URL = "https://reg.163.com/logins.jsp"
    LoginData = {
    	:url2 => {
    		:wy163 => 'http://mail.163.com/errorpage/err_163.htm',
		  	:wy126 => 'http://mail.126.com/errorpage/err_126.htm',
				:yeah => 'http://mail.yeah.net/errorpage/err_yeah.htm'
    	},
    	:url => {
    		:wy163 => 'http://entry.mail.163.com/coremail/fcg/ntesdoor2?lightweight=1&verifycookie=1&language=-1&style=-1&username=%s',
    		:wy126 => 'http://entry.mail.126.com/cgi/ntesdoor?hid=10010102&lightweight=1&verifycookie=1&language=0&style=-1&username=%s',
    		:yeah => 'http://entry.mail.yeah.net/cgi/ntesdoor?lightweight=1&verifycookie=1&style=-1&username=%s'
    	},
    	:product => {
    		:wy163 => 'mail163',
    		:wy126 => 'mail126',
    		:yeah => 'mailyeah'
    	}
    }
    ENTER_MAIL_URL = {
    	:wy163 => "http://entry.mail.163.com/coremail/fcg/ntesdoor2?lightweight=1&verifycookie=1&language=-1&style=-1&username=%s",
    	:wy126 => "http://entry.mail.126.com/cgi/ntesdoor?hid=10010102&lightweight=1&verifycookie=1&language=0&style=-1&username=%s",
    	:yeah => "http://entry.mail.yeah.net/cgi/ntesdoor?lightweight=1&verifycookie=1&style=-1&username=%s"
    }

		CONTACT_LIST_URL = "%ss?sid=%s&func=global:sequential"
		PROTOCOL_ERROR = "netease has changed its protocols, please upgrade this library first. you can also contact kamechb@gmail.com"

    def initialize(login, password, options={})
			@mail_type = get_mail_type(login)
			super(login,password,options)
    end

    def real_connect
			login_for_cookies
			enter_mail_server
    end

    def contacts
    	return @contacts if @contacts
      if connected?
				url = URI.parse(CONTACT_LIST_URL % [@mail_server,@sid])
				http = open_http(url)
				postdata = '<?xml version="1.0"?><object><array name="items"><object><string name="func">pab:searchContacts</string><object name="var"><array name="order"><object><string name="field">FN</string><boolean name="ignoreCase">true</boolean></object></array></object></object><object><string name="func">user:getSignatures</string></object><object><string name="func">pab:getAllGroups</string></object></array></object>'
				set_header = {"Cookie" => @cookies,'Accept' => 'text/javascript','Content-Type' => 'application/xml; charset=UTF-8'}
				resp, data = http.post("#{url.path}?#{url.query}",postdata,set_header)
				if resp.code_type != Net::HTTPOK
          raise ConnectionError, self.class.const_get(:PROTOCOL_ERROR)
        end
				parse(data)
      end
    end

    private

    def get_mail_type(username)
    	if username.include?("@126.com")
    		:wy126
    	elsif username.include?("@163.com")
    		:wy163
    	elsif username.include?("@yeah.net")
    		:yeah
    	else
    		raise MailServerError, "there are only three mail servers that 126.com, 163.com and yeah.net. please add domain after username"
    	end
    end

    def parse(data)
    	json_data = Contacts.parse_json(data)
    	json_data['var'][0]['var'].map{|contactor|
    		[contactor['FN'],contactor['EMAIL;PREF']]
    	}
    end

    def login_for_cookies
    	data = {
	      :type => '1',
				:url => LoginData[:url][@mail_type],
				:username => @login,
				:password => @password,
				:selType => '-1',
				:remUser => '1',
				:secure => 'on',
				:verifycookie => '1',
				:style => '-1',
				:product => LoginData[:product][@mail_type],
				:savelogin => '',
				:url2 => LoginData[:url2][@mail_type]
      }
      postdata = data.to_query_string
      #login and get cookie
      data, resp, cookies, forward = post(LOGIN_URL,postdata)
      @cookies = cookies
      if data.index(LoginData[:url2][@mail_type])
      	raise AuthenticationError, "Username or password error"
      end
    end

    def enter_mail_server
			#get mail server and sid
			enter_mail_url = ENTER_MAIL_URL[@mail_type] % @login
			data, resp, cookies, forward = get(enter_mail_url,@cookies)
			location = resp['Location']
			data_reg = /<a.*?(http.*?)main.jsp\?sid=(.*?)\">/
			location_reg = /(http.*?)main.jsp\?sid=(.*)/
			unless data.match(data_reg) || location.match(location_reg)
				raise ConnectionError, self.class.const_get(:PROTOCOL_ERROR)
			end
			@cookies = cookies
			@mail_server = $1
			@sid = $2
    end
    TYPES[:net_ease] = NetEase
  end
end
