require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class VerifyIpaWithAppStoreConnectHelper
      # class methods that you define here become available in your action
      # as `Helper::VerifyIpaWithAppStoreConnectHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the verify_ipa_with_app_store_connect plugin helper!")
      end
    end
  end
end
