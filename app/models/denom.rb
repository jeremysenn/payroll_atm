class Denom < ActiveRecord::Base
  establish_connection :ez_cash
  self.primary_key = 'dev_id'
  
  belongs_to :device, :foreign_key => 'dev_id'
  
  
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.find_by_device_id(device_id)
    client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
    response = client.call(:do_query, message: {Query: "SELECT [denoms].* FROM [denoms] WHERE [denoms].[dev_id] = N'#{device_id}'"})
    Rails.logger.debug "**Denom.find_by_device_id_and_cassette_id response body: #{response.body}"
    if response.success?
      unless response.body[:do_query_response].blank? or response.body[:do_query_response][:return].to_i > 0
        xml_string = response.body[:do_query_response][:return]
        data= Hash.from_xml(xml_string)
        unless data['XML']['RESULT']['ROW'].blank?
          return data['XML']['RESULT']['ROW']
        else
          nil
        end
      else
        nil
      end
    else
      nil
    end
  end
  
  def self.find_by_device_id_and_cassette_id(device_id, cassette_id)
    client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
    response = client.call(:do_query, message: {Query: "SELECT [denoms].* FROM [denoms] WHERE [denoms].[dev_id] = N'#{device_id}' AND [denoms].[cassette_id] = N'#{cassette_id}'"})
    Rails.logger.debug "**Denom.find_by_device_id_and_cassette_id response body: #{response.body}"
    if response.success?
      unless response.body[:do_query_response].blank? or response.body[:do_query_response][:return].to_i > 0
        xml_string = response.body[:do_query_response][:return]
        data= Hash.from_xml(xml_string)
        unless data['XML']['RESULT']['ROW'].blank?
          return data['XML']['RESULT']['ROW']
        else
          nil
        end
      else
        nil
      end
    else
      nil
    end
  end
  
  def self.denomination(device_id, cassette_id)
    denom = Denom.find_by_device_id_and_cassette_id(device_id, cassette_id)
    denom['denomination'] unless denom.blank?
  end
  
end