require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/efax/outbound'

module EFaxOutboundTest

  class RequestTest < Test::Unit::TestCase
    def test_should_encode_data
      EFax::Request.account_id = 1234567890
      EFax::Request.publicize_class_methods do
        assert_equal "id=1234567890&xml=%40abc%23&respond=XML", EFax::Request.params('@abc#')
      end
    end
  end

  class OutboundResponseTest < Test::Unit::TestCase
    def test_successful_response
      xml = <<-XML
        <?xml version="1.0"?>
        <OutboundResponse>
          <Transmission>
            <TransmissionControl>
              <TransmissionID></TransmissionID>
              <DOCID>12345678</DOCID>
            </TransmissionControl>
            <Response>
              <StatusCode>1</StatusCode>
              <StatusDescription>Success</StatusDescription>
            </Response>
          </Transmission>
        </OutboundResponse>
      XML
      http_response = mock
      http_response.expects(:is_a?).with(Net::HTTPOK).returns(true)
      http_response.expects(:body).returns(xml)
      response = EFax::OutboundResponse.new(http_response)

      assert_equal EFax::RequestStatus::SUCCESS, response.status_code
      assert_equal "12345678", response.doc_id
      assert_nil response.error_message
      assert_nil response.error_level
    end

    def test_system_level_failed_response
      xml = <<-XML
        <?xml version="1.0"?>
        <OutboundResponse>
          <Transmission>
            <TransmissionControl>
              <TransmissionID></TransmissionID>
              <DOCID></DOCID>
            </TransmissionControl>
            <Response>
              <StatusCode>2</StatusCode>
              <StatusDescription>Failure</StatusDescription>
              <ErrorLevel>System</ErrorLevel>
              <ErrorMessage>We FAIL</ErrorMessage>
            </Response>
          </Transmission>
        </OutboundResponse>
      XML
      http_response = mock()
      http_response.expects(:is_a?).with(Net::HTTPOK).returns(true)
      http_response.expects(:body).returns(xml)
      response = EFax::OutboundResponse.new(http_response)
      assert_equal EFax::RequestStatus::FAILURE, response.status_code
      assert_nil response.doc_id
      assert_equal "We FAIL", response.error_message
      assert_equal "System", response.error_level
    end

    def test_user_level_failed_response
      xml = <<-XML
        <?xml version="1.0"?>
        <OutboundResponse>
          <Transmission>
            <TransmissionControl>
              <TransmissionID></TransmissionID>
              <DOCID></DOCID>
            </TransmissionControl>
            <Response>
              <StatusCode>2</StatusCode>
              <StatusDescription>Failure</StatusDescription>
              <ErrorLevel>User</ErrorLevel>
              <ErrorMessage>"QWE RTY" does not satisfy the "base64Binary" type</ErrorMessage>
            </Response>
          </Transmission>
        </OutboundResponse>
      XML
      http_response = mock()
      http_response.expects(:is_a?).with(Net::HTTPOK).returns(true)
      http_response.expects(:body).returns(xml)
      response = EFax::OutboundResponse.new(http_response)
      assert_equal EFax::RequestStatus::FAILURE, response.status_code
      assert_nil response.doc_id
      assert_equal '"QWE RTY" does not satisfy the "base64Binary" type', response.error_message
      assert_equal "User", response.error_level
    end

    def test_http_failed_response
      http_response = mock()
      http_response.expects(:is_a?).with(Net::HTTPOK).returns(false)
      http_response.expects(:code).returns(500)
      response = EFax::OutboundResponse.new(http_response)
      assert_equal EFax::RequestStatus::HTTP_FAILURE, response.status_code
      assert_nil response.doc_id
      assert_equal "HTTP request failed (500)", response.error_message
      assert_nil response.error_level
    end
  end

  class OutboundStatusResponseTest < Test::Unit::TestCase
    def test_successful_response
      xml = <<-XML
        <?xml version="1.0"?>
        <OutboundStatusResponse>
          <Transmission>
            <TransmissionControl>
              <TransmissionID></TransmissionID>
            </TransmissionControl>
            <Recipients>
              <Recipient>
                <DOCID>12345678</DOCID>
                <Name>Mike Rotch</Name>
                <Company>Moe's</Company>
                <Fax>12345678901</Fax>
                <Status>
                  <Message>Your transmission has completed.</Message>
                  <Classification>"Success"</Classification>
                  <Outcome>"Success"</Outcome>
                </Status>
                <LastAttempt>
                  <LastDate>08/06/2008</LastDate>
                  <LastTime>05:49:05</LastTime>
                </LastAttempt>
                <NextAttempt>
                  <NextDate></NextDate>
                  <NextTime></NextTime>
                </NextAttempt>
                <Pages>
                  <Scheduled>1</Scheduled>
                  <Sent>1</Sent>
                </Pages>
                <BaudRate>14400</BaudRate>
                <Duration>0.4</Duration>
                <Retries>1</Retries>
                <RemoteCSID>"-"</RemoteCSID>
              </Recipient>
            </Recipients>
          </Transmission>
        </OutboundStatusResponse>
      XML
      http_response = mock()
      http_response.expects(:is_a?).with(Net::HTTPOK).returns(true)
      http_response.expects(:body).returns(xml)
      response = EFax::OutboundStatusResponse.new(http_response)
      assert_equal "Your transmission has completed.", response.message
      assert_equal "Success", response.outcome
      assert_equal "Success", response.classification
      assert_equal EFax::QueryStatus::SENT, response.status_code
    end

        def test_busy_response
      xml = <<-XML
        <?xml version="1.0"?>
        <OutboundStatusResponse>
          <Transmission>
            <TransmissionControl>
              <TransmissionID></TransmissionID>
            </TransmissionControl>
            <Recipients>
              <Recipient>
                <DOCID>12345678</DOCID>
                <Name>Mike Rotch</Name>
                <Company>Moe's</Company>
                <Fax>12345678901</Fax>
                <Status>
                  <Message>Your transmission is waiting to be sent.</Message>
                  <Classification>Busy</Classification>
                  <Outcome>Normal busy: remote end busy (off hook)</Outcome>
                </Status>
                <LastAttempt>
                  <LastDate></LastDate>
                  <LastTime></LastTime>
                </LastAttempt>
                <NextAttempt>
                  <NextDate></NextDate>
                  <NextTime></NextTime>
                </NextAttempt>
                <Pages>
                  <Scheduled>1</Scheduled>
                  <Sent>1</Sent>
                </Pages>
                <BaudRate>14400</BaudRate>
                <Duration>0.4</Duration>
                <Retries>1</Retries>
                <RemoteCSID>"-"</RemoteCSID>
              </Recipient>
            </Recipients>
          </Transmission>
        </OutboundStatusResponse>
      XML

      http_response = mock()
      http_response.expects(:is_a?).with(Net::HTTPOK).returns(true)
      http_response.expects(:body).returns(xml)
      response = EFax::OutboundStatusResponse.new(http_response)

      assert_equal "Normal busy: remote end busy (off hook)", response.outcome
      assert_equal "Busy", response.classification
      assert_equal "Your transmission is waiting to be sent.", response.message
      assert_equal EFax::QueryStatus::PENDING, response.status_code
    end

    def test_pending_response
      xml = <<-XML
        <?xml version="1.0"?>
        <OutboundStatusResponse>
          <Transmission>
            <TransmissionControl>
              <TransmissionID></TransmissionID>
            </TransmissionControl>
            <Recipients>
              <Recipient>
                <DOCID>12345678</DOCID>
                <Name>Mike Rotch</Name>
                <Company>Moe's</Company>
                <Fax>12345678901</Fax>
                <Status>
                  <Message>Your fax is waiting to be send</Message>
                  <Classification></Classification>
                  <Outcome></Outcome>
                </Status>
                <LastAttempt>
                  <LastDate></LastDate>
                  <LastTime></LastTime>
                </LastAttempt>
                <NextAttempt>
                  <NextDate></NextDate>
                  <NextTime></NextTime>
                </NextAttempt>
                <Pages>
                  <Scheduled>1</Scheduled>
                  <Sent>1</Sent>
                </Pages>
                <BaudRate>14400</BaudRate>
                <Duration>0.4</Duration>
                <Retries>1</Retries>
                <RemoteCSID>"-"</RemoteCSID>
              </Recipient>
            </Recipients>
          </Transmission>
        </OutboundStatusResponse>
      XML

      http_response = mock()
      http_response.expects(:is_a?).with(Net::HTTPOK).returns(true)
      http_response.expects(:body).returns(xml)
      response = EFax::OutboundStatusResponse.new(http_response)

      assert_equal "", response.outcome
      assert_equal "", response.classification
      assert_equal EFax::QueryStatus::PENDING, response.status_code
    end

    def test_failed_response
      xml = <<-XML
        <?xml version="1.0"?>
        <OutboundStatusResponse>
          <Transmission>
            <TransmissionControl>
              <TransmissionID></TransmissionID>
            </TransmissionControl>
            <Recipients>
              <Recipient>
                <DOCID>12345678</DOCID>
                <Name>Mike Rotch</Name>
                <Company>Moe's</Company>
                <Fax>12345678901</Fax>
                <Status>
                  <Message>Your fax caused the world to end</Message>
                  <Classification>Apocalyptic failure</Classification>
                  <Outcome>End of days</Outcome>
                </Status>
                <LastAttempt>
                  <LastDate></LastDate>
                  <LastTime></LastTime>
                </LastAttempt>
                <NextAttempt>
                  <NextDate></NextDate>
                  <NextTime></NextTime>
                </NextAttempt>
                <Pages>
                  <Scheduled>1</Scheduled>
                  <Sent>0</Sent>
                </Pages>
                <BaudRate></BaudRate>
                <Duration></Duration>
                <Retries>1</Retries>
                <RemoteCSID>"-"</RemoteCSID>
              </Recipient>
            </Recipients>
          </Transmission>
        </OutboundStatusResponse>
      XML

      http_response = mock()
      http_response.expects(:is_a?).with(Net::HTTPOK).returns(true)
      http_response.expects(:body).returns(xml)
      response = EFax::OutboundStatusResponse.new(http_response)

      assert_equal "Your fax caused the world to end", response.message
      assert_equal "End of days", response.outcome
      assert_equal "Apocalyptic failure", response.classification
      assert_equal EFax::QueryStatus::FAILURE, response.status_code
    end

  end

  class OutboundRequestTest < Test::Unit::TestCase
    def test_generate_xml
      expected_xml = <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
          <OutboundRequest>
            <AccessControl>
              <UserName>Mike Rotch</UserName>
              <Password>moes</Password>
            </AccessControl>
            <Transmission>
              <TransmissionControl>
                <Resolution>FINE</Resolution>
                <Priority>NORMAL</Priority>
                <SelfBusy>ENABLE</SelfBusy>
                <FaxHeader>Subject</FaxHeader>
              </TransmissionControl>
            <DispositionControl>
              <DispositionLevel>NONE</DispositionLevel>
            </DispositionControl>
            <Recipients>
              <Recipient>
                <RecipientName>I. P. Freely</RecipientName>
                <RecipientCompany>Moe's</RecipientCompany>
                <RecipientFax>12345678901</RecipientFax>
              </Recipient>
            </Recipients>
            <Files>
              <File>
                <FileContents>PGh0bWw+PGJvZHk+PGgxPlRlc3Q8L2gxPjwvYm9keT48L2h0bWw+</FileContents>
                <FileType>html</FileType>
              </File>
            </Files>
          </Transmission>
        </OutboundRequest>
      XML
      EFax::Request.user = "Mike Rotch"
      EFax::Request.password = "moes"
      EFax::OutboundRequest.publicize_class_methods do
        assert_equal expected_xml.delete(" "), EFax::OutboundRequest.xml("I. P. Freely", "Moe's", "12345678901", "Subject", "<html><body><h1>Test</h1></body></html>").delete(" ")
      end
    end
  end

  class OutboundStatusTest < Test::Unit::TestCase
    def test_generate_xml
      expected_xml = <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <OutboundStatus>
          <AccessControl>
            <UserName>Mike Rotch</UserName>
            <Password>moes</Password>
          </AccessControl>
          <Transmission>
            <TransmissionControl>
              <DOCID>123456</DOCID>
            </TransmissionControl>
          </Transmission>
        </OutboundStatus>
      XML

      EFax::OutboundStatus.publicize_class_methods do
        assert_equal expected_xml.delete(" "), EFax::OutboundStatus.xml("123456").delete(" ")
      end
    end
  end

  class OutboundStatusTest < Test::Unit::TestCase
    def test_generate_xml
      expected_xml = <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <OutboundStatus>
          <AccessControl>
            <UserName>Mike Rotch</UserName>
            <Password>moes</Password>
          </AccessControl>
          <Transmission>
            <TransmissionControl>
              <DOCID>123456</DOCID>
            </TransmissionControl>
          </Transmission>
        </OutboundStatus>
      XML

      EFax::Request.user = "Mike Rotch"
      EFax::Request.password = "moes"
      EFax::OutboundStatus.publicize_class_methods do
        assert_equal expected_xml.delete(" "), EFax::OutboundStatus.xml("123456").delete(" ")
      end
    end
  end

end
