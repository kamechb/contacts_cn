dir = File.dirname(__FILE__)
require "#{dir}/../test_helper"
require 'contacts'
class NetEaseContactImporterTest < ContactImporterTestCase
  def setup
    super
    @wy163 = TestAccounts[:wy163]
    @wy126 = TestAccounts[:wy126]
    @yeah = TestAccounts[:yeah]
    @accounts = [@wy163,@wy126,@yeah]
  end

  def test_successful_login
    @accounts.each do |account|
      Contacts.new(:net_ease, account.username, account.password)
    end
  end

  def test_importer_fails_with_invalid_password
    @accounts.each do |account|
      assert_raise(Contacts::AuthenticationError) do
        Contacts.new(:net_ease, account.username, "wrong_password")
      end
    end
  end

  def test_importer_fails_with_blank_password
    @accounts.each do |account|
      assert_raise(Contacts::AuthenticationError) do
        Contacts.new(:net_ease, account.username, "")
      end
    end
  end

  def test_importer_fails_with_blank_username
    @accounts.each do |account|
      assert_raise(Contacts::MailServerError) do
        Contacts.new(:net_ease, "", account.password)
      end
    end
  end

  def test_importer_fails_with_invalid_username
    @accounts.each do |account|
      assert_raise(Contacts::MailServerError) do
        Contacts.new(:net_ease, "error_username", account.password)
      end
    end
  end

  def test_fetch_contacts
    @accounts.each do |account|
      contacts = Contacts.new(:net_ease, account.username, account.password).contacts
      account.contacts.each do |contact|
        assert contacts.include?(contact), "Could not find: #{contact.inspect} in #{contacts.inspect}"
      end
    end
  end

end
