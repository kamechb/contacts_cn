dir = File.dirname(__FILE__)
require "#{dir}/../test_helper"
require 'contacts'
class SinaContactImporterTest < ContactImporterTestCase
  def setup
    super
    @sina_cn = TestAccounts[:sina_cn]
    @sina_com = TestAccounts[:sina_com]
    @accounts = [@sina_cn,@sina_com]
  end

  def test_successful_login
    @accounts.each do |account|
      Contacts.new(:sina, account.username, account.password)
    end
  end

  def test_importer_fails_with_invalid_password
    @accounts.each do |account|
      assert_raise(Contacts::AuthenticationError) do
        Contacts.new(:sina, account.username, "wrong_password")
      end
    end
  end

  def test_importer_fails_with_blank_password
    @accounts.each do |account|
      assert_raise(Contacts::AuthenticationError) do
        Contacts.new(:sina, account.username, "")
      end
    end
  end

  def test_importer_fails_with_blank_username
    @accounts.each do |account|
      assert_raise(Contacts::MailServerError) do
        Contacts.new(:sina, "", account.password)
      end
    end
  end

  def test_importer_fails_with_invalid_username
    @accounts.each do |account|
      assert_raise(Contacts::MailServerError) do
        Contacts.new(:sina, "error_username", account.password)
      end
    end
  end

  def test_fetch_contacts
    @accounts.each do |account|
      contacts = Contacts.new(:sina, account.username, account.password).contacts
      account.contacts.each do |contact|
        assert contacts.include?(contact), "Could not find: #{contact.inspect} in #{contacts.inspect}"
      end
    end
  end

end
