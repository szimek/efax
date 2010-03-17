require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/efax/inbound'
require 'efax/helpers/inbound_helpers'

module EFaxInboundTest
  class InboundPostRequestTest < Test::Unit::TestCase
    include EFax::Helpers::InboundHelpers

    def test_receive_by_params
      EFax::InboundPostRequest.expects(:receive_by_xml).with(efax_inbound_post_xml).returns(response = mock)
      assert_equal(EFax::InboundPostRequest.receive_by_params({:xml => efax_inbound_post_xml}), response)
    end

    def test_receive_by_xml
      response = efax_inbound_post(:barcodes => %w[EFAXTEST1A EFAXTEST2A EFAXTEST3A EFAXTEST4A EFAXTEST5A])

      assert_equal efax_inbound_post_file_contents, response.encoded_file_contents
      assert_equal :pdf,          response.file_type
      assert_equal '8587123600',  response.sender_fax_number
      assert_equal '8587123600',  response.ani
      assert_equal '1234567890',  response.account_id
      assert_equal 'SampleOut',   response.fax_name
      assert_equal '8587123600',  response.csid
      assert_equal 0,             response.status
      assert_equal 12345678,      response.mcfid
      assert_equal 5,             response.page_count
      assert_equal 'New Inbound', response.request_type
      assert_equal %w[EFAXTEST1A EFAXTEST2A EFAXTEST3A EFAXTEST4A EFAXTEST5A],
                                  response.barcodes
      assert_not_nil response.file_contents
      assert_not_nil response.file
      assert_respond_to response.file, :read
      assert_equal response.file_contents, response.file.read

      # According to docs these will always be "Pacific Time Zone" (sometimes -8, sometimes -7 -- using -8)
      assert_equal Time.utc(2005,8,18,20,2,13), response.date_received
      assert_equal Time.utc(2005,8,18,20,2,25), response.request_date
    end

  end
end

