require 'spec_helper'

describe 'pbuilder' do
  let(:title) { 'foo' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'default parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pbuilder::common') }

        it do
          is_expected.to contain_file('/etc/pbuilder/foo/pbuilderrc').
            with_content(%r{MIRRORSITE=""}).
            with_content(%r{DISTRIBUTION="#{facts[:os]['distro']['codename']}"}).
            with_content(%r{ARCH="#{facts[:os]['architecture']}"}).
            with_content(%r{BASETGZ="/var/chroot/pbuilder/base_foo\.tgz"}).
            without_content(%r{BASEPATH=})

          is_expected.to contain_file('/usr/local/bin/pbuilder-foo').
            with_content(%r{CONFIGFILE="/etc/pbuilder/foo/pbuilderrc"})
        end
      end

      describe 'methodurl set' do
        let(:params) do
          { methodurl: 'http://ftp.debian.org/debian' }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_file('/etc/pbuilder/foo/pbuilderrc').
            with_content(%r{MIRRORSITE="http://ftp\.debian\.org/debian"})
        end
      end
    end
  end
end
