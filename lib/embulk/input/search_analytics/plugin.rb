module Embulk
  module Input
    module SearchAnalytics
      class Plugin < InputPlugin
        ::Embulk::Plugin.register_input("search_analytics", self)

        def self.transaction(config, &control)
          task = {
            # API Authorize Parameters
            "token_credential_uri" => "https://accounts.google.com/o/oauth2/token",
            "audience" => "https://accounts.google.com/o/oauth2/token",
            "client_id" => config.param("client_id", :string),
            "client_secret" => config.param("client_secret", :string),
            "refresh_token" => config.param("refresh_token", :string),
            "scope" => "https://www.googleapis.com/auth/webmasters.readonly",

            # API Request Parameters
            "site_url" => config.param("site_url", :string),
            "start_date" => config.param("start_date", :string),
            "end_date" => config.param("end_date", :string),
            "dimensions" => config.param("dimensions", :array),
            "dimension_filter_groups" => config.param("dimension_filter_groups", :array, default: nil),
            "search_type" => config.param("search_type", :string, default: "web"),
            "row_limit" => config.param("row_limit", :integer, default: 5000),
          }
          columns = columns_from_task(task)
          resume(task, columns, 1, &control)
        end

        def self.resume(task, columns, count, &control)
          task_reports = yield(task, columns, count)

          next_config_diff = {}
          return next_config_diff
        end

        def self.columns_from_task(task)
          columns = task["dimensions"].map{|dimension|
            Column.new(nil, dimension, :string)
          }
          columns << Column.new(nil, "clicks", :long)
          columns << Column.new(nil, "impressions", :long)
          columns << Column.new(nil, "ctr", :double)
          columns << Column.new(nil, "position", :double)
          columns
        end

        def init
        end

        def run
          columns = self.class.columns_from_task(task)
          Client.new(task, @is_preview).invoke.each do |row|
            @page_builder.add columns.map{|col| row[col.name]}
          end
          @page_builder.finish
          task_report = {}
          task_report
        end
      end
    end
  end
end
