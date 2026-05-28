# frozen_string_literal: true

require 'spec_helper_acceptance'

def skip_debian12_in_container
  return unless default[:hypervisor] == 'container_podman'

  "debootstrap in Debian 12 doesn't work inside a container" if fact('os.family') == 'Debian' && fact('os.release.major') == '12'
end

describe 'pbuilder' do
  context 'with defaults', skip: skip_debian12_in_container do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        pbuilder { 'local':
          methodurl => 'https://deb.debian.org/debian'
        }
        PUPPET
      end
    end

    describe file('/var/chroot/pbuilder/base_local.tgz') do
      it { is_expected.to be_file }
    end
  end
end
