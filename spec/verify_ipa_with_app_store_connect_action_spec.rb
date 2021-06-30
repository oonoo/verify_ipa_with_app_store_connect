describe Fastlane::Actions::VerifyIpaWithAppStoreConnectAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The verify_ipa_with_app_store_connect plugin is working!")

      Fastlane::Actions::VerifyIpaWithAppStoreConnectAction.run(nil)
    end
  end
end
