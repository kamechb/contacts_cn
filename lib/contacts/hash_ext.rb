require 'erb'
class Hash
  def to_query_string
    u = ERB::Util.method(:u)
    map { |k, v|
      u.call(k) + "=" + u.call(v)
    }.join("&")
  end
end
