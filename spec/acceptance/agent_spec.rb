require 'spec_helper_acceptance'

describe 'puppet::agent::settings' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include ::puppet
        puppet::agent::setting { 'certificate_revocation':
          value => 'false'
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file '/etc/puppet/puppet.conf' do
      it { is_expected.to be_file }
      its(:content) { should contain /certificate_revocation/ }
    end

  end
end

