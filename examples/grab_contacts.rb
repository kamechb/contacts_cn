require File.dirname(__FILE__)+"/../lib/im_contacts"

login = ARGV[0]
password = ARGV[1]
#login is your email
Contacts::Gmail.new(login, password).contacts

Contacts.new(:gmail, login, password).contacts

Contacts.new("gmail", login, password).contacts

Contacts.guess(login, password).contacts

Contacts.new(:yahoo,login,password).contacts

Contacts.new(:hotmail,login,password).contacts

#net_ease support 163.com, 126.com, yeah.net
Contacts.new(:net_ease,login,password).contacts

Contacts.new(:sina,login,password).contacts

Contacts.new(:sohu,login,password).contacts
