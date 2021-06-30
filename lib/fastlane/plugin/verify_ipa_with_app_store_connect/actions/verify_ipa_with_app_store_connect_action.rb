require 'fastlane/action'
require_relative '../helper/verify_ipa_with_app_store_connect_helper'

module Fastlane
  module Actions
    class VerifyIpaWithAppStoreConnectAction < Action
      def self.run(params)
        UI.message("The verify_ipa_with_app_store_connect plugin is working!")
      end

      def self.description
        "Uses iTMSTransporter to verify an ipa with App Store Connect."
      end

      def self.authors
        ["Onno Bergob"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "This plugin can be used to check for issues before an actual upload to App Store Connect."
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "VERIFY_IPA_WITH_APP_STORE_CONNECT_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
