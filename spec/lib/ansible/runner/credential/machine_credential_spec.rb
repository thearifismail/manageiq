require 'ansible/runner'
require 'ansible/runner/credential'

RSpec.describe Ansible::Runner::MachineCredential do
  it ".auth_type is the correct Authentication sub-class" do
    expect(described_class.auth_type).to eq("ManageIQ::Providers::EmbeddedAnsible::AutomationManager::MachineCredential")
  end

  context "with a credential object" do
    around do |example|
      Dir.mktmpdir("ansible-runner-credential-test") do |dir|
        @base_dir = dir
        example.run
      end
    end

    let(:auth) do
      auth_attributes = {
        :userid            => "manageiq",
        :password          => "secret",
        :auth_key          => "key_data",
        :become_username   => "root",
        :become_password   => "othersecret",
        :auth_key_password => "keypass",
        :options           => {:become_method => "su"}
      }
      FactoryBot.create(:embedded_ansible_machine_credential, auth_attributes)
    end

    let(:cred) { described_class.new(auth.id, @base_dir) }

    describe "#command_line" do
      it "is correct with all attributes" do
        expected = {
          :ask_pass      => nil,
          :become        => nil,
          :become_user   => "root",
          :become_method => "su",
          :user          => "manageiq"
        }
        expect(cred.command_line).to eq(expected)
      end

      it "doesn't send :user if userid is not set" do
        auth.update!(:userid => nil)

        expected = {
          :ask_pass      => nil,
          :become        => nil,
          :become_user   => "root",
          :become_method => "su"
        }
        expect(cred.command_line).to eq(expected)
      end

      it "doesn't send the become keys if :become_user is not set" do
        auth.update!(:become_username => nil)
        expect(cred.command_line).to eq(:ask_pass => nil, :user => "manageiq")
      end
    end

    it "#env_vars is an empty hash" do
      expect(cred.env_vars).to eq({})
    end

    it "#extra_vars is an empty hash" do
      expect(cred.extra_vars).to eq({})
    end

    describe "#write_password_file" do
      let(:password_file) { File.join(@base_dir, "env", "passwords") }
      let(:key_file)      { File.join(@base_dir, "env", "ssh_key") }

      def password_hash
        YAML.load_file(password_file)
      end

      it "writes out both the passwords file and the key file" do
        cred.write_password_file

        expect(password_hash).to eq(
          "^SSH [pP]assword:"                                     => "secret",
          "^BECOME [pP]assword:"                                  => "othersecret",
          "^Enter passphrase for [a-zA-Z0-9\-\/]+\/ssh_key_data:" => "keypass"
        )

        expect(File.read(key_file)).to eq("key_data")
      end

      it "doesn't create the password file if there are no passwords" do
        auth.update!(:password => nil, :become_password => nil, :auth_key_password => nil)
        cred.write_password_file
        expect(File.exist?(password_file)).to be_falsey
      end

      it "writes the password file in valid yaml when the password contains quotes" do
        password = '!compli-cat"ed&pass,"wor;d'
        auth.update!(:password => password)

        cred.write_password_file

        expect(password_hash["^SSH [pP]assword:"]).to eq(password)
      end
    end
  end
end
