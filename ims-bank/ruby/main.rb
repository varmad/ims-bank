require 'sinatra'
require 'sinatra/reloader'

require 'net/http'
require 'json'

set :protection, :except => :frame_options
set :bind, '0.0.0.0'
set :port, 8080

get '/' do
  url = 'https://quietstreamfinancial.github.io/eng-recruiting/transactions.json'
  uri = URI(url)
  response = Net::HTTP.get(uri)
  @ims_data = JSON.parse(response)

  @converted_data = @ims_data.each do |data|
    data['transaction_amount'] = data['transaction_amount']&.gsub!('$', '')&.to_i
  end

  @customer_accounts = {}
  @converted_data.each do |data|
    @customer_accounts[data['customer_name']] ||= {}
    @customer_accounts[data['customer_name']][data['account_type']] ||= {}
    @customer_accounts[data['customer_name']][data['account_type']]['total'] ||= 0
    @customer_accounts[data['customer_name']][data['account_type']]['total'] += data['transaction_amount']
  end

  erb :table
end
