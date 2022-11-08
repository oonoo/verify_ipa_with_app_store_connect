require 'fastlane/action'
require_relative '../helper/verify_ipa_with_app_store_connect_helper'

module Fastlane
  module Actions
    class VerifyIpaWithAppStoreConnectAction < Action
      def self.run(params)
        ipa_path = params[:ipa_path]

        UI.message "Parameter ipa_path: #{ipa_path}"

        api_token = params[:api_token]

        transporter = FastlaneCore::AltoolTransporterExecutor.new

        api_key = { key_id: api_token.key_id, issuer_id: api_token.issuer_id, key: api_token.key_raw }

        api_key = api_key.clone
        api_key[:key_dir] = Dir.mktmpdir("deliver-")
        # Specified p8 needs to be generated to call altool
        File.open(File.join(api_key[:key_dir], "AuthKey_#{api_key[:key_id]}.p8"), "wb") do |p8|
          p8.write(api_key[:key])
        end

        command = [
          "API_PRIVATE_KEYS_DIR=#{api_key[:key_dir]}",
          "xcrun altool",
          "--validate-app",
          "--apiKey #{api_key[:key_id]}",
          "--apiIssuer #{api_key[:issuer_id]}",
          "-t #{params[:platform]}",
          "-f #{ipa_path.shellescape}",
          "-k 100000"
        ].compact.join(' ')

        UI.verbose(command)

        begin
          result = transporter.execute(command, false)
        ensure
          FileUtils.rm_rf(api_key[:key_dir])  # we don't need the file with the api key any more
          # FileUtils.rm_rf(package_path) # we don't need the ipa any more
        end

        if result
          UI.header("Successfully verified package with App Store Connect.")
        end

        unless result
          UI.user_error!("Error verifying ipa file!")
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Uses the command line tool iTMSTransporter provided with Xcode to verify the ipa."
      end

      def self.details
        "You can use this action to check for issues before an actual upload to App Store Connect."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :ipa_path,
                                       env_name: "FL_VERIFY_IPA_IPA_PATH",
                                       description: "Path to the ipa file to validate",
                                       is_string: true,
                                       default_value: Dir["*.ipa"].sort_by { |x| File.mtime(x) }.last,
                                       optional: true,
                                       verify_block: proc do |value|
                                         value = File.expand_path(value)
                                         UI.user_error!("could not find ipa file at path '#{value}'") unless File.exist?(value)
                                         UI.user_error!("'#{value}' doesn't seem to be an ipa file") unless value.end_with?(".ipa")
                                       end),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: "FL_VERIFY_IPA_PLATFORM",
                                       description: "Provide the platform for example ios",
                                       is_string: true, # true: verifies the input is a string, false: every kind of value
                                       default_value: "ios"), # the default value if the user didn't provide one
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_VERIFY_IPA_API_TOKEN",
                                       description: "Provide the api token",
                                       is_string: false, # true: verifies the input is a string, false: every kind of value
                                       default_value: false) # the default value if the user didn't provide one
        ]
      end

      def self.authors
        ["oonoo@github.com"]
      end

      def self.is_supported?(platform) 
        platform == :ios
      end
    end
  end
end
