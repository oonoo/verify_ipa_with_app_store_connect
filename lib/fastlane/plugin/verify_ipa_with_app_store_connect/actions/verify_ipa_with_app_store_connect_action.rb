require 'fastlane/action'
require_relative '../helper/verify_ipa_with_app_store_connect_helper'

module Fastlane
  module Actions
    class VerifyIpaWithAppStoreConnectAction < Action
      def self.run(params)
        UI.message "Parameter ipa_path: #{params[:ipa_path]}"

        app = find_app(params)

        package_path = FastlaneCore::IpaUploadPackageBuilder.new.generate(
          app_id: app.id,
          ipa_path: params[:ipa_path],
          package_path: "/tmp",
          platform: params[:platform]
        )

        api_token = params[:api_token]
        transporter = FastlaneCore::JavaTransporterExecutor.new

        command = [
          'xcrun iTMSTransporter',
          '-m verify',
          "-jwt #{api_token.text}",
          "-f #{package_path.shellescape}",
          '2>&1' # cause stderr to be written to stdout
        ].compact.join(' ') # compact gets rid of the possibly nil ENV value


        UI.verbose(command)

        result = transporter.execute(command, false)

        if result
          UI.header("Successfully verified package with App Store Connect.")
        end

        FileUtils.rm_rf(package_path) unless Helper.test? # we don't need the package any more

        unless result
          UI.user_error!("Error verifying ipa file!")
        end
      end

      def self.find_app(options)
        app_identifier = options[:app_identifier]

        if !app_identifier.to_s.empty?
          Spaceship::ConnectAPI.token = options[:api_token]
          app = Spaceship::ConnectAPI::App.find(app_identifier)
        end

        if app
          return app
        else
          UI.user_error!("Could not find app with app identifier '#{options[:app_identifier]}' in your App Store Connect account")
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
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       env_name: "FL_VERIFY_IPA_APP_IDENTIFIER",
                                       description: "Provide the app identifier",
                                       is_string: true, # true: verifies the input is a string, false: every kind of value
                                       default_value: false), # the default value if the user didn't provide one
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
