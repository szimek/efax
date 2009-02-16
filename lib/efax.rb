#--
# (The MIT License)
#
# Copyright (c) 2008 Szymon Nowak & Pawel Kozlowski (U2I)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#++
#

require 'rubygems'
require 'net/http'
require 'net/https'
require 'builder'
require 'hpricot'
require 'base64'

module Net #:nodoc:
  # Helper class for making HTTPS requests
  class HTTPS < HTTP
    def self.start(address, port = nil, p_addr = nil, p_port = nil, p_user = nil, p_pass = nil, &block) #:nodoc:
      https = new(address, port, p_addr, p_port, p_user, p_pass)
      https.use_ssl = true
      https.start(&block)
    end
  end
end

module EFax
  # URL of eFax web service
  URL      = "https://secure.efaxdeveloper.com/EFax_WebFax.serv"  
  # URI of eFax web service
  URI      = URI.parse(URL)
  # Prefered content type
  HEADERS  = {'Content-Type' => 'text/xml'}  

  # Base class for OutboundRequest and OutboundStatus classes
  class Request
    def self.user
      @@user
    end
    def self.user=(name)
      @@user = name
    end

    def self.password
      @@password
    end
    def self.password=(password)
      @@password = password
    end

    def self.account_id
      @@account_id
    end
    def self.account_id=(id)
      @@account_id = id
    end
    
    def self.params(content)
      escaped_xml = ::URI.escape(content, Regexp.new("[^#{::URI::PATTERN::UNRESERVED}]"))
      "id=#{account_id}&xml=#{escaped_xml}&respond=XML"
    end

    private_class_method :params
  end  

  class OutboundRequest < Request
    def self.post(name, company, fax_number, subject, html_content)
      xml_request = xml(name, company, fax_number, subject, html_content)
      response = Net::HTTPS.start(EFax::URI.host, EFax::URI.port) do |https|
        https.post(EFax::URI.path, params(xml_request), EFax::HEADERS)
      end
      OutboundResponse.new(response)
    end
    
    def self.xml(name, company, fax_number, subject, html_content)
      xml_request = ""
      xml = Builder::XmlMarkup.new(:target => xml_request, :indent => 2 )
      xml.instruct! :xml, :version => '1.0'
      xml.OutboundRequest do
        xml.AccessControl do
          xml.UserName(self.user)
          xml.Password(self.password)
        end
        xml.Transmission do
          xml.TransmissionControl do
            xml.Resolution("FINE")
            xml.Priority("NORMAL")
            xml.SelfBusy("ENABLE")
            xml.FaxHeader(subject)
          end
          xml.DispositionControl do
            xml.DispositionLevel("NONE")
          end
          xml.Recipients do
            xml.Recipient do
              xml.RecipientName(name)
              xml.RecipientCompany(company)
              xml.RecipientFax(fax_number)
            end
          end
          xml.Files do
            xml.File do
              encoded_html = Base64.encode64(html_content).delete("\n")
              xml.FileContents(encoded_html)
              xml.FileType("html")
            end
          end
        end
      end
      xml_request
    end

    private_class_method :xml
  end

  class RequestStatus
    HTTP_FAILURE = 0
    SUCCESS      = 1
    FAILURE      = 2
  end

  class OutboundResponse
    attr_reader :status_code
    attr_reader :error_message
    attr_reader :error_level
    attr_reader :doc_id

    def initialize(response)  #:nodoc:
      if response.is_a? Net::HTTPOK
        doc = Hpricot(response.body)
        @status_code = doc.at(:statuscode).inner_text.to_i
        @error_message = doc.at(:errormessage)
        @error_message = @error_message.inner_text if @error_message
        @error_level = doc.at(:errorlevel)
        @error_level = @error_level.inner_text if @error_level
        @doc_id = doc.at(:docid).inner_text
        @doc_id = @doc_id.empty? ? nil : @doc_id
      else
        @status_code = RequestStatus::HTTP_FAILURE
        @error_message = "HTTP request failed (#{response.code})"
      end
    end
  end

  class OutboundStatus < Request
    def self.post(doc_id)
      data = params(xml(doc_id))
      response = Net::HTTPS.start(EFax::URI.host, EFax::URI.port) do |https|
        https.post(EFax::URI.path, data, EFax::HEADERS)
      end
      OutboundStatusResponse.new(response)
    end
    
    def self.xml(doc_id)
      xml_request = ""
      xml = Builder::XmlMarkup.new(:target => xml_request, :indent => 2 )
      xml.instruct! :xml, :version => '1.0'
      xml.OutboundStatus do
        xml.AccessControl do
          xml.UserName(self.user)
          xml.Password(self.password)
        end
        xml.Transmission do
          xml.TransmissionControl do
            xml.DOCID(doc_id)
          end
        end
      end
      xml_request
    end

    private_class_method :xml
  end

  class QueryStatus
    HTTP_FAILURE = 0
    PENDING      = 3
    SENT         = 4
    FAILURE      = 5
  end

  class OutboundStatusResponse
    attr_reader :status_code
    attr_reader :message
    attr_reader :classification
    attr_reader :outcome

    def initialize(response) #:nodoc:
      if response.is_a? Net::HTTPOK
        doc = Hpricot(response.body)
        @message = doc.at(:message).innerText
        @classification = doc.at(:classification).innerText.delete('"')
        @outcome = doc.at(:outcome).innerText.delete('"')
        if @classification.empty? && @outcome.empty?
          @status_code = QueryStatus::PENDING
        elsif @classification == "Success" && @outcome == "Success"
          @status_code = QueryStatus::SENT
        else
          @status_code = QueryStatus::FAILURE
        end
      else
        @status_code = QueryStatus::HTTP_FAILURE
        @message = "HTTP request failed (#{response.code})"
      end
    end
  end

end
