require 'google/apis/webmasters_v3'
module Embulk
  module Input
    module SearchAnalytics
      class Client
        def initialize(task, is_preview = false)
          @task = task
          @is_preview = is_preview
        end

        def invoke
          response = []
          start_row = 0
          loop do
            response << self.query(@task["site_url"], {
              :row_limit => @task["row_limit"],
              :dimensions => @task["dimensions"],
              :dimension_filter_groups => @task["dimension_filter_groups"],
              :search_type => @task["search_type"],
              :start_date => @task["start_date"],
              :end_date => @task["end_date"],
              :start_row => start_row,
            })
            break if response.last.length < @task["row_limit"]
            start_row += @task["row_limit"]
          end
          response.flatten
        end

        def query(site_url, params)
          unless params[:dimension_filter_groups].nil?
            params[:dimension_filter_groups] = JSON.parse(params[:dimension_filter_groups].to_json, symbolize_names: true)
          end
          self.service.query_search_analytics(site_url, params, {}).rows.collect do |row|
            item = {}
            @task["dimensions"].each_with_index do |dim, idx|
              item[dim] = row.keys[idx]
            end
            item["clicks"] = row.clicks.to_i
            item["impressions"] = row.impressions.to_i
            item["ctr"] = row.ctr.to_f
            item["position"] = row.position.to_f
            item
          end
        end

        def service
          webmasters_service = ::Google::Apis::WebmastersV3::WebmastersService.new
          webmasters_service.authorization = Signet::OAuth2::Client.new({
            :token_credential_uri => @task["token_credential_uri"],
            :audience => @task["audience"],
            :client_id => @task["client_id"],
            :client_secret => @task["client_secret"],
            :refresh_token => @task["refresh_token"],
            :scope => @task["scope"],
          })
          webmasters_service.authorization.fetch_access_token!
          webmasters_service
        end
      end
    end
  end
end
